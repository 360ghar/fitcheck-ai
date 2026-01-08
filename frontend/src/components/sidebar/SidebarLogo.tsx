import { Link } from 'react-router-dom'
import { Sparkles } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'

export function SidebarLogo() {
  const { isCollapsed } = useSidebar()

  return (
    <Link
      to="/dashboard"
      className={cn(
        'flex items-center gap-2 px-3 py-4 transition-all duration-200',
        isCollapsed && 'justify-center px-2'
      )}
    >
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary text-primary-foreground">
        <Sparkles className="h-4 w-4" />
      </div>
      <div
        className={cn(
          'flex flex-col overflow-hidden transition-all duration-200',
          isCollapsed ? 'w-0 opacity-0' : 'w-auto opacity-100'
        )}
      >
        <span className="text-lg font-bold leading-none text-primary">
          FitCheck
        </span>
        <span className="text-xs font-light text-muted-foreground">AI</span>
      </div>
    </Link>
  )
}
