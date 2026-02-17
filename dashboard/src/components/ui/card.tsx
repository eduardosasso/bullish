import * as React from "react";
import { cn } from "@/lib/cn";

const Card = React.forwardRef<
	HTMLDivElement,
	React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
	<div
		ref={ref}
		className={cn("rounded-xl border border-border bg-surface p-6", className)}
		{...props}
	/>
));
Card.displayName = "Card";

const CardHeader = React.forwardRef<
	HTMLDivElement,
	React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
	<div
		ref={ref}
		className={cn("flex flex-col gap-1.5", className)}
		{...props}
	/>
));
CardHeader.displayName = "CardHeader";

const CardTitle = React.forwardRef<
	HTMLParagraphElement,
	React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
	<h3
		ref={ref}
		className={cn(
			"text-xs font-semibold uppercase tracking-wider text-text-secondary",
			className,
		)}
		{...props}
	/>
));
CardTitle.displayName = "CardTitle";

const CardContent = React.forwardRef<
	HTMLDivElement,
	React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
	<div
		ref={ref}
		className={cn("text-3xl font-bold tabular-nums tracking-tight", className)}
		{...props}
	/>
));
CardContent.displayName = "CardContent";

export { Card, CardHeader, CardTitle, CardContent };
