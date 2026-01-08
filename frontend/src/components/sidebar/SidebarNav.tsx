import { cn } from '@/lib/utils'

interface SidebarNavProps {
  children: React.ReactNode
  className?: string
}

export function SidebarNav({ children, className }: SidebarNavProps) {
  return (
    <nav
      role="navigation"
      aria-label="Main navigation"
      className={cn('flex-1 space-y-2 overflow-y-auto px-3 py-2', className)}
    >
      {children}
    </nav>
  )
}
