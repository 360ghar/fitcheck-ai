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

function AppLayoutContent() {
  const { isCollapsed } = useSidebar()

  return (
    <div className="flex min-h-[100svh] md:min-h-screen bg-background">
      {/* Desktop sidebar */}
      <Sidebar className="hidden md:flex" />

      {/* Mobile header - simplified since we have bottom nav */}
      <header className="fixed left-0 right-0 top-0 z-40 flex h-16 items-center justify-center border-b border-hairline bg-background safe-area-top md:hidden pl-[var(--safe-area-left)] pr-[var(--safe-area-right)]">
        <div className="absolute left-[calc(var(--safe-area-left)+0.5rem)]">
          <SidebarMobileTrigger />
        </div>
        <div className="flex items-center gap-2">
          <span className="text-lg font-bold text-ink">FitCheck</span>
          <span className="text-lg font-semibold text-primary">AI</span>
        </div>
        <Button asChild size="icon" className="absolute right-[calc(var(--safe-area-right)+0.5rem)]" aria-label="Add to wardrobe">
          <Link to="/wardrobe?action=add"><Plus className="h-4 w-4" /></Link>
        </Button>
      </header>

      {/* Main content */}
      <main
        className={cn(
          'flex-1 transition-[margin] duration-200',
          isCollapsed ? 'md:ml-16' : 'md:ml-60'
        )}
      >
        {/* Content wrapper with padding for mobile header and bottom nav */}
        <div className="min-h-[100svh] md:min-h-screen pt-[calc(4rem+var(--safe-area-top))] pb-[calc(var(--bottom-nav-height)+var(--safe-area-bottom))] md:pt-0 md:pb-0">
          <Outlet />
        </div>

        <footer className="py-6 text-center text-xs text-muted-foreground hidden md:block">
          © {new Date().getFullYear()} FitCheck AI. All rights reserved.
        </footer>
      </main>

      {/* Background AI job status (wardrobe upload, generate look, etc.) */}
      <JobPill />

      {/* Bottom navigation for mobile */}
      <SidebarMobile />
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
