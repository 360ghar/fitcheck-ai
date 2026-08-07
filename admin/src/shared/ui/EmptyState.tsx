import type { LucideIcon } from 'lucide-react'
import { Inbox } from 'lucide-react'

import { cn } from '@/shared/lib/cn'

/**
 * Empty state — one clear CTA, flat illustration-style (DESIGN.md §5).
 */
export interface EmptyStateProps {
  icon?: LucideIcon
  title: string
  message?: string
  action?: React.ReactNode
  className?: string
}

export function EmptyState({ icon: Icon = Inbox, title, message, action, className }: EmptyStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center gap-2 px-6 py-12 text-center', className)}>
      <div className="flex size-12 items-center justify-center rounded-full bg-surface-card" aria-hidden="true">
        <Icon className="size-6 text-muted-foreground" />
      </div>
      <h3 className="text-base font-semibold text-foreground">{title}</h3>
      {message ? <p className="max-w-sm text-sm text-muted-foreground">{message}</p> : null}
      {action ? <div className="mt-2">{action}</div> : null}
    </div>
  )
}
