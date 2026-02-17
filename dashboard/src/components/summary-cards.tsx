import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatPct, pctColor } from "@/lib/format";
import type { ScanResult } from "@/lib/types";

type SummaryCardsProps = {
	scan: ScanResult;
};

type StatDef = {
	label: string;
	value: string | number;
	colorClass?: string;
};

export const SummaryCards = ({ scan }: SummaryCardsProps) => {
	const stats: StatDef[] = [
		{ label: "Total Stocks", value: scan.total_stocks },
		{ label: "Watchlist", value: scan.watchlist.length },
		{ label: "Big Drops", value: scan.big_drops.length },
		{ label: "Big Gains", value: scan.big_gains.length },
		{ label: "Down Streaks", value: scan.down_streaks.length },
		{ label: "Up Streaks", value: scan.up_streaks.length },
		{ label: "Parabolic", value: scan.parabolic.length },
		{
			label: "QQQ 30d",
			value: formatPct(scan.qqq_30d_return),
			colorClass: pctColor(scan.qqq_30d_return),
		},
	];

	return (
		<div className="grid grid-cols-2 gap-4 md:grid-cols-4 lg:grid-cols-8">
			{stats.map((stat) => (
				<Card key={stat.label}>
					<CardHeader>
						<CardTitle>{stat.label}</CardTitle>
					</CardHeader>
					<CardContent className={stat.colorClass}>{stat.value}</CardContent>
				</Card>
			))}
		</div>
	);
};
