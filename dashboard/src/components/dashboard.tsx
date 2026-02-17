import { useState } from "react";
import { ScanPicker } from "@/components/scan-picker";
import { StockTable } from "@/components/stock-table";
import { SummaryCards } from "@/components/summary-cards";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { TAB_CONFIG, TABS_WITH_AI } from "@/lib/format";
import type { ScanResult, TabKey } from "@/lib/types";

type DashboardProps = {
	scans: ScanResult[];
};

const TAB_KEYS: TabKey[] = [
	"watchlist",
	"big_drops",
	"big_gains",
	"down_streaks",
	"up_streaks",
	"parabolic",
];

export const Dashboard = ({ scans }: DashboardProps) => {
	const [scanIndex, setScanIndex] = useState(0);
	const scan = scans[scanIndex];

	if (!scan) {
		return (
			<div className="flex h-screen items-center justify-center text-text-tertiary">
				No scan data found. Run scan.py to generate data.
			</div>
		);
	}

	return (
		<div className="min-h-screen bg-background px-6 py-6">
			<header className="mb-6 flex items-center justify-between">
				<div>
					<h1 className="text-2xl font-bold tracking-tight text-text-primary">
						Bullish
					</h1>
					<p className="text-sm text-text-tertiary">
						Momentum & mean-reversion scanner
					</p>
				</div>
				<ScanPicker
					timestamps={scans.map((s) => s.timestamp)}
					selected={scanIndex}
					onSelect={setScanIndex}
				/>
			</header>

			<section className="mb-6">
				<SummaryCards scan={scan} />
			</section>

			<Tabs defaultValue="watchlist">
				<TabsList>
					{TAB_KEYS.map((key) => (
						<TabsTrigger key={key} value={key}>
							{TAB_CONFIG[key].label}
							<span className="ml-1.5 text-text-tertiary">
								{scan[key].length}
							</span>
						</TabsTrigger>
					))}
				</TabsList>

				{TAB_KEYS.map((key) => (
					<TabsContent key={key} value={key}>
						<StockTable
							stocks={scan[key]}
							columns={TAB_CONFIG[key].columns}
							showAI={TABS_WITH_AI.includes(key)}
						/>
					</TabsContent>
				))}
			</Tabs>
		</div>
	);
};
