import { Link } from 'react-router-dom'
import { Shirt } from 'lucide-react'
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
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-gold-400 text-navy-900">
        <Shirt className="h-4 w-4" />
      </div>
      <div
        className={cn(
          'flex items-baseline gap-0.5 overflow-hidden transition-all duration-200',
          isCollapsed ? 'w-0 opacity-0' : 'w-auto opacity-100'
        )}
      >
        <span className="text-lg font-display font-semibold leading-none text-navy-800 dark:text-white">
          FitCheck
        </span>
        <span className="text-lg font-light text-gold-500 dark:text-gold-400">AI</span>
      </div>
    </Link>
  )
}
