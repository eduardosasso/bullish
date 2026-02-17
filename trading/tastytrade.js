// tastytrade.js — Tastytrade API client for wheel strategy
// Sandbox: https://api.cert.tastyworks.com
// Production: https://api.tastyworks.com

const SANDBOX_BASE = 'https://api.cert.tastyworks.com';
const PROD_BASE = 'https://api.tastyworks.com';

const CONFIG = {
  username: 'jazstonne',
  password: 'TTSandbox2026x',
  accountNumber: '5WW75739',
  sandbox: true,
  // Wheel strategy params
  maxPositionSize: 5000,       // Max cash to deploy
  targetDTE: [20, 45],         // Days to expiration range
  targetDelta: [-0.30, -0.20], // Delta range for CSPs (OTM)
  minPremium: 0.30,            // Min premium per contract
  maxContracts: 1,             // Max contracts per trade (cash account)
};

function getBase() {
  return CONFIG.sandbox ? SANDBOX_BASE : PROD_BASE;
}

// --- Auth ---
let sessionToken = null;
let tokenExpiry = null;

async function login() {
  const res = await fetch(`${getBase()}/sessions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ login: CONFIG.username, password: CONFIG.password }),
  });
  const data = await res.json();
  if (data.error) throw new Error(`Login failed: ${data.error.message}`);
  sessionToken = data.data['session-token'];
  tokenExpiry = new Date(data.data['session-expiration']);
  console.log(`✅ Logged in as ${data.data.user.username}, expires ${tokenExpiry.toISOString()}`);
  return sessionToken;
}

async function getToken() {
  if (!sessionToken || !tokenExpiry || new Date() > tokenExpiry) {
    await login();
  }
  return sessionToken;
}

async function api(path, opts = {}) {
  const token = await getToken();
  const res = await fetch(`${getBase()}${path}`, {
    ...opts,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
      ...opts.headers,
    },
  });
  const data = await res.json();
  if (data.error) throw new Error(`API ${path}: ${data.error.message}`);
  return data.data;
}

// --- Account ---
async function getBalance() {
  return api(`/accounts/${CONFIG.accountNumber}/balances`);
}

async function getPositions() {
  return api(`/accounts/${CONFIG.accountNumber}/positions`);
}

async function getOrders(status = 'Live') {
  return api(`/accounts/${CONFIG.accountNumber}/orders?status=${status}`);
}

// --- Instruments ---
async function getOptionChain(symbol) {
  return api(`/option-chains/${symbol}/nested`);
}

async function getEquity(symbol) {
  return api(`/instruments/equities/${symbol}`);
}

// --- Order Helpers ---

// Build option symbol: e.g., "AAPL  260320P00080000" 
// Format: SYMBOL (padded to 6) + YYMMDD + P/C + strike (8 digits: 5 whole + 3 decimal)
function buildOptionSymbol(underlying, expDate, type, strike) {
  const padded = underlying.padEnd(6, ' ');
  const dateStr = expDate.replace(/-/g, '').slice(2); // YYMMDD
  const typeChar = type === 'put' ? 'P' : 'C';
  const whole = Math.floor(strike);
  const decimal = Math.round((strike - whole) * 1000);
  const strikeStr = whole.toString().padStart(5, '0') + decimal.toString().padStart(3, '0');
  return `${padded}${dateStr}${typeChar}${strikeStr}`;
}

// Sell cash-secured put
function buildCSPOrder(symbol, expDate, strike, premium, quantity = 1) {
  const optSymbol = buildOptionSymbol(symbol, expDate, 'put', strike);
  return {
    'time-in-force': 'Day',
    'order-type': 'Limit',
    'price': premium.toFixed(2),
    'price-effect': 'Credit',
    legs: [{
      action: 'Sell to Open',
      symbol: optSymbol,
      quantity,
      'instrument-type': 'Equity Option',
    }],
  };
}

// Sell covered call
function buildCoveredCallOrder(symbol, expDate, strike, premium, quantity = 1) {
  const optSymbol = buildOptionSymbol(symbol, expDate, 'call', strike);
  return {
    'time-in-force': 'Day',
    'order-type': 'Limit',
    'price': premium.toFixed(2),
    'price-effect': 'Credit',
    legs: [{
      action: 'Sell to Open',
      symbol: optSymbol,
      quantity,
      'instrument-type': 'Equity Option',
    }],
  };
}

// Buy to close (any option)
function buildBuyToCloseOrder(optSymbol, price, quantity = 1) {
  return {
    'time-in-force': 'Day',
    'order-type': 'Limit',
    'price': price.toFixed(2),
    'price-effect': 'Debit',
    legs: [{
      action: 'Buy to Close',
      symbol: optSymbol,
      quantity,
      'instrument-type': 'Equity Option',
    }],
  };
}

// --- Order Execution ---
async function dryRun(order) {
  return api(`/accounts/${CONFIG.accountNumber}/orders/dry-run`, {
    method: 'POST',
    body: JSON.stringify(order),
  });
}

async function submitOrder(order) {
  return api(`/accounts/${CONFIG.accountNumber}/orders`, {
    method: 'POST',
    body: JSON.stringify(order),
  });
}

async function cancelOrder(orderId) {
  return api(`/accounts/${CONFIG.accountNumber}/orders/${orderId}`, {
    method: 'DELETE',
  });
}

// --- Wheel Strategy Logic ---

// Extract expirations from nested chain response
function getExpirations(chain) {
  if (chain.items && chain.items[0] && chain.items[0].expirations) {
    return chain.items[0].expirations;
  }
  return chain.expirations || [];
}

// Find best CSP candidate from option chain
function findBestCSP(chain, stockPrice, maxCost) {
  const now = new Date();
  const candidates = [];
  const expirations = getExpirations(chain);

  for (const exp of expirations) {
    const dte = exp['days-to-expiration'] || Math.round((new Date(exp['expiration-date']) - now) / (1000 * 60 * 60 * 24));
    
    if (dte < CONFIG.targetDTE[0] || dte > CONFIG.targetDTE[1]) continue;

    for (const strike of exp.strikes || []) {
      const strikePrice = parseFloat(strike['strike-price']);
      
      // Cash-secured put: need cash = strike * 100
      const cashNeeded = strikePrice * 100;
      if (cashNeeded > maxCost) continue;
      
      // Only OTM puts (strike below current price)
      if (strikePrice >= stockPrice) continue;
      
      // Check if put exists (in nested format, put is a symbol string)
      const putSymbol = typeof strike.put === 'string' ? strike.put : strike.put?.symbol;
      if (!putSymbol) continue;

      candidates.push({
        optionSymbol: putSymbol.trim(),
        streamerSymbol: strike['put-streamer-symbol'] || '',
        strike: strikePrice,
        expDate: exp['expiration-date'],
        dte,
        cashNeeded,
      });
    }
  }

  // Sort by strike descending (closest to ATM = most premium)
  candidates.sort((a, b) => b.strike - a.strike);
  return candidates.slice(0, 10);
}

// Find best covered call for an existing position
function findBestCC(chain, stockPrice, shares) {
  const now = new Date();
  const contracts = Math.floor(shares / 100);
  if (contracts === 0) return [];
  
  const candidates = [];
  const expirations = getExpirations(chain);

  for (const exp of expirations) {
    const dte = exp['days-to-expiration'] || Math.round((new Date(exp['expiration-date']) - now) / (1000 * 60 * 60 * 24));
    
    if (dte < CONFIG.targetDTE[0] || dte > CONFIG.targetDTE[1]) continue;

    for (const strike of exp.strikes || []) {
      const strikePrice = parseFloat(strike['strike-price']);
      
      // Only OTM calls (strike above current price)
      if (strikePrice <= stockPrice) continue;
      
      const callSymbol = typeof strike.call === 'string' ? strike.call : strike.call?.symbol;
      if (!callSymbol) continue;

      candidates.push({
        optionSymbol: callSymbol.trim(),
        streamerSymbol: strike['call-streamer-symbol'] || '',
        strike: strikePrice,
        expDate: exp['expiration-date'],
        dte,
        contracts,
      });
    }
  }

  // Sort by strike ascending (closest to ATM = most premium)
  candidates.sort((a, b) => a.strike - b.strike);
  return candidates.slice(0, 10);
}

// --- Status Report ---
async function status() {
  console.log('━━━ Tastytrade Wheel Bot Status ━━━');
  console.log(`Environment: ${CONFIG.sandbox ? 'SANDBOX' : '⚠️  PRODUCTION'}`);
  console.log(`Account: ${CONFIG.accountNumber}`);
  
  try {
    const bal = await getBalance();
    console.log(`\n💰 Balance:`);
    console.log(`  Cash: $${bal['cash-balance'] || 'N/A'}`);
    console.log(`  Net Liq: $${bal['net-liquidating-value'] || 'N/A'}`);
    console.log(`  Buying Power: $${bal['equity-buying-power'] || 'N/A'}`);
  } catch (e) {
    console.log(`\n💰 Balance: ${e.message}`);
  }
  
  try {
    const pos = await getPositions();
    const items = pos.items || pos || [];
    console.log(`\n📊 Positions: ${items.length}`);
    for (const p of items) {
      console.log(`  ${p.symbol} | ${p['quantity-direction']} ${p.quantity} | Type: ${p['instrument-type']}`);
    }
  } catch (e) {
    console.log(`\n📊 Positions: ${e.message}`);
  }
  
  try {
    const orders = await getOrders();
    const items = orders.items || orders || [];
    console.log(`\n📋 Live Orders: ${items.length}`);
    for (const o of items) {
      console.log(`  #${o.id} | ${o.status} | ${o['order-type']} | $${o.price}`);
    }
  } catch (e) {
    console.log(`\n📋 Orders: ${e.message}`);
  }
  
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// --- Scan for Wheel Opportunities ---
async function scan(symbols = ['AAPL', 'AMD', 'INTC', 'F', 'SOFI', 'PLTR']) {
  console.log('━━━ Wheel Strategy Scanner ━━━');
  console.log(`Scanning: ${symbols.join(', ')}`);
  console.log(`DTE: ${CONFIG.targetDTE[0]}-${CONFIG.targetDTE[1]} days`);
  console.log(`Max position: $${CONFIG.maxPositionSize}\n`);

  let balance;
  try {
    balance = await getBalance();
  } catch (e) {
    console.log(`⚠️  Can't fetch balance: ${e.message}`);
    console.log('Using max position size as proxy.\n');
  }
  
  const buyingPower = balance?.['equity-buying-power'] 
    ? parseFloat(balance['equity-buying-power']) 
    : CONFIG.maxPositionSize;

  const results = [];

  for (const sym of symbols) {
    try {
      const chain = await getOptionChain(sym);
      const exps = getExpirations(chain);
      if (exps.length === 0) {
        console.log(`${sym}: No option chain data`);
        continue;
      }

      // Approximate stock price from middle of nearest expiration strikes
      const nearestStrikes = exps[0].strikes || [];
      const midIdx = Math.floor(nearestStrikes.length / 2);
      const approxPrice = nearestStrikes[midIdx] ? parseFloat(nearestStrikes[midIdx]['strike-price']) : 0;

      const csps = findBestCSP(chain, approxPrice, Math.min(buyingPower, CONFIG.maxPositionSize));
      
      if (csps.length > 0) {
        console.log(`\n${sym} (~$${approxPrice}) — ${csps.length} CSP candidates:`);
        for (const c of csps.slice(0, 3)) {
          console.log(`  $${c.strike} put | ${c.expDate} | ${c.dte}d | Cash: $${c.cashNeeded}`);
        }
        results.push({ symbol: sym, price: approxPrice, candidates: csps });
      } else {
        console.log(`${sym}: No CSP candidates within constraints`);
      }
    } catch (e) {
      console.log(`${sym}: ${e.message}`);
    }
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  return results;
}

// --- Exports ---
module.exports = {
  CONFIG,
  login,
  getToken,
  api,
  getBalance,
  getPositions,
  getOrders,
  getOptionChain,
  getEquity,
  buildOptionSymbol,
  buildCSPOrder,
  buildCoveredCallOrder,
  buildBuyToCloseOrder,
  dryRun,
  submitOrder,
  cancelOrder,
  findBestCSP,
  findBestCC,
  status,
  scan,
};

// --- CLI ---
if (require.main === module) {
  const cmd = process.argv[2] || 'status';
  (async () => {
    try {
      if (cmd === 'status') await status();
      else if (cmd === 'scan') await scan(process.argv.slice(3).length ? process.argv.slice(3) : undefined);
      else if (cmd === 'login') { await login(); console.log('Token:', sessionToken); }
      else console.log('Usage: node tastytrade.js [status|scan|login] [symbols...]');
    } catch (e) {
      console.error('❌', e.message);
    }
  })();
}
