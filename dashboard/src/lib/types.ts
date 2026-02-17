export type Stock = {
	ticker: string;
	name: string;
	price: number;
	ath: number;
	market_cap: number;
	sector: string;
	pct_from_ath: number;
	change_1d: number;
	streak: number;
	rsi: number;
	roc_30d: number;
	rs_vs_qqq: number;
	vol_surge: number;
	pct_vs_50dma: number;
	is_52w_high: boolean | number;
	signal: string;
	ai_assessment: string;
	fair_value: number;
	upside: number;
	rating: string;
	fv_vs_ath: number;
};

export type ScanResult = {
	timestamp: string;
	qqq_30d_return: number;
	total_stocks: number;
	watchlist: Stock[];
	big_drops: Stock[];
	big_gains: Stock[];
	down_streaks: Stock[];
	up_streaks: Stock[];
	parabolic: Stock[];
};

export type TabKey =
	| "watchlist"
	| "big_drops"
	| "big_gains"
	| "down_streaks"
	| "up_streaks"
	| "parabolic";

export type ColumnKey =
	| "ticker"
	| "name"
	| "price"
	| "ath"
	| "pct_from_ath"
	| "fair_value"
	| "upside"
	| "rating"
	| "rsi"
	| "change_1d"
	| "streak"
	| "roc_30d";

export type ColumnDef = {
	key: ColumnKey;
	label: string;
	align: "left" | "right" | "center";
	tooltip?: string;
};
