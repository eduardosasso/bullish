# Trading — Scan-to-Trade Pipeline

Connects the Bullish stock scanner to Tastytrade for automated wheel strategy execution.

## Architecture

```
scan.py (Python)          →  data/scan_*.json
                               ↓
wheel.js (filter + score) →  Ranked CSP candidates
                               ↓
tastytrade.js (execute)   →  Dry-run / submit orders
```

## Quick Start

```bash
# 1. Run the scanner (from repo root)
python scan.py

# 2. View wheel candidates from latest scan
node trading/wheel.js candidates

# 3. Enrich with live option chains from Tastytrade
node trading/wheel.js enrich

# 4. Dry-run an order
node trading/wheel.js dryrun TTD

# 5. Full pipeline summary
node trading/wheel.js summary
```

## wheel.js — Scan-to-Trade Bridge

Reads scanner output, filters for wheel-eligible stocks, scores them, and optionally fetches live option chains.

**Scoring criteria:**
- RSI (oversold = higher score)
- Analyst fair value upside
- Rating (strong_buy > buy > hold)
- ATH discount depth
- Down streak (mean reversion)
- AI assessment (BUY > WAIT > PASS)
- Volume surge (institutional interest)

**Hard filters:**
- Price × 100 ≤ $5,000 budget (cash-secured put collateral)
- RSI ≤ 45
- At least 15% below ATH
- Excludes: MSTR, COIN (crypto-adjacent volatility)

**Commands:**
| Command | Description |
|---------|-------------|
| `candidates` | Show ranked candidates from latest scan |
| `enrich` | Candidates + live option chain data |
| `dryrun <TICKER>` | Dry-run best CSP order via Tastytrade |
| `execute <TICKER> --confirm` | Submit order (requires confirmation flag) |
| `positions` | Show current positions & live orders |
| `summary` | Full pipeline: scan → filter → enrich → positions |

**Flags:** `--scan FILE`, `--top N`, `--json`

## tastytrade.js — API Client

Direct Tastytrade API client for the wheel strategy.

```bash
node trading/tastytrade.js status     # Account overview
node trading/tastytrade.js scan F SOFI # Scan specific tickers
node trading/tastytrade.js login      # Test auth
```

## Tests

```bash
node --test trading/wheel.test.js      # 14 tests — scoring, filtering, real data
node --test trading/tastytrade.test.js # 24 tests — API, orders, option symbols
```

## Config

Edit `CONFIG` in `tastytrade.js`:
- `maxPositionSize`: Max cash collateral (default $5,000)
- `targetDTE`: Days to expiration range (default 20-45)
- `targetDelta`: Delta range for OTM puts (default -0.30 to -0.20)
- `sandbox`: Toggle sandbox/production

Edit `WHEEL_CRITERIA` in `wheel.js`:
- `maxPrice`, `maxRSI`, `minATHDrop`: Hard filters
- `preferredRatings`, `excludeTickers`: Soft preferences
