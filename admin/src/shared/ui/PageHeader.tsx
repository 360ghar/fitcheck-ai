import { cn } from '@/shared/lib/cn'

/**
 * Standard page header: title, optional description, actions slot.
 * 64px section rhythm is handled by the page layout.
 */
export interface PageHeaderProps {
  title: string
  description?: string
  actions?: React.ReactNode
  className?: string
  /** Compact variant for table pages — smaller type, less vertical rhythm. */
  dense?: boolean
}

export function PageHeader({ title, description, actions, className, dense }: PageHeaderProps) {
  if (dense) {
    return (
      <div className={cn('flex flex-wrap items-center justify-between gap-2', className)}>
        <div className="min-w-0 flex-1">
          <h1 className="truncate text-base font-semibold tracking-tight text-ink">{title}</h1>
          {description ? (
            <p className="truncate text-xs text-muted-foreground">{description}</p>
          ) : null}
        </div>
        {actions ? (
          <div className="flex min-w-0 shrink-0 flex-wrap items-center gap-2">{actions}</div>
        ) : null}
      </div>
    )
  }
  return (
    <div className={cn('flex flex-wrap items-start justify-between gap-4', className)}>
      <div className="space-y-1">
        <h1 className="text-2xl font-bold tracking-tight text-ink">{title}</h1>
        {description ? <p className="max-w-2xl text-sm text-muted-foreground">{description}</p> : null}
      </div>
      {/* min-w-0: actions can exceed the viewport (tab pills, button rows);
          without it the wrapper's min-width:auto blows the page out on
          mobile instead of wrapping/shrinking. */}
      {actions ? (
        <div className="flex min-w-0 flex-wrap items-center gap-2">{actions}</div>
      ) : null}
    </div>
  )
}
