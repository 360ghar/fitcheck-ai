import * as React from 'react'

import { cn } from '@/shared/lib/cn'

/** Keyboard key hint (⌘K, ↑↓, …) — used in the topbar search button and the
 * command palette footer. */
const Kbd = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    <kbd
      ref={ref}
      className={cn(
        'pointer-events-none inline-flex h-5 select-none items-center gap-1 rounded-sm border border-border bg-muted px-1.5 font-mono text-[11px] font-medium text-muted-foreground',
        className,
      )}
      {...props}
    />
  ),
)
Kbd.displayName = 'Kbd'

export { Kbd }
