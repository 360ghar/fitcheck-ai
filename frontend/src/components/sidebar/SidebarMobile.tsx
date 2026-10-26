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
import { useTranslation } from '@/i18n'

export function SidebarMobileTrigger() {
  const { toggleMobile } = useSidebar()
  const { t } = useTranslation()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleMobile}
      className="md:hidden"
      aria-label={t('nav.mainNavigation')}
    >
      <Menu className="h-6 w-6" />
    </Button>
  )
}

export function SidebarMobile() {
  const { isMobileOpen, setIsMobileOpen } = useSidebar()
  const { t } = useTranslation()

  return (
    <Sheet open={isMobileOpen} onOpenChange={setIsMobileOpen}>
      {/* `start`, not `left`: in an RTL locale the drawer has to slide in from
          the right, where the sidebar actually is. */}
      <SheetContent side="start" className="flex w-72 flex-col px-0 pb-[calc(1.5rem+var(--safe-area-bottom))] pt-[calc(1rem+var(--safe-area-top))]">
        <SheetHeader className="border-b border-border px-2 py-3">
          <SheetTitle className="sr-only">{t('nav.mainNavigation')}</SheetTitle>
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
                label={t(item.labelKey)}
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
