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
  useSidebar,
} from '@/components/sidebar'
import { BottomNav } from '@/components/navigation/BottomNav'

function AppLayoutContent() {
  const { isCollapsed } = useSidebar()

  return (
    <div className="flex min-h-screen bg-background">
      {/* Desktop sidebar */}
      <Sidebar className="hidden md:flex" />

      {/* Mobile header - simplified since we have bottom nav */}
      <header className="fixed left-0 right-0 top-0 z-40 flex h-14 items-center justify-center border-b border-border bg-background/95 backdrop-blur-sm safe-area-top md:hidden">
        <div className="flex items-center gap-2">
          <span className="text-lg font-bold text-primary">FitCheck</span>
          <span className="text-lg font-light text-muted-foreground">AI</span>
        </div>
      </header>

      {/* Main content */}
      <main
        className={cn(
          'flex-1 transition-all duration-200',
          isCollapsed ? 'md:ml-16' : 'md:ml-60'
        )}
      >
        {/* Content wrapper with padding for mobile header and bottom nav */}
        <div className="min-h-screen pt-[calc(var(--mobile-header-height)+var(--safe-area-top))] pb-[calc(var(--bottom-nav-height)+var(--safe-area-bottom))] md:pt-0 md:pb-0">
          <Outlet />
        </div>

        <footer className="py-6 text-center text-xs text-muted-foreground hidden md:block">
          © {new Date().getFullYear()} FitCheck AI. All rights reserved.
        </footer>
      </main>

      {/* Bottom navigation for mobile */}
      <BottomNav />
    </div>
  )
}

export default function AppLayout() {
  return (
    <SidebarProvider>
      <AppLayoutContent />
    </SidebarProvider>
  )
}
