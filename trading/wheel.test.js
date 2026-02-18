const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const fs = require('fs');

const { scoreStock, filterWheelCandidates, WHEEL_CRITERIA, loadScan, getLatestScan } = require('./wheel');

// --- Mock stock factory ---
function mockStock(overrides = {}) {
  return {
    ticker: 'TEST', name: 'Test Inc', price: 25, ath: 50,
    market_cap: 5e9, sector: 'Technology', pct_from_ath: -50,
    change_1d: -3, streak: -4, rsi: 28, roc_30d: -15,
    rs_vs_qqq: -10, vol_surge: 1.2, pct_vs_50dma: -12,
    is_52w_high: false, signal: 'BUY', ai_assessment: 'BUY - strong catalyst',
    fair_value: 40, upside: 60, rating: 'buy', fv_vs_ath: -20,
    ...overrides,
  };
}

function mockScan(stocks = []) {
  return {
    timestamp: '2026-02-05T10:00:00',
    qqq_30d_return: 2.5,
    total_stocks: stocks.length,
    watchlist: stocks,
    big_drops: [],
    big_gains: [],
    down_streaks: [],
    up_streaks: [],
    parabolic: [],
  };
}

// --- Score Tests ---
describe('scoreStock', () => {
  it('scores oversold + buy-rated + deep discount high', () => {
    const s = mockStock({ rsi: 25, rating: 'strong_buy', pct_from_ath: -55, upside: 60, streak: -4, ai_assessment: 'BUY - catalyst' });
    const score = scoreStock(s);
    assert.ok(score >= 90, `Expected >=90, got ${score}`);
  });

  it('scores neutral stock low', () => {
    const s = mockStock({ rsi: 50, rating: 'hold', pct_from_ath: -10, upside: 5, streak: 0, ai_assessment: '' });
    const score = scoreStock(s);
    assert.ok(score < 20, `Expected <20, got ${score}`);
  });

  it('penalizes PASS AI assessment', () => {
    const withBuy = scoreStock(mockStock({ ai_assessment: 'BUY - good' }));
    const withPass = scoreStock(mockStock({ ai_assessment: 'PASS - avoid' }));
    assert.ok(withBuy > withPass, 'BUY should score higher than PASS');
  });

  it('rewards down streaks', () => {
    const streak = scoreStock(mockStock({ streak: -5 }));
    const flat = scoreStock(mockStock({ streak: 0 }));
    assert.ok(streak > flat, 'Down streak should score higher');
  });

  it('rewards volume surge', () => {
    const surge = scoreStock(mockStock({ vol_surge: 3.0 }));
    const normal = scoreStock(mockStock({ vol_surge: 1.0 }));
    assert.ok(surge > normal, 'Volume surge should score higher');
  });
});

// --- Filter Tests ---
describe('filterWheelCandidates', () => {
  it('excludes stocks above max price', () => {
    const scan = mockScan([mockStock({ ticker: 'EXPENSIVE', price: 60 })]);
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 0);
  });

  it('excludes high RSI stocks', () => {
    const scan = mockScan([mockStock({ ticker: 'OVERBOUGHT', rsi: 70 })]);
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 0);
  });

  it('excludes stocks not far enough from ATH', () => {
    const scan = mockScan([mockStock({ ticker: 'NEAR_ATH', pct_from_ath: -5 })]);
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 0);
  });

  it('excludes blacklisted tickers', () => {
    const scan = mockScan([mockStock({ ticker: 'MSTR' }), mockStock({ ticker: 'COIN' })]);
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 0);
  });

  it('passes valid candidate', () => {
    const scan = mockScan([mockStock()]);
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 1);
    assert.equal(result[0].ticker, 'TEST');
    assert.ok(result[0].wheelScore > 0);
  });

  it('deduplicates across categories', () => {
    const stock = mockStock({ ticker: 'DUP' });
    const scan = {
      ...mockScan(),
      watchlist: [stock],
      big_drops: [stock],
      down_streaks: [stock],
    };
    const result = filterWheelCandidates(scan);
    assert.equal(result.length, 1);
  });

  it('sorts by score descending', () => {
    const scan = mockScan([
      mockStock({ ticker: 'LOW', rsi: 44, rating: 'hold', pct_from_ath: -16, upside: 5, streak: 0, ai_assessment: '' }),
      mockStock({ ticker: 'HIGH', rsi: 20, rating: 'strong_buy', pct_from_ath: -60, upside: 80, streak: -5, ai_assessment: 'BUY' }),
    ]);
    const result = filterWheelCandidates(scan);
    assert.equal(result[0].ticker, 'HIGH');
  });
});

// --- Real Scan Data Test ---
describe('real scan data', () => {
  it('loads latest scan file', () => {
    const dataDir = path.join(__dirname, '..', 'data');
    if (!fs.existsSync(dataDir)) return; // skip if no data

    const file = getLatestScan(dataDir);
    const scan = loadScan(file);
    assert.ok(scan.total_stocks > 0);
    assert.ok(scan.watchlist.length > 0);
  });

  it('produces candidates from real data', () => {
    const dataDir = path.join(__dirname, '..', 'data');
    if (!fs.existsSync(dataDir)) return;

    const scan = loadScan(getLatestScan(dataDir));
    const candidates = filterWheelCandidates(scan);
    assert.ok(candidates.length > 0, 'Should find at least one candidate');
    assert.ok(candidates[0].wheelScore > candidates[candidates.length - 1].wheelScore, 'Should be sorted by score');
  });
});
