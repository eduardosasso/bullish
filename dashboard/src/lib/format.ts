import type { ColumnDef, TabKey } from "@/lib/types";

export const formatPrice = (value: number): string => {
	if (value >= 1000)
		return value.toLocaleString("en-US", {
			minimumFractionDigits: 2,
			maximumFractionDigits: 2,
		});

	return value.toFixed(2);
};

export const formatPct = (value: number): string => {
	const sign = value > 0 ? "+" : "";

	return `${sign}${value.toFixed(1)}%`;
};

export const formatMarketCap = (value: number): string => {
	if (value >= 1e12) return `$${(value / 1e12).toFixed(1)}T`;
	if (value >= 1e9) return `$${(value / 1e9).toFixed(1)}B`;

	return `$${(value / 1e6).toFixed(0)}M`;
};

export const pctColor = (value: number): string => {
	if (value > 0) return "text-gain";
	if (value < 0) return "text-loss";

	return "text-text-secondary";
};

export const rsiColor = (value: number): string => {
	if (value < 30) return "text-gain";
	if (value < 50) return "text-caution";
	if (value < 70) return "text-accent";

	return "text-loss";
};

export const ratingColor = (rating: string): string => {
	const r = rating.toLowerCase();
	if (r === "strong_buy" || r === "buy") return "text-gain";
	if (r === "hold") return "text-caution";

	return "text-loss";
};

export const ratingLabel = (rating: string): string => {
	const r = rating.toLowerCase();
	if (r === "strong_buy") return "Buy+";
	if (r === "buy") return "Buy";
	if (r === "hold") return "Hold";
	if (r === "sell") return "Sell";
	if (r === "strong_sell") return "Sell-";

	return rating;
};

export const assessmentSignal = (assessment: string): string => {
	const upper = assessment.toUpperCase();
	if (upper.startsWith("BUY")) return "BUY";
	if (upper.startsWith("WAIT")) return "WAIT";
	if (upper.startsWith("PASS")) return "PASS";

	return "PASS";
};

export const assessmentBadgeClasses = (signal: string): string => {
	if (signal === "BUY") return "bg-green-500/15 text-green-400";
	if (signal === "WAIT") return "bg-amber-500/15 text-amber-400";

	return "bg-slate-500/15 text-slate-400";
};

export const TABS_WITH_AI: TabKey[] = [
	"watchlist",
	"big_drops",
	"down_streaks",
];

const COLUMN_TOOLTIPS: Record<string, string> = {
	ath: "All-Time High: The highest price the stock has ever reached",
	pct_from_ath:
		"% from ATH: How far below the all-time high. More negative = bigger discount from peak",
	fair_value:
		"Fair Value: Analyst consensus target price based on fundamentals",
	upside:
		"% to FV: Potential upside if stock reaches fair value. Higher = more undervalued",
	rsi: "RSI (14): Momentum indicator. <30 = oversold (bullish), >70 = overbought (bearish)",
	rating:
		"Analyst Rating: Wall Street consensus. Buy+ = Strong Buy, Buy, Hold, Sell, Sell- = Strong Sell",
	change_1d: "1-Day Change: Today's price movement percentage",
	streak:
		"Streak: Consecutive days up (+) or down (-). Longer streaks may signal reversal",
	roc_30d:
		"30-Day ROC: Rate of change over 30 days. High values indicate parabolic momentum",
};

export const TAB_CONFIG: Record<
	TabKey,
	{ label: string; columns: ColumnDef[] }
> = {
	watchlist: {
		label: "Watchlist",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "ath",
				label: "ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.ath,
			},
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
	big_drops: {
		label: "Big Drops",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "change_1d",
				label: "1d%",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.change_1d,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
	big_gains: {
		label: "Big Gains",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "change_1d",
				label: "1d%",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.change_1d,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
	down_streaks: {
		label: "Down Streaks",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "streak",
				label: "Streak",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.streak,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
	up_streaks: {
		label: "Up Streaks",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "streak",
				label: "Streak",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.streak,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
	parabolic: {
		label: "Parabolic",
		columns: [
			{ key: "ticker", label: "Ticker", align: "left" },
			{ key: "name", label: "Name", align: "left" },
			{ key: "price", label: "Price", align: "right" },
			{
				key: "pct_from_ath",
				label: "%ATH",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.pct_from_ath,
			},
			{
				key: "roc_30d",
				label: "30d%",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.roc_30d,
			},
			{
				key: "fair_value",
				label: "FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.fair_value,
			},
			{
				key: "upside",
				label: "%FV",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.upside,
			},
			{
				key: "rating",
				label: "Rating",
				align: "center",
				tooltip: COLUMN_TOOLTIPS.rating,
			},
			{
				key: "rsi",
				label: "RSI",
				align: "right",
				tooltip: COLUMN_TOOLTIPS.rsi,
			},
		],
	},
};
