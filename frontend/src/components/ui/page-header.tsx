import { cn } from '@/lib/utils'

export interface PageHeaderProps {
  title: string
  description?: string
  children?: React.ReactNode
  className?: string
  /** Optional leading icon/element */
  leading?: React.ReactNode
}

export function PageHeader({
  title,
  description,
  children,
  className,
  leading,
}: PageHeaderProps) {
  return (
    <div
      className={cn(
        'flex min-h-14 flex-col gap-2 border-b border-transparent pb-2 md:flex-row md:items-center md:justify-between md:pb-3',
        className
      )}
    >
      <div className="min-w-0">
        <div className="flex items-center gap-2">
          {leading}
          <h1 className="type-heading-xl text-foreground truncate">{title}</h1>
        </div>
        {description && (
          <p className="mt-1 type-body-sm text-muted-foreground">{description}</p>
        )}
      </div>
      {children && (
        <div className="flex flex-col sm:flex-row gap-2 shrink-0 w-full md:w-auto">
          {children}
        </div>
      )}
    </div>
  )
}
