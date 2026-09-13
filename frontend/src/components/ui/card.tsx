import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const cardVariants = cva(
  // Clay system (clay-rebuild brief): every card rests pressed into the page
  // (the 3-layer `shadow-pressed` stack — stamped, not floating). The old
  // "flat, hairline only" rule is revoked; the hairline border stays for edges.
  "rounded-2xl text-card-foreground shadow-pressed transition-colors",
  {
    variants: {
      variant: {
        default: "border border-border bg-card",
        elevated: "border border-border bg-background",
        glass: "border border-border bg-surface-soft",
        gradient: "relative overflow-hidden border border-border bg-card",
        image: "relative overflow-hidden border border-border bg-card",
        // Clay signature interaction: pressed at rest, rises into the hard
        // no-blur offset shadow on hover/focus with a small diagonal shift
        // (~150ms ease-out, motion-safe gated — the shadow swap still fires
        // under reduced motion). Replaces the old "grounded lift": the offset
        // shadow grounds the motion instead of a bare translate.
        interactive:
          "cursor-pointer border border-transparent bg-card shadow-pressed transition-[border-color,box-shadow,transform] duration-150 ease-out hover:border-border hover:shadow-offset focus-within:border-border focus-within:shadow-offset motion-safe:hover:-translate-x-px motion-safe:hover:-translate-y-px",
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
      "type-heading-lg",
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
    className={cn("type-body-sm text-muted-foreground", className)}
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

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent, cardVariants }
