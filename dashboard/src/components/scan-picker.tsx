import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/ui/select";

type ScanPickerProps = {
	timestamps: string[];
	selected: number;
	onSelect: (index: number) => void;
};

const formatTimestamp = (ts: string): string => {
	const d = new Date(ts);

	return d.toLocaleDateString("en-US", {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "numeric",
		minute: "2-digit",
	});
};

export const ScanPicker = ({
	timestamps,
	selected,
	onSelect,
}: ScanPickerProps) => (
	<Select value={String(selected)} onValueChange={(v) => onSelect(Number(v))}>
		<SelectTrigger className="w-64">
			<SelectValue />
		</SelectTrigger>
		<SelectContent>
			{timestamps.map((ts, i) => (
				<SelectItem key={ts} value={String(i)}>
					{formatTimestamp(ts)}
				</SelectItem>
			))}
		</SelectContent>
	</Select>
);
