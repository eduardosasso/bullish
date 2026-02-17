# Trading Bot — Wheel Strategy

Automated options income via the wheel strategy (cash-secured puts → covered calls) on Tastytrade.

## Setup

```bash
node tastytrade.js status    # Check account status
node tastytrade.js scan F SOFI INTC  # Scan for CSP candidates
node tastytrade.js login     # Test authentication
```

## Strategy

1. **Scan** for stocks with options priced within our cash budget ($5K)
2. **Sell cash-secured puts** (OTM, 20-45 DTE, ~0.20-0.30 delta)
3. If assigned → **sell covered calls** on the shares
4. If expired → collect premium, repeat

## Config

Edit `CONFIG` in `tastytrade.js`:
- `maxPositionSize`: Max cash to deploy (default $5,000)
- `targetDTE`: Days to expiration range (default 20-45)
- `targetDelta`: Delta range for OTM puts (default -0.30 to -0.20)
- `sandbox`: Toggle between sandbox and production

## API

- **Sandbox:** https://api.cert.tastyworks.com
- **Production:** https://api.tastyworks.com
- **Docs:** https://developer.tastytrade.com
