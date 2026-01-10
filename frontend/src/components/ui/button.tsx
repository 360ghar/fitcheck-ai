import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default: "bg-navy-800 text-white hover:bg-navy-900 dark:bg-gold-400 dark:text-navy-950 dark:hover:bg-gold-500",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-navy-200 bg-transparent hover:bg-navy-50 hover:text-navy-800 dark:border-navy-700 dark:hover:bg-navy-800 dark:hover:text-white",
        secondary:
          "bg-navy-100 text-navy-800 hover:bg-navy-200 dark:bg-navy-800 dark:text-navy-100 dark:hover:bg-navy-700",
        ghost: "hover:bg-navy-100 hover:text-navy-800 dark:hover:bg-navy-800 dark:hover:text-white",
        link: "text-navy-800 underline-offset-4 hover:underline dark:text-gold-400",
        gold: "bg-gold-400 text-navy-900 hover:bg-gold-500 shadow-gold-glow font-semibold",
      },
      size: {
        default: "h-11 px-5 py-2.5",
        sm: "h-10 rounded-md px-4",
        lg: "h-12 rounded-md px-8",
        icon: "h-11 w-11",
        "icon-sm": "h-10 w-10",
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
