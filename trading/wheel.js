#!/usr/bin/env node
// wheel.js — Scan-to-trade pipeline
// Reads bullish scanner output → filters for wheel-eligible stocks → scans option chains → ranks candidates
//
// Usage:
//   node wheel.js candidates              # Show CSP candidates from latest scan
//   node wheel.js candidates --scan FILE  # Use specific scan JSON
//   node wheel.js candidates --top 5      # Show top N (default 10)
//   node wheel.js dryrun TICKER           # Dry-run best CSP for ticker
//   node wheel.js execute TICKER          # Submit order (requires --confirm)
//   node wheel.js positions               # Show current wheel positions + P&L
//   node wheel.js summary                 # Full pipeline: scan → candidates → positions → recommendation

const path = require('path');
const fs = require('fs');
const tt = require('./tastytrade');

// --- Config ---
const WHEEL_CRITERIA = {
  maxPrice: 50,           // Stock price * 100 must be ≤ maxPositionSize
  minUpside: 10,          // Minimum analyst upside %
  minRSI: 0,              // Floor (no filter)
  maxRSI: 45,             // Oversold / neutral only
  preferredRatings: ['buy', 'strong_buy'],  // Analyst consensus
  preferredSignals: ['BUY', 'WATCH'],       // RSI signals
  minATHDrop: -15,        // At least 15% below ATH
  excludeTickers: ['MSTR', 'COIN'],         // Too volatile / crypto-adjacent
};

// --- Scan Data Loading ---

function getLatestScan(dataDir) {
  const dir = dataDir || path.join(__dirname, '..', 'data');
  const files = fs.readdirSync(dir)
    .filter(f => f.startsWith('scan_') && f.endsWith('.json'))
    .sort()
    .reverse();
  if (!files.length) throw new Error(`No scan files in ${dir}`);
  return path.join(dir, files[0]);
}

function loadScan(filePath) {
  const raw = fs.readFileSync(filePath, 'utf-8');
  return JSON.parse(raw);
}

// --- Candidate Filtering ---

function scoreStock(stock) {
  let score = 0;

  // RSI — lower is better (oversold)
  if (stock.rsi < 30) score += 30;
  else if (stock.rsi < 40) score += 15;
  else if (stock.rsi < 45) score += 5;

  // Analyst upside
  if (stock.upside >= 50) score += 25;
  else if (stock.upside >= 30) score += 15;
  else if (stock.upside >= 15) score += 8;

  // Rating
  const r = (stock.rating || '').toLowerCase();
  if (r === 'strong_buy') score += 20;
  else if (r === 'buy') score += 12;
  else if (r === 'hold') score += 3;

  // ATH discount — deeper = more value
  if (stock.pct_from_ath <= -50) score += 15;
  else if (stock.pct_from_ath <= -30) score += 10;
  else if (stock.pct_from_ath <= -20) score += 5;

  // Down streak bonus (mean reversion bet)
  if (stock.streak <= -3) score += 10;
  else if (stock.streak <= -2) score += 5;

  // AI assessment bonus
  const ai = (stock.ai_assessment || '').toUpperCase();
  if (ai.startsWith('BUY')) score += 15;
  else if (ai.startsWith('WAIT')) score += 3;
  else if (ai.startsWith('PASS')) score -= 5;

  // Volume surge (institutional interest)
  if (stock.vol_surge > 2) score += 5;

  return score;
}

function filterWheelCandidates(scan) {
  const maxStockPrice = tt.CONFIG.maxPositionSize / 100;

  // Combine all categories, deduplicate
  const all = [
    ...scan.watchlist,
    ...scan.big_drops,
    ...scan.down_streaks,
  ];
  const seen = new Set();
  const unique = [];
  for (const s of all) {
    if (!seen.has(s.ticker)) {
      seen.add(s.ticker);
      unique.push(s);
    }
  }

  return unique
    .filter(s => {
      // Hard filters
      if (WHEEL_CRITERIA.excludeTickers.includes(s.ticker)) return false;
      if (s.price > maxStockPrice) return false;
      if (s.price < 5) return false; // penny stock guard
      if (s.rsi > WHEEL_CRITERIA.maxRSI) return false;
      if (s.pct_from_ath > WHEEL_CRITERIA.minATHDrop) return false;

      // Must have options (proxy: market cap > $2B is already in scanner)
      return true;
    })
    .map(s => ({ ...s, wheelScore: scoreStock(s) }))
    .sort((a, b) => b.wheelScore - a.wheelScore);
}

// --- Option Chain Enrichment ---

async function enrichWithOptions(candidates, limit = 10) {
  const enriched = [];

  for (const stock of candidates.slice(0, limit)) {
    try {
      const chain = await tt.getOptionChain(stock.ticker);
      const csps = tt.findBestCSP(chain, stock.price, tt.CONFIG.maxPositionSize);

      if (csps.length === 0) continue;

      // Pick the best CSP: closest to ATM within budget
      const best = csps[0];

      enriched.push({
        ...stock,
        csp: {
          strike: best.strike,
          expDate: best.expDate,
          dte: best.dte,
          cashNeeded: best.cashNeeded,
          optionSymbol: best.optionSymbol,
          breakeven: best.strike, // premium not available from chain alone
          allCandidates: csps.slice(0, 5),
        },
      });
    } catch (e) {
      // Skip stocks where chain fetch fails
      continue;
    }
  }

  return enriched;
}

// --- Display ---

function printCandidates(candidates, enriched = false) {
  console.log('━━━ WHEEL CANDIDATES ━━━');
  console.log(`$${tt.CONFIG.maxPositionSize} budget | ${tt.CONFIG.targetDTE[0]}-${tt.CONFIG.targetDTE[1]} DTE\n`);

  if (!candidates.length) {
    console.log('No candidates match criteria.');
    return;
  }

  // Header
  const header = enriched
    ? `${'Ticker'.padEnd(7)} ${'Price'.padStart(7)} ${'%ATH'.padStart(7)} ${'RSI'.padStart(4)} ${'Score'.padStart(5)} ${'Rating'.padStart(8)} ${'Strike'.padStart(7)} ${'Exp'.padStart(11)} ${'DTE'.padStart(4)} ${'Cash'.padStart(7)} AI`
    : `${'Ticker'.padEnd(7)} ${'Price'.padStart(7)} ${'%ATH'.padStart(7)} ${'RSI'.padStart(4)} ${'Upside'.padStart(7)} ${'Score'.padStart(5)} ${'Rating'.padStart(8)} ${'Signal'.padStart(6)} AI`;

  console.log(header);
  console.log('─'.repeat(header.length));

  for (const c of candidates) {
    const ai = (c.ai_assessment || '').slice(0, 40);
    if (enriched && c.csp) {
      console.log(
        `${c.ticker.padEnd(7)} ${('$' + c.price.toFixed(0)).padStart(7)} ${(c.pct_from_ath.toFixed(1) + '%').padStart(7)} ${c.rsi.toFixed(0).padStart(4)} ${String(c.wheelScore).padStart(5)} ${(c.rating || '-').padStart(8)} ${('$' + c.csp.strike.toFixed(0)).padStart(7)} ${c.csp.expDate.padStart(11)} ${String(c.csp.dte).padStart(4)} ${('$' + c.csp.cashNeeded.toFixed(0)).padStart(7)} ${ai}`
      );
    } else {
      console.log(
        `${c.ticker.padEnd(7)} ${('$' + c.price.toFixed(0)).padStart(7)} ${(c.pct_from_ath.toFixed(1) + '%').padStart(7)} ${c.rsi.toFixed(0).padStart(4)} ${('+' + (c.upside || 0).toFixed(0) + '%').padStart(7)} ${String(c.wheelScore).padStart(5)} ${(c.rating || '-').padStart(8)} ${(c.signal || '-').padStart(6)} ${ai}`
      );
    }
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━');
}

async function printPositions() {
  console.log('━━━ WHEEL POSITIONS ━━━\n');

  try {
    const positions = await tt.getPositions();
    const items = positions.items || positions || [];

    if (!items.length) {
      console.log('No open positions.\n');
    } else {
      for (const p of items) {
        const dir = p['quantity-direction'] === 'Short' ? 'SOLD' : 'LONG';
        const pnl = p['realized-day-gain'] ? ` | P&L: $${p['realized-day-gain']}` : '';
        console.log(`  ${p.symbol} | ${dir} x${p.quantity} | ${p['instrument-type']}${pnl}`);
      }
    }

    const orders = await tt.getOrders();
    const liveOrders = orders.items || orders || [];
    console.log(`\nLive orders: ${liveOrders.length}`);
    for (const o of liveOrders) {
      const legs = (o.legs || []).map(l => `${l.action} ${l.symbol}`).join(', ');
      console.log(`  #${o.id} | ${o['order-type']} $${o.price} | ${legs}`);
    }
  } catch (e) {
    console.log(`Error: ${e.message}`);
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━');
}

async function dryRunCSP(ticker, scanFile) {
  const scan = loadScan(scanFile || getLatestScan());
  const all = [...scan.watchlist, ...scan.big_drops, ...scan.down_streaks];
  const stock = all.find(s => s.ticker.toUpperCase() === ticker.toUpperCase());

  if (!stock) {
    console.log(`${ticker} not found in scan data. Running option chain lookup anyway...`);
  }

  const chain = await tt.getOptionChain(ticker.toUpperCase());
  const price = stock?.price || 0;
  const csps = tt.findBestCSP(chain, price, tt.CONFIG.maxPositionSize);

  if (!csps.length) {
    console.log(`No CSP candidates for ${ticker}`);
    return;
  }

  const best = csps[0];
  console.log(`\n${ticker} — Best CSP:`);
  console.log(`  Strike: $${best.strike} put`);
  console.log(`  Expiry: ${best.expDate} (${best.dte} DTE)`);
  console.log(`  Cash needed: $${best.cashNeeded}`);
  console.log(`  Option: ${best.optionSymbol}`);

  // Build order and dry-run
  const order = tt.buildCSPOrder(ticker.toUpperCase(), best.expDate, best.strike, tt.CONFIG.minPremium);
  console.log('\nDry-run order:');
  console.log(JSON.stringify(order, null, 2));

  try {
    const result = await tt.dryRun(order);
    console.log('\nDry-run result:');
    console.log(JSON.stringify(result, null, 2));
  } catch (e) {
    console.log(`\nDry-run error: ${e.message}`);
  }
}

// --- JSON Output (for dashboard consumption) ---

function outputJSON(candidates) {
  const output = {
    timestamp: new Date().toISOString(),
    budget: tt.CONFIG.maxPositionSize,
    dte_range: tt.CONFIG.targetDTE,
    candidates: candidates.map(c => ({
      ticker: c.ticker,
      name: c.name,
      price: c.price,
      pct_from_ath: c.pct_from_ath,
      rsi: c.rsi,
      upside: c.upside,
      rating: c.rating,
      signal: c.signal,
      ai_assessment: c.ai_assessment || '',
      wheel_score: c.wheelScore,
      csp: c.csp || null,
    })),
  };
  console.log(JSON.stringify(output, null, 2));
}

// --- Summary Pipeline ---

async function summary(scanFile) {
  const file = scanFile || getLatestScan();
  const scan = loadScan(file);

  console.log(`📊 Scan: ${path.basename(file)}`);
  console.log(`   ${scan.total_stocks} stocks | QQQ 30d: ${scan.qqq_30d_return > 0 ? '+' : ''}${scan.qqq_30d_return.toFixed(1)}%\n`);

  // Filter
  const candidates = filterWheelCandidates(scan);
  console.log(`🎯 ${candidates.length} stocks pass wheel criteria\n`);

  // Show top candidates without options data first (fast)
  printCandidates(candidates.slice(0, 15));

  // Enrich top 10 with real option chains
  console.log('\n⏳ Fetching option chains for top candidates...\n');
  const enriched = await enrichWithOptions(candidates, 10);

  if (enriched.length) {
    printCandidates(enriched, true);
  }

  // Show positions
  console.log();
  await printPositions();
}

// --- CLI ---
async function main() {
  const args = process.argv.slice(2);
  const cmd = args[0] || 'summary';

  // Parse flags
  const flags = {};
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--scan' && args[i + 1]) flags.scan = args[++i];
    else if (args[i] === '--top' && args[i + 1]) flags.top = parseInt(args[++i]);
    else if (args[i] === '--json') flags.json = true;
    else if (args[i] === '--confirm') flags.confirm = true;
    else if (!args[i].startsWith('-')) flags.ticker = args[i];
  }

  try {
    switch (cmd) {
      case 'candidates': {
        const scan = loadScan(flags.scan || getLatestScan());
        const candidates = filterWheelCandidates(scan);
        const top = candidates.slice(0, flags.top || 10);

        if (flags.json) {
          outputJSON(top);
        } else {
          printCandidates(top);
        }
        break;
      }

      case 'enrich': {
        const scan = loadScan(flags.scan || getLatestScan());
        const candidates = filterWheelCandidates(scan);
        const enriched = await enrichWithOptions(candidates, flags.top || 10);

        if (flags.json) {
          outputJSON(enriched);
        } else {
          printCandidates(enriched, true);
        }
        break;
      }

      case 'dryrun': {
        if (!flags.ticker) { console.log('Usage: node wheel.js dryrun TICKER'); break; }
        await dryRunCSP(flags.ticker, flags.scan);
        break;
      }

      case 'execute': {
        if (!flags.ticker) { console.log('Usage: node wheel.js execute TICKER --confirm'); break; }
        if (!flags.confirm) { console.log('⚠️  Add --confirm to actually submit the order'); break; }

        const chain = await tt.getOptionChain(flags.ticker.toUpperCase());
        const csps = tt.findBestCSP(chain, 0, tt.CONFIG.maxPositionSize);
        if (!csps.length) { console.log('No candidates'); break; }

        const best = csps[0];
        const order = tt.buildCSPOrder(flags.ticker.toUpperCase(), best.expDate, best.strike, tt.CONFIG.minPremium);
        console.log('Submitting order...');
        const result = await tt.submitOrder(order);
        console.log('✅ Order submitted:', JSON.stringify(result, null, 2));
        break;
      }

      case 'positions': {
        await printPositions();
        break;
      }

      case 'summary': {
        await summary(flags.scan);
        break;
      }

      default:
        console.log(`
Usage: node wheel.js <command> [options]

Commands:
  candidates              Show wheel-eligible stocks from latest scan
  enrich                  Candidates + live option chain data
  dryrun <TICKER>         Dry-run best CSP order
  execute <TICKER>        Submit order (requires --confirm)
  positions               Show current positions & orders
  summary                 Full pipeline overview

Options:
  --scan FILE             Use specific scan JSON file
  --top N                 Limit results (default 10)
  --json                  Output as JSON (for dashboard)
  --confirm               Required for execute
        `);
    }
  } catch (e) {
    console.error('❌', e.message);
    process.exit(1);
  }
}

// --- Exports ---
module.exports = {
  WHEEL_CRITERIA,
  scoreStock,
  filterWheelCandidates,
  enrichWithOptions,
  loadScan,
  getLatestScan,
  outputJSON,
};

if (require.main === module) main();
