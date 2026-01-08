/**
 * Main App Layout Component
 * Wraps authenticated pages with collapsible sidebar navigation
 */

import { Outlet } from 'react-router-dom'
import { Menu } from 'lucide-react'
import { cn } from '@/lib/utils'
import {
  SidebarProvider,
  Sidebar,
  SidebarMobile,
  useSidebar,
} from '@/components/sidebar'
import { Button } from '@/components/ui/button'

function AppLayoutContent() {
  const { isCollapsed, toggleMobile } = useSidebar()

  return (
    <div className="flex min-h-screen bg-background">
      {/* Desktop sidebar */}
      <Sidebar className="hidden md:flex" />

      {/* Mobile header */}
      <header className="fixed left-0 right-0 top-0 z-40 flex h-14 items-center justify-between border-b border-border bg-background px-4 md:hidden">
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleMobile}
          aria-label="Open navigation menu"
        >
          <Menu className="h-6 w-6" />
        </Button>
        <div className="flex items-center gap-2">
          <span className="text-lg font-bold text-primary">FitCheck</span>
          <span className="text-lg font-light text-muted-foreground">AI</span>
        </div>
        <div className="w-10" /> {/* Spacer for centering */}
      </header>

      {/* Mobile drawer */}
      <SidebarMobile />

      {/* Main content */}
      <main
        className={cn(
          'flex-1 transition-all duration-200',
          isCollapsed ? 'md:ml-16' : 'md:ml-60'
        )}
      >
        <div className="min-h-screen pt-14 md:pt-0">
          <Outlet />
        </div>

        <footer className="py-6 text-center text-xs text-muted-foreground">
          © {new Date().getFullYear()} FitCheck AI. All rights reserved.
        </footer>
      </main>
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
