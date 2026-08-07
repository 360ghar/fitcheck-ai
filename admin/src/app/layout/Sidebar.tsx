import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { navGroups, type NavItem } from '@/app/layout/nav'
import { usePermission } from '@/shared/hooks/usePermission'
import { cn } from '@/shared/lib/cn'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { Avatar, AvatarFallback, AvatarImage } from '@/shared/ui/avatar'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/shared/ui/tooltip'

/**
 * Sidebar — fixed on desktop (collapsible 240px → 64px), rendered inside a
 * Sheet drawer on mobile. Groups + items filtered by usePermission.
 */
export function Sidebar({
  collapsed,
  onNavigate,
}: {
  collapsed: boolean
  onNavigate?: () => void
}) {
  const { t } = useTranslation('layout')
  const { can } = usePermission()

  return (
    <div className="flex h-full flex-col bg-background">
      <div
        className={cn(
          'flex h-16 shrink-0 items-center gap-2.5 border-b border-border px-4',
          collapsed && 'justify-center px-2',
        )}
      >
        <img src="/favicon.svg" alt="" className="size-6 shrink-0" aria-hidden="true" />
        {!collapsed ? (
          <span className="text-sm font-bold tracking-tight text-ink">{t('brand')}</span>
        ) : null}
      </div>

      <nav className="flex-1 overflow-y-auto px-2 py-4" aria-label={t('nav.label')}>
        {navGroups.map((group) => {
          const visibleItems = group.items.filter((item) => !item.permission || can(item.permission))
          if (visibleItems.length === 0) return null
          return (
            <div key={group.labelKey} className="mb-4 last:mb-0">
              {!collapsed ? (
                <p className="px-2.5 pb-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                  {t(group.labelKey)}
                </p>
              ) : null}
              <ul className="space-y-0.5">
                {visibleItems.map((item) => (
                  <SidebarItem key={item.path} item={item} collapsed={collapsed} onNavigate={onNavigate} />
                ))}
              </ul>
            </div>
          )
        })}
      </nav>

      <SidebarUserCard collapsed={collapsed} />
    </div>
  )
}

function SidebarItem({
  item,
  collapsed,
  onNavigate,
}: {
  item: NavItem
  collapsed: boolean
  onNavigate: (() => void) | undefined
}) {
  const { t } = useTranslation('layout')
  const icon = <item.icon className="size-4 shrink-0" aria-hidden="true" />
  const link = (
    <NavLink
      to={item.path}
      onClick={onNavigate}
      className={({ isActive }) =>
        cn(
          'group relative flex items-center gap-2.5 rounded-md px-2.5 py-2 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50',
          isActive
            ? 'bg-surface-card text-ink'
            : 'text-muted-foreground hover:bg-surface-card/60 hover:text-foreground',
          collapsed && 'justify-center px-0',
        )
      }
    >
      {({ isActive }) => (
        <>
          {isActive ? (
            <span
              className="absolute left-0 top-1/2 h-5 w-0.5 -translate-y-1/2 rounded-full bg-primary"
              aria-hidden="true"
            />
          ) : null}
          {icon}
          {!collapsed ? <span className="truncate">{t(item.titleKey)}</span> : null}
          <span className={cn('sr-only', !collapsed && 'hidden')}>{t(item.titleKey)}</span>
        </>
      )}
    </NavLink>
  )

  if (!collapsed) return <li>{link}</li>
  return (
    <li>
      <Tooltip>
        <TooltipTrigger asChild>{link}</TooltipTrigger>
        <TooltipContent side="right">{t(item.titleKey)}</TooltipContent>
      </Tooltip>
    </li>
  )
}

function SidebarUserCard({ collapsed }: { collapsed: boolean }) {
  const { t } = useTranslation('layout')
  const user = useSessionStore((state) => state.user)
  const role = useSessionStore((state) => state.role)
  const displayName = user?.full_name || user?.email || '—'
  const initials = user?.full_name
    ? user.full_name
        .split(' ')
        .map((part) => part[0])
        .filter(Boolean)
        .slice(0, 2)
        .join('')
        .toUpperCase()
    : user?.email?.slice(0, 2).toUpperCase() ?? '?'

  const card = (
    <div
      className={cn(
        'flex shrink-0 items-center gap-2.5 border-t border-border p-3',
        collapsed && 'justify-center p-2',
      )}
    >
      <Avatar className="size-8">
        <AvatarImage src={user?.avatar_url ?? undefined} alt="" />
        <AvatarFallback>{initials}</AvatarFallback>
      </Avatar>
      {!collapsed ? (
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-medium text-foreground">{displayName}</p>
          <p className="truncate text-xs text-muted-foreground">{role ? t(`roles.${role}`) : '—'}</p>
        </div>
      ) : null}
    </div>
  )

  if (collapsed) {
    return (
      <Tooltip>
        <TooltipTrigger asChild>{card}</TooltipTrigger>
        <TooltipContent side="right">
          {displayName} · {role ? t(`roles.${role}`) : '—'}
        </TooltipContent>
      </Tooltip>
    )
  }
  return card
}
