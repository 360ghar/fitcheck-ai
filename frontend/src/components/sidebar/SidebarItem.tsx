import { Link, useLocation } from 'react-router-dom'
import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'

interface SidebarItemProps {
  href: string
  icon: LucideIcon
  label: string
  badge?: string | number
  onClick?: () => void
}

export function SidebarItem({
  href,
  icon: Icon,
  label,
  badge,
  onClick,
}: SidebarItemProps) {
  const location = useLocation()
  const { isCollapsed, closeMobile } = useSidebar()

  const isActive =
    location.pathname === href ||
    (href !== '/dashboard' && location.pathname.startsWith(href))

  const handleClick = () => {
    closeMobile()
    onClick?.()
  }

  const content = (
    <Link
      to={href}
      onClick={handleClick}
      className={cn(
        'group flex min-h-11 items-center gap-3 rounded-md px-3 py-2 text-sm font-semibold transition-colors',
        'hover:bg-accent hover:text-accent-foreground',
        isActive
          ? 'bg-primary text-primary-foreground'
          : 'text-muted-foreground',
        isCollapsed && 'justify-center px-2'
      )}
      aria-current={isActive ? 'page' : undefined}
    >
      <Icon
        className={cn(
          'h-5 w-5 shrink-0 transition-colors',
          isActive
            ? 'text-primary-foreground'
            : 'text-muted-foreground group-hover:text-accent-foreground'
        )}
      />
      <span
        className={cn(
          'truncate transition-[width,opacity] duration-200',
          isCollapsed ? 'w-0 opacity-0' : 'w-auto opacity-100'
        )}
      >
        {label}
      </span>
      {badge !== undefined && !isCollapsed && (
        <span className="ml-auto flex h-5 min-w-5 items-center justify-center rounded-full bg-primary/10 px-1.5 text-xs font-medium text-primary">
          {badge}
        </span>
      )}
    </Link>
  )

  if (isCollapsed) {
    return (
      <Tooltip delayDuration={0}>
        <TooltipTrigger asChild>{content}</TooltipTrigger>
        <TooltipContent side="right" sideOffset={10}>
          <p>{label}</p>
          {badge !== undefined && (
            <span className="ml-1 text-xs text-muted-foreground">({badge})</span>
          )}
        </TooltipContent>
      </Tooltip>
    )
  }

  return content
}
