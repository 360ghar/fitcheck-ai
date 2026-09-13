import { cn } from '@/lib/utils'

interface EditorialPanelProps {
  children: React.ReactNode
  className?: string
}

/** Pressed-clay panel for interactive landing demos (clay-rebuild "Depth"):
 *  `landing-panel` supplies the 24px card radius + oat hairline; the resting
 *  `shadow-pressed` stack stamps the demo card into the page. */
export function EditorialPanel({ children, className }: EditorialPanelProps) {
  return (
    <div className={cn('landing-panel shadow-pressed', className)}>
      {children}
    </div>
  )
}
