import { ChevronDown, ChevronRight } from "lucide-react";
import { useState } from "react";
import { AiBadge } from "@/components/ai-badge";
import { RsiGauge } from "@/components/rsi-gauge";
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/components/ui/table";
import { Tooltip } from "@/components/ui/tooltip";
import { cn } from "@/lib/cn";
import {
	formatPct,
	formatPrice,
	pctColor,
	ratingColor,
	ratingLabel,
} from "@/lib/format";
import type { ColumnDef, ColumnKey, Stock } from "@/lib/types";

type StockTableProps = {
	stocks: Stock[];
	columns: ColumnDef[];
	showAI: boolean;
};

const alignClass = (align: string): string => {
	if (align === "right") return "text-right";
	if (align === "center") return "text-center";

	return "text-left";
};

const cellContent = (stock: Stock, key: ColumnKey): React.ReactNode => {
	switch (key) {
		case "ticker":
			return (
				<span className="font-semibold tracking-wide">{stock.ticker}</span>
			);
		case "name":
			return (
				<span className="max-w-48 truncate text-text-secondary">
					{stock.name}
				</span>
			);
		case "price":
			return formatPrice(stock.price);
		case "ath":
			return formatPrice(stock.ath);
		case "pct_from_ath":
			return (
				<span className={pctColor(stock.pct_from_ath)}>
					{formatPct(stock.pct_from_ath)}
				</span>
			);
		case "fair_value":
			return stock.fair_value > 0 ? (
				formatPrice(stock.fair_value)
			) : (
				<span className="text-text-tertiary">—</span>
			);
		case "upside":
			return stock.fair_value > 0 ? (
				<span className={pctColor(stock.upside)}>
					{formatPct(stock.upside)}
				</span>
			) : (
				<span className="text-text-tertiary">—</span>
			);
		case "rating":
			return stock.rating ? (
				<span
					className={cn("text-xs font-semibold", ratingColor(stock.rating))}
				>
					{ratingLabel(stock.rating)}
				</span>
			) : (
				<span className="text-text-tertiary">—</span>
			);
		case "rsi":
			return <RsiGauge value={stock.rsi} />;
		case "change_1d":
			return (
				<span className={pctColor(stock.change_1d)}>
					{formatPct(stock.change_1d)}
				</span>
			);
		case "streak":
			return (
				<span className={pctColor(stock.streak)}>
					{stock.streak > 0 ? `+${stock.streak}` : stock.streak}
				</span>
			);
		case "roc_30d":
			return (
				<span className={pctColor(stock.roc_30d)}>
					{formatPct(stock.roc_30d)}
				</span>
			);
		default:
			return null;
	}
};

export const StockTable = ({ stocks, columns, showAI }: StockTableProps) => {
	const [expanded, setExpanded] = useState<Set<string>>(new Set());

	const toggle = (ticker: string) => {
		setExpanded((prev) => {
			const next = new Set(prev);
			if (next.has(ticker)) next.delete(ticker);
			else next.add(ticker);

			return next;
		});
	};

	if (stocks.length === 0) {
		return (
			<div className="flex h-32 items-center justify-center text-text-tertiary">
				No stocks in this category
			</div>
		);
	}

	return (
		<Table>
			<TableHeader>
				<TableRow className="border-white/10 hover:bg-transparent">
					{showAI && <TableHead className="w-8" />}
					{columns.map((col) => (
						<TableHead key={col.key} className={alignClass(col.align)}>
							{col.tooltip ? (
								<Tooltip content={col.tooltip}>{col.label}</Tooltip>
							) : (
								col.label
							)}
						</TableHead>
					))}
				</TableRow>
			</TableHeader>
			<TableBody>
				{stocks.map((stock) => {
					const hasAI = showAI && !!stock.ai_assessment;
					const isExpanded = expanded.has(stock.ticker);

					return (
						<>
							<TableRow key={stock.ticker}>
								{showAI && (
									<TableCell className="w-8 pr-0">
										{hasAI && (
											<button
												type="button"
												onClick={() => toggle(stock.ticker)}
												className="flex h-5 w-5 items-center justify-center rounded text-text-tertiary hover:text-text-primary"
											>
												{isExpanded ? (
													<ChevronDown className="h-3.5 w-3.5" />
												) : (
													<ChevronRight className="h-3.5 w-3.5" />
												)}
											</button>
										)}
									</TableCell>
								)}
								{columns.map((col) => (
									<TableCell key={col.key} className={alignClass(col.align)}>
										{cellContent(stock, col.key)}
									</TableCell>
								))}
							</TableRow>
							{hasAI && isExpanded && (
								<TableRow
									key={`${stock.ticker}-ai`}
									className="hover:bg-transparent"
								>
									<TableCell colSpan={columns.length + 1} className="px-6 py-3">
										<div className="flex items-start gap-3 rounded-lg bg-white/[0.02] px-4 py-3">
											<AiBadge assessment={stock.ai_assessment} />
											<p className="text-sm leading-relaxed text-text-secondary">
												{stock.ai_assessment}
											</p>
										</div>
									</TableCell>
								</TableRow>
							)}
						</>
					);
				})}
			</TableBody>
		</Table>
	);
};
