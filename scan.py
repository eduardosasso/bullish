#!/usr/bin/env python3
"""
Bullish - Momentum & Mean Reversion Scanner for Tech Stocks

Dynamically discovers tech stocks from S&P 500 and NASDAQ-100.
Scans for:
1. Stocks 20%+ below all-time high (position entry candidates)
2. Parabolic breakouts (momentum rides)
3. Tracks consecutive up/down day streaks
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from dataclasses import dataclass, asdict, field
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from io import StringIO
from pathlib import Path

import numpy as np
import pandas as pd
import requests
import yfinance as yf
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.text import Text
from rich import box

console = Console()

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
}

# Configuration
MIN_MARKET_CAP = 2_000_000_000
MIN_AVG_VOLUME = 500_000
MIN_PRICE = 10
ATH_THRESHOLD = -20

TECH_SECTORS = {
    "Technology",
    "Communication Services",
    "Consumer Cyclical",
}


@dataclass
class Stock:
    ticker: str
    name: str
    price: float
    ath: float
    market_cap: float
    sector: str
    pct_from_ath: float
    change_1d: float
    streak: int
    rsi: float
    roc_30d: float
    rs_vs_qqq: float
    vol_surge: float
    pct_vs_50dma: float
    is_52w_high: bool
    signal: str = ""
    ai_assessment: str = ""
    fair_value: float = 0.0
    upside: float = 0.0
    rating: str = ""
    fv_vs_ath: float = 0.0


@dataclass
class ScanResult:
    timestamp: str
    qqq_30d_return: float
    total_stocks: int
    watchlist: list[Stock]
    big_drops: list[Stock]
    big_gains: list[Stock]
    down_streaks: list[Stock]
    up_streaks: list[Stock]
    parabolic: list[Stock]


def fetch_sp500_tickers() -> list[str]:
    url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
    response = requests.get(url, headers=HEADERS)
    tables = pd.read_html(StringIO(response.text))
    df = tables[0]

    return df["Symbol"].str.replace(".", "-", regex=False).tolist()


def fetch_nasdaq100_tickers() -> list[str]:
    url = "https://en.wikipedia.org/wiki/Nasdaq-100"
    response = requests.get(url, headers=HEADERS)
    tables = pd.read_html(StringIO(response.text))
    for table in tables:
        if "Ticker" in table.columns:
            return table["Ticker"].tolist()
        if "Symbol" in table.columns:
            return table["Symbol"].tolist()

    return []


def get_dynamic_universe() -> list[str]:
    console.print("[dim]Fetching S&P 500 components...[/dim]")
    sp500 = fetch_sp500_tickers()
    console.print(f"[dim]  Found {len(sp500)} S&P 500 stocks[/dim]")

    console.print("[dim]Fetching NASDAQ-100 components...[/dim]")
    ndx = fetch_nasdaq100_tickers()
    console.print(f"[dim]  Found {len(ndx)} NASDAQ-100 stocks[/dim]")

    universe = list(set(sp500 + ndx))
    console.print(f"[dim]  Combined universe: {len(universe)} unique tickers[/dim]\n")

    return universe


def calculate_rsi(prices: pd.Series, period: int = 14) -> float:
    delta = prices.diff()
    gain = delta.where(delta > 0, 0).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    rsi = 100 - (100 / (1 + rs))

    return rsi.iloc[-1] if not rsi.empty else 50


def calculate_streak(prices: pd.Series) -> int:
    if len(prices) < 2:
        return 0

    daily_returns = prices.pct_change().dropna()
    if daily_returns.empty:
        return 0

    streak = 0
    direction = None

    for ret in reversed(daily_returns.values):
        if direction is None:
            direction = 1 if ret > 0 else -1
            streak = direction
        elif (ret > 0 and direction > 0) or (ret < 0 and direction < 0):
            streak += direction
        else:
            break

    return streak


def rsi_signal(rsi: float) -> str:
    if rsi < 30:
        return "[bold green]BUY[/bold green]"
    elif rsi < 40:
        return "[bold #ff5555]WATCH[/bold #ff5555]"
    elif rsi > 70:
        return "[bold #ff5555]SELL[/bold #ff5555]"

    return "[dim]-[/dim]"


def rsi_signal_plain(rsi: float) -> str:
    if rsi < 30:
        return "BUY"
    elif rsi < 40:
        return "WATCH"
    elif rsi > 70:
        return "SELL"

    return "-"


def analyze_stock(ticker: str, qqq_returns_30d: float) -> Stock | None:
    try:
        stock = yf.Ticker(ticker)
        info = stock.info

        sector = info.get("sector", "")
        if sector not in TECH_SECTORS:
            return None

        market_cap = info.get("marketCap", 0)
        avg_volume = info.get("averageVolume", 0)
        current_price = info.get("currentPrice") or info.get("regularMarketPrice", 0)
        name = info.get("shortName", ticker)

        if market_cap < MIN_MARKET_CAP:
            return None
        if avg_volume < MIN_AVG_VOLUME:
            return None
        if current_price < MIN_PRICE:
            return None

        hist = stock.history(period="1y")
        if hist.empty or len(hist) < 30:
            return None

        close = hist["Close"]
        volume = hist["Volume"]

        ath = close.max()
        pct_from_ath = ((current_price - ath) / ath) * 100
        high_52w = close.max()
        rsi = calculate_rsi(close)
        streak = calculate_streak(close)

        if len(close) >= 2:
            prev_close = close.iloc[-2]
            change_1d = ((current_price - prev_close) / prev_close) * 100
        else:
            change_1d = 0

        if len(close) >= 30:
            price_30d_ago = close.iloc[-30]
            roc_30d = ((current_price - price_30d_ago) / price_30d_ago) * 100
        else:
            roc_30d = 0

        rs_vs_qqq = roc_30d - qqq_returns_30d

        recent_vol = volume.iloc[-1]
        avg_vol_20d = volume.iloc[-20:].mean()
        vol_surge = recent_vol / avg_vol_20d if avg_vol_20d > 0 else 1

        if len(close) >= 50:
            ma_50 = close.iloc[-50:].mean()
            pct_vs_50dma = ((current_price - ma_50) / ma_50) * 100
        else:
            pct_vs_50dma = 0

        fair_value = info.get("targetMeanPrice", 0) or 0
        rating = info.get("recommendationKey", "") or ""
        upside = ((fair_value - current_price) / current_price) * 100 if fair_value and current_price else 0.0
        fv_vs_ath = ((fair_value - ath) / ath) * 100 if fair_value and ath else 0.0

        return Stock(
            ticker=ticker,
            name=name[:25],
            price=current_price,
            ath=ath,
            market_cap=market_cap,
            sector=sector,
            pct_from_ath=pct_from_ath,
            change_1d=change_1d,
            streak=streak,
            rsi=rsi,
            roc_30d=roc_30d,
            rs_vs_qqq=rs_vs_qqq,
            vol_surge=vol_surge,
            pct_vs_50dma=pct_vs_50dma,
            is_52w_high=current_price >= high_52w * 0.98,
            signal=rsi_signal_plain(rsi),
            fair_value=fair_value,
            upside=upside,
            rating=rating,
            fv_vs_ath=fv_vs_ath,
        )

    except Exception:
        return None


def get_qqq_30d_return() -> float:
    try:
        qqq = yf.Ticker("QQQ")
        hist = qqq.history(period="60d")
        if len(hist) >= 30:
            return ((hist["Close"].iloc[-1] - hist["Close"].iloc[-30]) / hist["Close"].iloc[-30]) * 100
    except Exception:
        pass

    return 0


def get_ai_assessment(stocks: list[Stock]) -> dict[str, str]:
    if not stocks:
        return {}

    stock_summaries = []
    for s in stocks:
        fv_part = f", analyst FV ${s.fair_value:.0f} ({s.upside:+.0f}%)" if s.fair_value else ""
        rating_part = f", rating {s.rating.upper()}" if s.rating else ""
        summary = (
            f"{s.ticker} ({s.name}): "
            f"Price ${s.price:.0f}, ATH ${s.ath:.0f} ({s.pct_from_ath:+.1f}%), "
            f"1d change {s.change_1d:+.1f}%, streak {s.streak} days, 30d return {s.roc_30d:+.1f}%"
            f"{fv_part}{rating_part}"
        )
        stock_summaries.append(summary)

    prompt = f"""You are a direct stock analyst. Search for latest news on these stocks, then give a ONE LINE verdict (max 100 chars).

RULES:
- Start with BUY, WAIT, or PASS
- State the KEY catalyst or risk in plain English
- NO URLs, links, or markdown formatting
- NO vague statements - be specific about WHY

GOOD examples:
"BUY - Cloud revenue up 40% YoY, AI integrations driving enterprise deals"
"PASS - Payroll processing facing AI automation threat; defensive but no growth catalyst"
"WAIT - Strong earnings but China exposure risk with new tariffs pending"

BAD examples (never do this):
"BUY - [Link](url) shows strong performance"
"WAIT - Stock is volatile"
"PASS - Concerns about outlook"

Stocks:
{chr(10).join(stock_summaries)}

Format: TICKER: [BUY/WAIT/PASS] - specific catalyst or risk"""

    try:
        result = subprocess.run(
            ["claude", "-p", prompt, "--model", "sonnet", "--allowedTools", "mcp__fetch__fetch,WebSearch"],
            capture_output=True,
            text=True,
            timeout=180
        )

        if result.returncode != 0:
            return {s.ticker: f"CLI error: {result.stderr[:40]}" for s in stocks}

        assessments = {}
        text = result.stdout
        tickers = [s.ticker.upper() for s in stocks]

        for line in text.strip().split("\n"):
            line = line.strip()
            if not line:
                continue

            for ticker in tickers:
                if ticker in line.upper():
                    idx = line.upper().find(ticker)
                    assessment = line[idx + len(ticker):].lstrip(":*-() ").strip()
                    if assessment and len(assessment) > 5:
                        assessments[ticker] = assessment[:120]
                    break

        if not assessments and text.strip():
            first_line = text.strip().split("\n")[0][:60]
            return {s.ticker: f"Parse failed. Raw: {first_line}..." for s in stocks}

        return assessments

    except FileNotFoundError:
        return {s.ticker: "claude CLI not found" for s in stocks}
    except subprocess.TimeoutExpired:
        return {s.ticker: "AI request timed out" for s in stocks}
    except Exception as e:
        return {s.ticker: f"AI error: {str(e)[:40]}" for s in stocks}


def format_streak(streak: int) -> str:
    if streak > 0:
        return f"[bold green]↑{streak}[/bold green]"
    elif streak < 0:
        return f"[bold red]↓{abs(streak)}[/bold red]"

    return "[dim]—[/dim]"


def format_pct(value: float, invert: bool = False) -> str:
    color = "red" if (value < 0) != invert else "green"

    return f"[bold {color}]{value:+.1f}%[/bold {color}]"


def format_price(value: float) -> str:
    return f"[bold]${value:,.0f}[/bold]"


def format_rsi(rsi: float) -> str:
    if rsi < 30:
        return f"[bold green]{rsi:.0f}[/bold green]"
    elif rsi < 40:
        return f"[bold yellow]{rsi:.0f}[/bold yellow]"
    elif rsi > 70:
        return f"[bold red]{rsi:.0f}[/bold red]"

    return f"[white]{rsi:.0f}[/white]"


def format_upside(value: float) -> str:
    if value == 0:
        return "[dim]—[/dim]"
    color = "green" if value > 0 else "red"

    return f"[bold {color}]{value:+.0f}%[/bold {color}]"


def format_rating(rating: str) -> str:
    r = rating.lower()
    if r in ("buy", "strong_buy", "strongbuy"):
        return f"[bold green]{rating.upper()}[/bold green]"
    elif r in ("hold", "neutral"):
        return f"[bold yellow]{rating.upper()}[/bold yellow]"
    elif r in ("sell", "strong_sell", "strongsell", "underperform"):
        return f"[bold red]{rating.upper()}[/bold red]"
    elif rating:
        return f"[dim]{rating.upper()}[/dim]"

    return "[dim]—[/dim]"


def build_row(stock: Stock, columns: list[tuple]) -> list[str]:
    row = []
    for col_name, _ in columns:
        if col_name == "Ticker":
            row.append(f"[bold white]{stock.ticker}[/bold white]")
        elif col_name == "Name":
            row.append(f"[dim]{stock.name[:20]}[/dim]")
        elif col_name == "Price":
            row.append(format_price(stock.price))
        elif col_name == "ATH":
            row.append(f"[dim]${stock.ath:,.0f}[/dim]")
        elif col_name == "%ATH":
            row.append(format_pct(stock.pct_from_ath))
        elif col_name == "1d%":
            row.append(format_pct(stock.change_1d))
        elif col_name == "30d%":
            row.append(format_pct(stock.roc_30d))
        elif col_name == "Streak":
            row.append(format_streak(stock.streak))
        elif col_name == "RSI":
            row.append(format_rsi(stock.rsi))
        elif col_name == "Signal":
            row.append(rsi_signal(stock.rsi))
        elif col_name == "Vol":
            color = "green" if stock.vol_surge > 1.5 else "dim"
            row.append(f"[{color}]{stock.vol_surge:.1f}x[/{color}]")
        elif col_name == "FV":
            row.append(format_price(stock.fair_value) if stock.fair_value else "[dim]—[/dim]")
        elif col_name == "%FV":
            row.append(format_upside(stock.upside))
        elif col_name == "FV%ATH":
            row.append(format_upside(stock.fv_vs_ath))
        elif col_name == "Rating":
            row.append(format_rating(stock.rating))
        elif col_name == "52wH":
            row.append("[bold green]YES[/bold green]" if stock.is_52w_high else "")

    return row


def build_ai_text(ai: str) -> Text:
    ai_text = Text("└ ", style="dim")
    ai_upper = ai.upper()
    if ai_upper.startswith("BUY"):
        ai_text.append("BUY", style="bold green")
        ai_text.append(ai[3:], style="italic dim")
    elif ai_upper.startswith("SELL"):
        ai_text.append("SELL", style="bold #ff5555")
        ai_text.append(ai[4:], style="italic dim")
    elif ai_upper.startswith("WAIT"):
        ai_text.append("WAIT", style="bold #ff5555")
        ai_text.append(ai[4:], style="italic dim")
    elif ai_upper.startswith("PASS"):
        ai_text.append("PASS", style="bold #ff5555")
        ai_text.append(ai[4:], style="italic dim")
    else:
        ai_text.append(ai, style="italic dim")

    return ai_text


def render_table_with_ai(title: str, stocks: list[Stock], columns: list[tuple], ai_assessments: dict[str, str]) -> None:
    if not stocks:
        console.print(f"\n[dim]No stocks in {title}[/dim]")
        return

    table = Table(
        title=title,
        box=box.ROUNDED,
        show_header=True,
        header_style="bold cyan",
        expand=True,
        title_style="bold white",
    )

    right_justify = {"Price", "ATH", "%ATH", "1d%", "30d%", "RSI", "Streak", "Vol", "FV", "%FV", "FV%ATH"}
    for col_name, col_width in columns:
        justify = "right" if col_name in right_justify else "left"
        table.add_column(col_name, min_width=col_width, no_wrap=True, justify=justify)

    for stock in stocks:
        row = build_row(stock, columns)
        table.add_row(*row)

    console.print(table)

    for stock in stocks:
        ai = ai_assessments.get(stock.ticker, "")
        if ai:
            ai_text = Text(f"  {stock.ticker} ", style="bold white")
            ai_text.append_text(build_ai_text(ai))
            console.print(ai_text)


def render_table_simple(title: str, stocks: list[Stock], columns: list[tuple]) -> None:
    if not stocks:
        console.print(f"\n[dim]No stocks in {title}[/dim]")
        return

    table = Table(
        title=title,
        box=box.ROUNDED,
        show_header=True,
        header_style="bold cyan",
        expand=True,
        title_style="bold white",
    )

    right_justify = {"Price", "ATH", "%ATH", "1d%", "30d%", "RSI", "Streak", "Vol", "FV", "%FV", "FV%ATH"}
    for col_name, col_width in columns:
        justify = "right" if col_name in right_justify else "left"
        table.add_column(col_name, min_width=col_width, no_wrap=True, justify=justify)

    for stock in stocks:
        row = build_row(stock, columns)
        table.add_row(*row)

    console.print(table)


def load_results(json_path: Path) -> ScanResult:
    """Load scan results from a JSON file."""
    with open(json_path) as f:
        data = json.load(f)

    return ScanResult(
        timestamp=data["timestamp"],
        qqq_30d_return=data["qqq_30d_return"],
        total_stocks=data["total_stocks"],
        watchlist=[Stock(**s) for s in data["watchlist"]],
        big_drops=[Stock(**s) for s in data["big_drops"]],
        big_gains=[Stock(**s) for s in data["big_gains"]],
        down_streaks=[Stock(**s) for s in data["down_streaks"]],
        up_streaks=[Stock(**s) for s in data["up_streaks"]],
        parabolic=[Stock(**s) for s in data["parabolic"]],
    )


def get_latest_scan(output_dir: Path) -> Path | None:
    """Get the most recent scan JSON file."""
    json_files = sorted(output_dir.glob("scan_*.json"), reverse=True)

    return json_files[0] if json_files else None


def convert_to_json_serializable(obj):
    """Convert numpy types to Python native types for JSON serialization."""
    if isinstance(obj, dict):
        return {k: convert_to_json_serializable(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_to_json_serializable(item) for item in obj]
    elif isinstance(obj, (np.bool_, np.integer)):
        return int(obj)
    elif isinstance(obj, np.floating):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()

    return obj


def save_results(result: ScanResult, output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")

    # Save JSON
    json_path = output_dir / f"scan_{timestamp}.json"
    data = {
        "timestamp": result.timestamp,
        "qqq_30d_return": result.qqq_30d_return,
        "total_stocks": result.total_stocks,
        "watchlist": [convert_to_json_serializable(asdict(s)) for s in result.watchlist],
        "big_drops": [convert_to_json_serializable(asdict(s)) for s in result.big_drops],
        "big_gains": [convert_to_json_serializable(asdict(s)) for s in result.big_gains],
        "down_streaks": [convert_to_json_serializable(asdict(s)) for s in result.down_streaks],
        "up_streaks": [convert_to_json_serializable(asdict(s)) for s in result.up_streaks],
        "parabolic": [convert_to_json_serializable(asdict(s)) for s in result.parabolic],
    }
    with open(json_path, "w") as f:
        json.dump(data, f, indent=2)

    # Save CSV for spreadsheet compatibility
    csv_path = output_dir / f"scan_{timestamp}.csv"
    all_stocks = (
        result.watchlist + result.big_drops + result.big_gains +
        result.down_streaks + result.up_streaks + result.parabolic
    )
    # Deduplicate
    seen = set()
    unique_stocks = []
    for s in all_stocks:
        if s.ticker not in seen:
            seen.add(s.ticker)
            unique_stocks.append(s)

    df = pd.DataFrame([asdict(s) for s in unique_stocks])
    df.to_csv(csv_path, index=False)

    return json_path, csv_path


def scan(skip_ai: bool = False) -> ScanResult:
    console.print(Panel.fit(
        f"[bold cyan]BULLISH SCANNER[/bold cyan]\n[dim]{datetime.now().strftime('%Y-%m-%d %H:%M')}[/dim]",
        border_style="cyan"
    ))

    universe = get_dynamic_universe()

    console.print("[dim]Fetching QQQ benchmark...[/dim]")
    qqq_30d = get_qqq_30d_return()
    console.print(f"[dim]QQQ 30-day return: {qqq_30d:+.1f}%[/dim]\n")

    results: list[Stock] = []

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("[cyan]Analyzing stocks...", total=len(universe))

        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = {executor.submit(analyze_stock, ticker, qqq_30d): ticker for ticker in universe}

            for future in as_completed(futures):
                progress.advance(task)
                result = future.result()
                if result:
                    results.append(result)

    console.print(f"\n[green]Found {len(results)} tech stocks matching criteria[/green]\n")

    if not results:
        console.print("[red]No stocks matched the criteria.[/red]")
        return ScanResult(
            timestamp=datetime.now().isoformat(),
            qqq_30d_return=qqq_30d,
            total_stocks=0,
            watchlist=[],
            big_drops=[],
            big_gains=[],
            down_streaks=[],
            up_streaks=[],
            parabolic=[],
        )

    # Categorize stocks
    watchlist = sorted([s for s in results if s.pct_from_ath <= ATH_THRESHOLD], key=lambda x: x.pct_from_ath)
    big_drops = sorted([s for s in results if s.change_1d <= -5], key=lambda x: x.change_1d)
    big_gains = sorted([s for s in results if s.change_1d >= 5], key=lambda x: -x.change_1d)
    down_streaks = sorted([s for s in results if s.streak < -2], key=lambda x: x.streak)[:15]
    up_streaks = sorted([s for s in results if s.streak > 2], key=lambda x: -x.streak)[:15]
    parabolic = sorted([s for s in results if s.roc_30d > 15 and s.rsi > 55], key=lambda x: -x.roc_30d)

    # Get AI assessments for key sections
    ai_assessments = {}
    if not skip_ai:
        ai_candidates = list({s.ticker: s for s in (watchlist + big_drops + down_streaks)}.values())

        if ai_candidates:
            with console.status("[bold cyan]Fetching AI analysis...[/bold cyan]"):
                ai_assessments = get_ai_assessment(ai_candidates)

            # Update stocks with AI assessments
            for stock in watchlist + big_drops + down_streaks:
                stock.ai_assessment = ai_assessments.get(stock.ticker, "")

    # Render tables
    watchlist_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("ATH", 7), ("%ATH", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("📉 WATCHLIST - 20%+ Below ATH", watchlist, watchlist_cols, ai_assessments)

    console.print()
    drops_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("1d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("🔻 BIG DROPS - Down 5%+ Today", big_drops, drops_cols, ai_assessments)

    console.print()
    gains_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("1d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🔺 BIG GAINS - Up 5%+ Today", big_gains, gains_cols)

    console.print()
    down_streak_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("Streak", 6), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("🔴 DOWN STREAKS - 3+ Days", down_streaks, down_streak_cols, ai_assessments)

    console.print()
    up_streak_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("Streak", 6), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🟢 UP STREAKS - 3+ Days", up_streaks, up_streak_cols)

    console.print()
    parabolic_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("30d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🚀 PARABOLIC - Strong Momentum", parabolic, parabolic_cols)

    # Summary
    buy_signals = len([s for s in results if s.rsi < 30])
    watch_signals = len([s for s in results if 30 <= s.rsi < 40])

    summary = Table(title="📈 SUMMARY", box=box.ROUNDED, show_header=False, expand=True, title_style="bold white")
    summary.add_column("Metric", style="dim", ratio=1)
    summary.add_column("Value", style="bold", justify="right", ratio=1)

    summary.add_row("Total tech stocks", str(len(results)))
    summary.add_row("RSI < 30 (BUY)", f"[green]{buy_signals}[/green]")
    summary.add_row("RSI 30-40 (WATCH)", f"[yellow]{watch_signals}[/yellow]")
    summary.add_row("20%+ below ATH", str(len(watchlist)))
    summary.add_row("Big drops today", str(len(big_drops)))
    summary.add_row("Big gains today", str(len(big_gains)))
    summary.add_row("Down streaks", str(len(down_streaks)))
    summary.add_row("Up streaks", str(len(up_streaks)))

    console.print()
    console.print(summary)

    # Create result object
    scan_result = ScanResult(
        timestamp=datetime.now().isoformat(),
        qqq_30d_return=qqq_30d,
        total_stocks=len(results),
        watchlist=watchlist,
        big_drops=big_drops,
        big_gains=big_gains,
        down_streaks=down_streaks,
        up_streaks=up_streaks,
        parabolic=parabolic,
    )

    # Save results
    output_dir = Path("data")
    json_path, csv_path = save_results(scan_result, output_dir)
    console.print(f"\n[dim]Results saved to:[/dim]")
    console.print(f"  [dim]JSON: {json_path}[/dim]")
    console.print(f"  [dim]CSV:  {csv_path}[/dim]")

    return scan_result


def render(result: ScanResult) -> None:
    """Render scan results to the console."""
    console.print(Panel.fit(
        f"[bold cyan]BULLISH SCANNER[/bold cyan]\n[dim]{result.timestamp}[/dim]",
        border_style="cyan"
    ))

    console.print(f"[dim]QQQ 30-day return: {result.qqq_30d_return:+.1f}%[/dim]")
    console.print(f"[green]Loaded {result.total_stocks} tech stocks[/green]\n")

    # Build AI assessments dict from loaded data
    ai_assessments = {}
    for stock in result.watchlist + result.big_drops + result.down_streaks:
        if stock.ai_assessment:
            ai_assessments[stock.ticker] = stock.ai_assessment

    # Render tables
    watchlist_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("ATH", 7), ("%ATH", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("📉 WATCHLIST - 20%+ Below ATH", result.watchlist, watchlist_cols, ai_assessments)

    console.print()
    drops_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("1d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("🔻 BIG DROPS - Down 5%+ Today", result.big_drops, drops_cols, ai_assessments)

    console.print()
    gains_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("1d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🔺 BIG GAINS - Up 5%+ Today", result.big_gains, gains_cols)

    console.print()
    down_streak_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("Streak", 6), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_with_ai("🔴 DOWN STREAKS - 3+ Days", result.down_streaks, down_streak_cols, ai_assessments)

    console.print()
    up_streak_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("Streak", 6), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🟢 UP STREAKS - 3+ Days", result.up_streaks, up_streak_cols)

    console.print()
    parabolic_cols = [("Ticker", 6), ("Name", 18), ("Price", 7), ("%ATH", 8), ("30d%", 8), ("FV", 7), ("%FV", 5), ("FV%ATH", 6), ("Rating", 6), ("RSI", 4), ("Signal", 6)]
    render_table_simple("🚀 PARABOLIC - Strong Momentum", result.parabolic, parabolic_cols)

    # Summary
    all_stocks_count = result.total_stocks
    buy_signals = len([s for s in result.watchlist + result.big_drops + result.down_streaks if s.rsi < 30])
    watch_signals = len([s for s in result.watchlist + result.big_drops + result.down_streaks if 30 <= s.rsi < 40])

    summary = Table(title="📈 SUMMARY", box=box.ROUNDED, show_header=False, expand=True, title_style="bold white")
    summary.add_column("Metric", style="dim", ratio=1)
    summary.add_column("Value", style="bold", justify="right", ratio=1)

    summary.add_row("Total tech stocks", str(all_stocks_count))
    summary.add_row("RSI < 30 (BUY)", f"[green]{buy_signals}[/green]")
    summary.add_row("RSI 30-40 (WATCH)", f"[yellow]{watch_signals}[/yellow]")
    summary.add_row("20%+ below ATH", str(len(result.watchlist)))
    summary.add_row("Big drops today", str(len(result.big_drops)))
    summary.add_row("Big gains today", str(len(result.big_gains)))
    summary.add_row("Down streaks", str(len(result.down_streaks)))
    summary.add_row("Up streaks", str(len(result.up_streaks)))

    console.print()
    console.print(summary)


def main():
    parser = argparse.ArgumentParser(description="Bullish - Tech Stock Scanner")
    parser.add_argument(
        "--load", "-l",
        type=str,
        metavar="FILE",
        nargs="?",
        const="latest",
        help="Load from JSON file instead of scanning. Use 'latest' or omit value for most recent scan."
    )
    parser.add_argument(
        "--no-ai",
        action="store_true",
        help="Skip AI assessment (faster scan)"
    )

    args = parser.parse_args()

    if args.load:
        # Load from file
        if args.load == "latest":
            json_path = get_latest_scan(Path("data"))
            if not json_path:
                console.print("[red]No scan files found in data/[/red]")
                return
            console.print(f"[dim]Loading from: {json_path}[/dim]\n")
        else:
            json_path = Path(args.load)
            if not json_path.exists():
                console.print(f"[red]File not found: {json_path}[/red]")
                return

        result = load_results(json_path)
        render(result)
    else:
        # Fresh scan
        scan(skip_ai=args.no_ai)


if __name__ == "__main__":
    main()
