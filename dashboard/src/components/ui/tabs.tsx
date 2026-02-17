import * as TabsPrimitive from "@radix-ui/react-tabs";
import * as React from "react";
import { cn } from "@/lib/cn";

const Tabs = TabsPrimitive.Root;

const TabsList = React.forwardRef<
	React.ComponentRef<typeof TabsPrimitive.List>,
	React.ComponentPropsWithoutRef<typeof TabsPrimitive.List>
>(({ className, ...props }, ref) => (
	<TabsPrimitive.List
		ref={ref}
		className={cn(
			"inline-flex items-center gap-1 rounded-lg bg-surface p-1",
			className,
		)}
		{...props}
	/>
));
TabsList.displayName = "TabsList";

const TabsTrigger = React.forwardRef<
	React.ComponentRef<typeof TabsPrimitive.Trigger>,
	React.ComponentPropsWithoutRef<typeof TabsPrimitive.Trigger>
>(({ className, ...props }, ref) => (
	<TabsPrimitive.Trigger
		ref={ref}
		className={cn(
			"inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1.5 text-xs font-semibold uppercase tracking-wider text-text-secondary transition-all",
			"hover:text-text-primary",
			"data-[state=active]:bg-surface-raised data-[state=active]:text-text-primary data-[state=active]:shadow-sm",
			className,
		)}
		{...props}
	/>
));
TabsTrigger.displayName = "TabsTrigger";

const TabsContent = React.forwardRef<
	React.ComponentRef<typeof TabsPrimitive.Content>,
	React.ComponentPropsWithoutRef<typeof TabsPrimitive.Content>
>(({ className, ...props }, ref) => (
	<TabsPrimitive.Content
		ref={ref}
		className={cn("mt-4 focus-visible:outline-none", className)}
		{...props}
	/>
));
TabsContent.displayName = "TabsContent";

export { Tabs, TabsList, TabsTrigger, TabsContent };
