// tastytrade.test.js — Tests for the wheel strategy trading bot
const assert = require('node:assert/strict');
const { describe, it, beforeEach, mock } = require('node:test');

const tt = require('./tastytrade');

describe('Config', () => {
  it('has required fields', () => {
    assert.ok(tt.CONFIG.username);
    assert.ok(tt.CONFIG.password);
    assert.ok(tt.CONFIG.accountNumber);
    assert.strictEqual(tt.CONFIG.sandbox, true);
    assert.ok(tt.CONFIG.maxPositionSize > 0);
    assert.ok(Array.isArray(tt.CONFIG.targetDTE));
    assert.strictEqual(tt.CONFIG.targetDTE.length, 2);
  });

  it('defaults to sandbox', () => {
    assert.strictEqual(tt.CONFIG.sandbox, true);
  });
});

describe('buildOptionSymbol', () => {
  it('builds correct put symbol', () => {
    const sym = tt.buildOptionSymbol('AAPL', '2026-03-20', 'put', 170);
    assert.strictEqual(sym, 'AAPL  260320P00170000');
  });

  it('builds correct call symbol', () => {
    const sym = tt.buildOptionSymbol('AAPL', '2026-03-20', 'call', 200);
    assert.strictEqual(sym, 'AAPL  260320C00200000');
  });

  it('handles fractional strikes', () => {
    const sym = tt.buildOptionSymbol('AAPL', '2026-03-20', 'put', 197.5);
    assert.strictEqual(sym, 'AAPL  260320P00197500');
  });

  it('pads short symbols', () => {
    const sym = tt.buildOptionSymbol('F', '2026-03-20', 'put', 13);
    assert.strictEqual(sym, 'F     260320P00013000');
  });

  it('handles low strikes', () => {
    const sym = tt.buildOptionSymbol('SOFI', '2026-04-17', 'call', 8.5);
    assert.strictEqual(sym, 'SOFI  260417C00008500');
  });
});

describe('buildCSPOrder', () => {
  it('builds valid cash-secured put order', () => {
    const order = tt.buildCSPOrder('F', '2026-03-20', 13, 0.45);
    assert.strictEqual(order['time-in-force'], 'Day');
    assert.strictEqual(order['order-type'], 'Limit');
    assert.strictEqual(order['price'], '0.45');
    assert.strictEqual(order['price-effect'], 'Credit');
    assert.strictEqual(order.legs.length, 1);
    assert.strictEqual(order.legs[0].action, 'Sell to Open');
    assert.strictEqual(order.legs[0]['instrument-type'], 'Equity Option');
    assert.strictEqual(order.legs[0].quantity, 1);
    assert.match(order.legs[0].symbol, /F\s+260320P00013000/);
  });

  it('supports custom quantity', () => {
    const order = tt.buildCSPOrder('F', '2026-03-20', 13, 0.45, 3);
    assert.strictEqual(order.legs[0].quantity, 3);
  });
});

describe('buildCoveredCallOrder', () => {
  it('builds valid covered call order', () => {
    const order = tt.buildCoveredCallOrder('AAPL', '2026-03-20', 200, 2.50);
    assert.strictEqual(order['price-effect'], 'Credit');
    assert.strictEqual(order.legs[0].action, 'Sell to Open');
    assert.match(order.legs[0].symbol, /AAPL\s+260320C00200000/);
  });
});

describe('buildBuyToCloseOrder', () => {
  it('builds valid BTC order', () => {
    const order = tt.buildBuyToCloseOrder('F     260320P00013000', 0.10);
    assert.strictEqual(order['price-effect'], 'Debit');
    assert.strictEqual(order.legs[0].action, 'Buy to Close');
    assert.strictEqual(order.legs[0].symbol, 'F     260320P00013000');
    assert.strictEqual(order['price'], '0.10');
  });
});

describe('findBestCSP', () => {
  const mockChain = {
    items: [{
      'underlying-symbol': 'F',
      expirations: [
        {
          'expiration-date': (() => {
            const d = new Date();
            d.setDate(d.getDate() + 30);
            return d.toISOString().split('T')[0];
          })(),
          'days-to-expiration': 30,
          strikes: [
            { 'strike-price': '10.0', put: 'F     260320P00010000', 'put-streamer-symbol': '.F260320P10' },
            { 'strike-price': '11.0', put: 'F     260320P00011000', 'put-streamer-symbol': '.F260320P11' },
            { 'strike-price': '12.0', put: 'F     260320P00012000', 'put-streamer-symbol': '.F260320P12' },
            { 'strike-price': '13.0', put: 'F     260320P00013000', 'put-streamer-symbol': '.F260320P13' },
            { 'strike-price': '14.0', put: 'F     260320P00014000', 'put-streamer-symbol': '.F260320P14' },
            { 'strike-price': '15.0', put: 'F     260320P00015000', 'put-streamer-symbol': '.F260320P15' },
          ]
        },
        {
          'expiration-date': (() => {
            const d = new Date();
            d.setDate(d.getDate() + 5);
            return d.toISOString().split('T')[0];
          })(),
          'days-to-expiration': 5,
          strikes: [
            { 'strike-price': '13.0', put: 'F     260220P00013000' },
          ]
        },
      ]
    }]
  };

  it('finds OTM puts within DTE range', () => {
    const candidates = tt.findBestCSP(mockChain, 14, 5000);
    assert.ok(candidates.length > 0);
    // All should be below stock price (OTM)
    candidates.forEach(c => assert.ok(c.strike < 14, `${c.strike} should be < 14`));
  });

  it('filters by cash constraint', () => {
    const candidates = tt.findBestCSP(mockChain, 14, 1200);
    // Max cash $1200 = max strike $12
    candidates.forEach(c => assert.ok(c.cashNeeded <= 1200, `Cash ${c.cashNeeded} should be <= 1200`));
  });

  it('excludes expirations outside DTE range', () => {
    const candidates = tt.findBestCSP(mockChain, 14, 5000);
    // DTE 5 should be excluded (below targetDTE[0] = 20)
    candidates.forEach(c => {
      assert.ok(c.dte >= tt.CONFIG.targetDTE[0], `DTE ${c.dte} should be >= ${tt.CONFIG.targetDTE[0]}`);
      assert.ok(c.dte <= tt.CONFIG.targetDTE[1], `DTE ${c.dte} should be <= ${tt.CONFIG.targetDTE[1]}`);
    });
  });

  it('excludes ITM puts', () => {
    const candidates = tt.findBestCSP(mockChain, 11, 5000);
    // With stock at $11, only $10 put should be OTM
    candidates.forEach(c => assert.ok(c.strike < 11));
  });

  it('returns empty for unaffordable underlyings', () => {
    const candidates = tt.findBestCSP(mockChain, 14, 500);
    // $500 max = max $5 strike, none available
    assert.strictEqual(candidates.length, 0);
  });

  it('sorts by strike descending (closest to ATM first)', () => {
    const candidates = tt.findBestCSP(mockChain, 14, 5000);
    for (let i = 1; i < candidates.length; i++) {
      assert.ok(candidates[i - 1].strike >= candidates[i].strike);
    }
  });
});

describe('findBestCC', () => {
  const mockChain = {
    items: [{
      'underlying-symbol': 'F',
      expirations: [{
        'expiration-date': (() => {
          const d = new Date();
          d.setDate(d.getDate() + 30);
          return d.toISOString().split('T')[0];
        })(),
        'days-to-expiration': 30,
        strikes: [
          { 'strike-price': '13.0', call: 'F     260320C00013000' },
          { 'strike-price': '14.0', call: 'F     260320C00014000' },
          { 'strike-price': '15.0', call: 'F     260320C00015000' },
          { 'strike-price': '16.0', call: 'F     260320C00016000' },
        ]
      }]
    }]
  };

  it('finds OTM calls', () => {
    const candidates = tt.findBestCC(mockChain, 14, 100);
    assert.ok(candidates.length > 0);
    candidates.forEach(c => assert.ok(c.strike > 14));
  });

  it('returns empty with insufficient shares', () => {
    const candidates = tt.findBestCC(mockChain, 14, 50);
    assert.strictEqual(candidates.length, 0);
  });

  it('calculates correct contract count', () => {
    const candidates = tt.findBestCC(mockChain, 14, 300);
    candidates.forEach(c => assert.strictEqual(c.contracts, 3));
  });

  it('sorts by strike ascending (closest to ATM first)', () => {
    const candidates = tt.findBestCC(mockChain, 14, 100);
    for (let i = 1; i < candidates.length; i++) {
      assert.ok(candidates[i - 1].strike <= candidates[i].strike);
    }
  });
});

describe('API integration (sandbox)', () => {
  it('can authenticate', async () => {
    const token = await tt.login();
    assert.ok(token);
    assert.ok(token.length > 10);
  });

  it('can fetch option chain', async () => {
    await tt.login();
    const chain = await tt.getOptionChain('F');
    assert.ok(chain.items);
    assert.ok(chain.items[0].expirations.length > 0);
    assert.strictEqual(chain.items[0]['underlying-symbol'], 'F');
  });

  it('can fetch positions (even if empty)', async () => {
    await tt.login();
    const positions = await tt.getPositions();
    assert.ok(positions); // May be empty array or object
  });
});
