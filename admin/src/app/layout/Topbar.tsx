import { PanelLeftClose, PanelLeftOpen, Search, Menu } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { useMatches } from 'react-router-dom'

import { DeploymentStatus } from '@/app/layout/DeploymentStatus'
import { ThemeToggle, UserMenu } from '@/app/layout/UserMenu'
import { cn } from '@/shared/lib/cn'
import { useCommandStore } from '@/shared/stores/commandStore'
import { useUiStore } from '@/shared/stores/uiStore'
import { Button } from '@/shared/ui/button'
import { Kbd } from '@/shared/ui/kbd'

/**
 * Top bar: mobile hamburger, collapse toggle, global search (⌘K), theme
 * toggle, deployment status pill, user menu.
 */
export function Topbar({ onMenuClick }: { onMenuClick: () => void }) {
  const { t } = useTranslation('layout')
  const sidebarCollapsed = useUiStore((state) => state.sidebarCollapsed)
  const toggleSidebar = useUiStore((state) => state.toggleSidebar)
  const setCommandOpen = useCommandStore((state) => state.setOpen)
  const matches = useMatches()
  let titleKey: string | null = null
  for (const match of [...matches].reverse()) {
    const handle = match.handle as { titleKey?: string } | undefined
    if (handle?.titleKey) {
      titleKey = handle.titleKey
      break
    }
  }
  const pageTitle = titleKey ? t(titleKey) : null

  return (
    <header className="sticky top-0 z-30 flex h-14 shrink-0 items-center gap-2 border-b border-border bg-background/90 px-4 backdrop-blur sm:px-6">
      <div className="flex min-w-0 items-center gap-2">
        <Button
          variant="ghost"
          size="icon"
          className="lg:hidden"
          onClick={onMenuClick}
          aria-label={t('topbar.openMenu')}
        >
          <Menu aria-hidden="true" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="hidden lg:inline-flex"
          onClick={toggleSidebar}
          aria-label={t(sidebarCollapsed ? 'sidebar.expand' : 'sidebar.collapse')}
        >
          {sidebarCollapsed ? (
            <PanelLeftOpen aria-hidden="true" />
          ) : (
            <PanelLeftClose aria-hidden="true" />
          )}
        </Button>
        {pageTitle ? (
          <span className="hidden max-w-[28vw] truncate text-sm font-semibold tracking-tight text-ink lg:block">
            {pageTitle}
          </span>
        ) : null}
      </div>

      {/* Mobile-only icon trigger — ⌘K doesn't exist on touch devices */}
      <Button
        variant="ghost"
        size="icon"
        className="sm:hidden"
        onClick={() => setCommandOpen(true)}
        aria-label={t('topbar.search.hint')}
      >
        <Search aria-hidden="true" />
      </Button>

      <div className="ml-auto flex items-center gap-1.5">
        <button
          type="button"
          onClick={() => setCommandOpen(true)}
          aria-label={t('topbar.search.ariaLabel')}
          className={cn(
            'hidden h-8 w-[220px] items-center gap-2 rounded-full border border-border bg-surface-card px-3 text-left transition-colors hover:border-hairline sm:flex lg:w-[260px]',
            'focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50',
          )}
        >
          <Search className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
          <span className="flex-1 truncate text-sm text-muted-foreground">
            {t('topbar.search.placeholder')}
          </span>
          <Kbd>⌘K</Kbd>
        </button>
        <DeploymentStatus />
        <ThemeToggle />
        <UserMenu />
      </div>
    </header>
  )
}
