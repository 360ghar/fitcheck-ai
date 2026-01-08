import { Menu } from 'lucide-react'
import { useSidebar } from './sidebar-context'
import { SidebarLogo } from './SidebarLogo'
import { SidebarNav } from './SidebarNav'
import { SidebarItem } from './SidebarItem'
import { SidebarUser } from './SidebarUser'
import { navigationItems } from './navigation-config'
import { Button } from '@/components/ui/button'
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'

export function SidebarMobileTrigger() {
  const { toggleMobile } = useSidebar()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleMobile}
      className="md:hidden"
      aria-label="Open navigation menu"
    >
      <Menu className="h-6 w-6" />
    </Button>
  )
}

export function SidebarMobile() {
  const { isMobileOpen, setIsMobileOpen } = useSidebar()

  return (
    <Sheet open={isMobileOpen} onOpenChange={setIsMobileOpen}>
      <SheetContent side="left" className="flex w-72 flex-col p-0">
        <SheetHeader className="border-b border-border px-2 py-3">
          <SheetTitle className="sr-only">Navigation menu</SheetTitle>
          <SidebarLogo />
        </SheetHeader>

        {/* Navigation */}
        <SidebarNav className="flex-1">
          <div className="space-y-1">
            {navigationItems.map((item) => (
              <SidebarItem
                key={item.href}
                href={item.href}
                icon={item.icon}
                label={item.name}
                badge={item.badge}
              />
            ))}
          </div>
        </SidebarNav>

        {/* User section */}
        <SidebarUser />
      </SheetContent>
    </Sheet>
  )
}
