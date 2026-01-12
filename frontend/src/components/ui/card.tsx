import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const cardVariants = cva(
  "rounded-lg text-card-foreground transition-all duration-200",
  {
    variants: {
      variant: {
        default: "border border-border/50 bg-card shadow-sm",
        elevated: "bg-card shadow-elevated hover:shadow-elevated-hover hover:-translate-y-0.5",
        glass: "bg-white/80 dark:bg-navy-900/80 backdrop-blur-xl border border-navy-100/30 dark:border-navy-700/30",
        gradient: "bg-card border-0 ring-1 ring-gold-200/30 dark:ring-gold-700/20 hover:ring-gold-400/50 relative overflow-hidden",
        image: "bg-card border-0 overflow-hidden relative",
        interactive: "bg-card border border-border/50 shadow-sm hover:shadow-elevated hover:-translate-y-0.5 cursor-pointer",
        luxury: "bg-card border border-gold-200/30 dark:border-gold-700/20 shadow-sm hover:shadow-gold-glow",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface CardProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof cardVariants> {}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(cardVariants({ variant }), className)}
      {...props}
    />
  )
)
Card.displayName = "Card"

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
))
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "text-2xl font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  />
))
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
))
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
))
CardFooter.displayName = "CardFooter"

/** Gradient accent bar for cards - place at top of card content */
const CardAccent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & { gradient?: string }
>(({ className, gradient = "bg-gradient-gold", ...props }, ref) => (
  <div
    ref={ref}
    className={cn("absolute top-0 left-0 right-0 h-1", gradient, className)}
    {...props}
  />
))
CardAccent.displayName = "CardAccent"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent, CardAccent, cardVariants }
