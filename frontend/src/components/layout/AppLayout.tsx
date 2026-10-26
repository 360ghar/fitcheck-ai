/**
 * Main App Layout Component
 * Wraps authenticated pages with collapsible sidebar navigation
 * Mobile: Bottom navigation bar with simplified header
 * Desktop: Collapsible sidebar
 */

import { Outlet } from 'react-router-dom'
import { cn } from '@/lib/utils'
import {
  SidebarProvider,
  Sidebar,
  SidebarMobile,
  SidebarMobileTrigger,
  useSidebar,
} from '@/components/sidebar'
import { BottomNav } from '@/components/navigation/BottomNav'
import { JobPill } from '@/components/jobs'
import { Button } from '@/components/ui/button'
import { Link } from 'react-router-dom'
import { Plus } from 'lucide-react'
import { Logo } from '@/components/brand/Logo'
import { useUserRefresh } from '@/hooks/useUserRefresh'
import { useTranslation } from '@/i18n'

function AppLayoutContent() {
  const { isCollapsed } = useSidebar()
  const { t } = useTranslation()

  return (
    <>
      <a className="skip-link" href="#main-content">
        {t('common.skipToContent')}
      </a>
      <div className="flex min-h-[100svh] md:min-h-screen bg-background">
      {/* Desktop sidebar */}
      <Sidebar className="hidden md:flex" />

      {/* Mobile header - simplified since we have bottom nav */}
      <header className="fixed inset-x-0 top-0 z-40 flex h-16 items-center justify-center border-b border-border bg-background safe-area-top md:hidden ps-[var(--safe-area-left)] pe-[var(--safe-area-right)]">
        <div className="absolute start-[calc(var(--safe-area-left)+0.5rem)]">
          <SidebarMobileTrigger />
        </div>
        <Link to="/dashboard">
          <Logo markSize={32} wordmarkClassName="text-lg" />
        </Link>
        <Button asChild size="icon" className="absolute end-[calc(var(--safe-area-right)+0.5rem)]" aria-label={t('nav.addToWardrobe')}>
          <Link to="/wardrobe?action=add"><Plus className="h-4 w-4" /></Link>
        </Button>
      </header>

      {/* Main content */}
      <main
        id="main-content"
        tabIndex={-1}
        className={cn(
          // `min-w-0` is load-bearing: a flex item's default `min-width: auto`
          // adopts its content's min-content width, so a wide intrinsic child
          // (e.g. the wardrobe chip rail, a flex row summing to ~780px) forced
          // this main to 810px on a 360px phone and the page rendered as a
          // clipped desktop layout under `body`'s `overflow-x-hidden`.
          // `ms-*` keeps the sidebar offset on the correct side in RTL.
          'min-w-0 flex-1 transition-[margin] duration-200',
          isCollapsed ? 'md:ms-16' : 'md:ms-60'
        )}
      >
        {/* Content wrapper with padding for mobile header and bottom nav */}
        <div className="min-h-[100svh] md:min-h-screen pt-[calc(4rem+var(--safe-area-top))] pb-[calc(var(--bottom-nav-height)+var(--safe-area-bottom))] md:pt-0 md:pb-0">
          <Outlet />
        </div>

        <footer className="py-6 text-center text-xs text-muted-foreground hidden md:block">
          {t('common.copyright', { year: new Date().getFullYear() })}
        </footer>
      </main>

      {/* Background AI job status (wardrobe upload, generate look, etc.) */}
      <JobPill />

      {/* Bottom navigation for mobile */}
      <SidebarMobile />
      <BottomNav />
      </div>
    </>
  )
}

export default function AppLayout() {
  // Keep the session-cached user (and its expiring presigned avatar URL)
  // fresh: re-reads /users/me on mount, navigation, tab focus, and a 50-min
  // guard. The Try On page's profile thumbnail is one of the surfaces this
  // heals — see hooks/useUserRefresh.ts.
  useUserRefresh();
  return (
    <SidebarProvider>
      <AppLayoutContent />
    </SidebarProvider>
  )
}
