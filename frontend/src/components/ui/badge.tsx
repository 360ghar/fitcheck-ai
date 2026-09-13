import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const badgeVariants = cva(
  // Clay system: badges are stamped, not floating — the 1px `shadow-pressed`
  // cast + inset edge gives even a small pill physical weight on cream.
  "inline-flex items-center rounded-full border px-2.5 py-1 text-xs font-bold leading-none shadow-pressed transition-colors",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-primary text-primary-foreground",
        secondary:
          "border-transparent bg-secondary text-secondary-foreground",
        destructive:
          "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
        outline: "border-hairline bg-background text-foreground",
        // `text-white` is explicit, not lazy: --primary-foreground inverts to
        // near-black on dark (white fails on the lightened red), which would
        // make this label unreadable on the purple. White holds 8.1:1 light
        // and 5.3:1 dark against --accent-purple.
        "ai-pick": "border-transparent bg-accent-purple text-white",
        success: "border-transparent bg-success-pale text-success-deep",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

// A <span>, not a <div>: buttons only permit phrasing content, and Badge
// renders inside TouchBadge buttons (div children there are invalid HTML
// and trip flex/alignment quirks in some engines).
function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <span className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
