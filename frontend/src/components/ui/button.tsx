import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "relative inline-flex min-w-[44px] items-center justify-center gap-2 whitespace-nowrap rounded-md px-4 text-sm font-bold leading-none text-ink transition-colors before:absolute before:-inset-y-0.5 before:left-0 before:right-0 before:content-[''] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:bg-surface-card disabled:text-ash disabled:opacity-100 cursor-pointer [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90 active:bg-primary-pressed",
        primary: "bg-primary text-primary-foreground hover:bg-primary/90 active:bg-primary-pressed",
        "primary-pressed": "bg-primary-pressed text-primary-foreground",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-border bg-transparent text-foreground hover:bg-secondary",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        tertiary: "bg-transparent hover:bg-surface-card",
        ghost: "bg-transparent hover:bg-surface-card",
        link: "text-primary underline-offset-4 hover:underline",
        // Rides over photography, so it keeps the theme-invariant on-image pair
        // in both themes (DESIGN.md 03 "bg canvas + text ink" = canvas white).
        "pill-on-image": "rounded-full bg-on-image text-on-image-foreground hover:bg-on-image/85",
        "icon-circular": "rounded-full bg-surface-card text-ink hover:bg-secondary",
      },
      size: {
        default: "h-11",
        sm: "h-11 px-3 text-xs",
        lg: "h-11 px-6",
        icon: "h-11 w-11 rounded-full px-0",
        "icon-sm": "h-11 w-11 rounded-full px-0",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
