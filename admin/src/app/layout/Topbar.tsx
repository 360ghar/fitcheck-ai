import { PanelLeftClose, PanelLeftOpen, Search, Menu } from 'lucide-react'
import { useTranslation } from 'react-i18next'

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

  return (
    <header className="sticky top-0 z-30 flex h-16 shrink-0 items-center gap-2 border-b border-border bg-background/90 px-4 backdrop-blur sm:px-6">
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

      <button
        type="button"
        onClick={() => setCommandOpen(true)}
        aria-label={t('topbar.search.ariaLabel')}
        className={cn(
          'hidden h-11 w-full max-w-md items-center gap-2 rounded-full border border-border bg-surface-card px-3.5 text-left transition-colors hover:border-hairline sm:flex',
          'focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50',
        )}
      >
        <Search className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
        <span className="flex-1 truncate text-sm text-muted-foreground">
          {t('topbar.search.placeholder')}
        </span>
        <Kbd>⌘K</Kbd>
      </button>

      <div className="ml-auto flex items-center gap-1.5">
        <DeploymentStatus />
        <ThemeToggle />
        <UserMenu />
      </div>
    </header>
  )
}
