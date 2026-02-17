import { cn } from "@/lib/cn";
import { rsiColor } from "@/lib/format";

type RsiGaugeProps = {
	value: number;
};

export const RsiGauge = ({ value }: RsiGaugeProps) => (
	<span className={cn("tabular-nums", rsiColor(value))}>
		{value.toFixed(0)}
	</span>
);
