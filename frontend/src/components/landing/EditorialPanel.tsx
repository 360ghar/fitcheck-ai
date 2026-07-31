import { cn } from '@/lib/utils'

interface EditorialPanelProps {
  children: React.ReactNode
  className?: string
}

/** Flat, token-backed panel for interactive landing demos. */
export function EditorialPanel({ children, className }: EditorialPanelProps) {
  return (
    <div className={cn('landing-panel', className)}>
      {children}
    </div>
  )
}
