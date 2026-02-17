import type * as React from "react";

type TooltipProps = {
	content: string;
	children: React.ReactNode;
};

export const Tooltip = ({ content, children }: TooltipProps) => (
	<span title={content} className="cursor-help border-b border-dashed border-text-tertiary">
		{children}
	</span>
);
