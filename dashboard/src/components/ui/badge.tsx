import * as React from "react";
import { cn } from "@/lib/cn";

type BadgeProps = React.HTMLAttributes<HTMLSpanElement>;

const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
	({ className, ...props }, ref) => (
		<span
			ref={ref}
			className={cn(
				"inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold uppercase tracking-wide",
				className,
			)}
			{...props}
		/>
	),
);
Badge.displayName = "Badge";

export { Badge };
