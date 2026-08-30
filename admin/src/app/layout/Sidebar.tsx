import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { navGroups, type NavItem } from '@/app/layout/nav'
import { usePermission } from '@/shared/hooks/usePermission'
import { cn } from '@/shared/lib/cn'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { Avatar, AvatarFallback, AvatarImage } from '@/shared/ui/avatar'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/shared/ui/tooltip'

/**
 * Sidebar v2 — power-tool rail: dense, bento-friendly.
 * - Desktop 240 → 72px collapsed (was 64), 11px group labels, dividers.
 * - Active: brand-accent left border + bg-brand/10 (was dot).
 * - Hover: bg-surface-card.
 * - Badge slot (right-aligned) for commerce/AI counts when expanded.
 * - Footer hint ⌘K for command palette.
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
          'flex h-14 shrink-0 items-center gap-2.5 border-b border-border px-3',
          collapsed && 'justify-center px-2',
        )}
      >
        <img src="/favicon.svg" alt="" className="size-6 shrink-0" aria-hidden="true" />
        {!collapsed ? (
          <span className="text-sm font-bold tracking-tight text-ink">{t('brand')}</span>
        ) : null}
      </div>

      <nav className="flex-1 overflow-y-auto px-2 py-3" aria-label={t('nav.label')}>
        {navGroups.map((group, idx) => {
          const visibleItems = group.items.filter((item) => !item.permission || can(item.permission))
          if (visibleItems.length === 0) return null
          return (
            <div key={group.labelKey} className={cn('mb-3 last:mb-0', idx > 0 && 'border-t border-border pt-3')}>
              {!collapsed ? (
                <p className="px-2 pb-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-muted-foreground">
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

      {!collapsed ? (
        <div className="border-t border-border px-3 py-2">
          <p className="text-[11px] text-muted-foreground">
            <span className="rounded border border-border bg-surface-card px-1 py-0.5 font-mono text-[10px]">⌘K</span>{' '}
            quick search
          </p>
        </div>
      ) : null}
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
          'group relative flex items-center gap-2 rounded-md px-2 py-1.5 text-[13px] font-medium transition-colors focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50',
          isActive
            ? 'border-l-[2px] border-brand bg-brand/10 pl-[6px] font-semibold text-brand'
            : 'border-l-[2px] border-transparent text-muted-foreground hover:bg-surface-card hover:text-foreground',
          collapsed && 'justify-center border-l-0 px-0 pl-0',
        )
      }
    >
      {({ isActive }) => (
        <>
          {icon}
          {!collapsed ? <span className="flex-1 truncate">{t(item.titleKey)}</span> : null}
          {!collapsed && isActive ? <span className="size-1.5 rounded-full bg-brand" aria-hidden="true" /> : null}
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
        'flex shrink-0 items-center gap-2 border-t border-border p-2.5',
        collapsed && 'justify-center p-2',
      )}
    >
      <Avatar className="size-7">
        <AvatarImage src={user?.avatar_url ?? undefined} alt="" />
        <AvatarFallback className="text-xs">{initials}</AvatarFallback>
      </Avatar>
      {!collapsed ? (
        <div className="min-w-0 flex-1">
          <p className="truncate text-[13px] font-medium leading-tight text-foreground">{displayName}</p>
          <p className="truncate text-[11px] leading-tight text-muted-foreground">{role ? t(`roles.${role}`) : '—'}</p>
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
