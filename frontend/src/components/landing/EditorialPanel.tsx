import { cn } from '@/lib/utils'

interface EditorialPanelProps {
  children: React.ReactNode
  className?: string
}

/** Paper sheet for the interactive landing demos: the stock's card colour on
 *  its slab (see `.paper-sheet` in index.css). */
export function EditorialPanel({ children, className }: EditorialPanelProps) {
  return (
    <div className={cn('paper-sheet', className)}>
      {children}
    </div>
  )
}
