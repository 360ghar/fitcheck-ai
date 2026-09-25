import { Link } from 'react-router-dom'
import { Logo } from '@/components/brand/Logo'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'

export function SidebarLogo() {
  const { isCollapsed } = useSidebar()

  return (
    <Link
      to="/dashboard"
      className={cn(
        'flex h-16 items-center gap-2 px-3 transition-[padding] duration-200',
        isCollapsed && 'justify-center px-2'
      )}
    >
      <Logo markSize={36} compact={isCollapsed} wordmarkClassName="text-lg" />
    </Link>
  )
}
