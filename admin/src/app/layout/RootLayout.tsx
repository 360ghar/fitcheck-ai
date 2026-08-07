import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Outlet, useMatches } from 'react-router-dom'

import { Sidebar } from '@/app/layout/Sidebar'
import { Topbar } from '@/app/layout/Topbar'
import { SessionTimeoutProvider } from '@/features/auth/components/SessionTimeoutProvider'
import { CommandPalette } from '@/features/search/components/CommandPalette'
import { cn } from '@/shared/lib/cn'
import { useUiStore } from '@/shared/stores/uiStore'
import { Sheet, SheetContent, SheetTitle } from '@/shared/ui/sheet'

/**
 * App shell (spec §5): collapsible sidebar (240→64px) + topbar + content
 * area (max-w-7xl, 8px grid, 64px section rhythm). Sidebar becomes a Sheet
 * drawer below lg.
 */
export function RootLayout() {
  const { t } = useTranslation('layout')
  const sidebarCollapsed = useUiStore((state) => state.sidebarCollapsed)
  const [mobileOpen, setMobileOpen] = useState(false)
  const matches = useMatches()

  // Document title from the deepest matched route's handle.titleKey.
  useEffect(() => {
    let titleKey: string | null = null
    for (const match of [...matches].reverse()) {
      const handle = match.handle
      if (
        handle &&
        typeof handle === 'object' &&
        'titleKey' in handle &&
        typeof (handle).titleKey === 'string'
      ) {
        titleKey = (handle as { titleKey: string }).titleKey
        break
      }
    }
    document.title = titleKey ? `${t(titleKey)} · ${t('brand')}` : t('brand')
  }, [matches, t])

  return (
    <div className="min-h-dvh bg-background">
      {/* Desktop sidebar */}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-40 hidden w-60 border-r border-border transition-[width] duration-150 lg:block',
          sidebarCollapsed && 'w-16',
        )}
      >
        <Sidebar collapsed={sidebarCollapsed} />
      </aside>

      {/* Mobile drawer */}
      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetContent side="left" className="w-72 p-0">
          <SheetTitle className="sr-only">{t('brand')}</SheetTitle>
          <Sidebar collapsed={false} onNavigate={() => setMobileOpen(false)} />
        </SheetContent>
      </Sheet>

      <div
        className={cn(
          'flex min-h-dvh flex-col transition-[padding] duration-150',
          sidebarCollapsed ? 'lg:pl-16' : 'lg:pl-60',
        )}
      >
        <Topbar onMenuClick={() => setMobileOpen(true)} />
        <main className="mx-auto w-full max-w-7xl flex-1 px-4 py-6 sm:px-6 lg:px-8">
          <Outlet />
        </main>
      </div>

      <SessionTimeoutProvider />
      <CommandPalette />
    </div>
  )
}
