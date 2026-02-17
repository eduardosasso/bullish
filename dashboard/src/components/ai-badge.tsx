import { Badge } from "@/components/ui/badge";
import { assessmentBadgeClasses, assessmentSignal } from "@/lib/format";

type AiBadgeProps = {
	assessment: string;
};

export const AiBadge = ({ assessment }: AiBadgeProps) => {
	const signal = assessmentSignal(assessment);

	return <Badge className={assessmentBadgeClasses(signal)}>{signal}</Badge>;
};
