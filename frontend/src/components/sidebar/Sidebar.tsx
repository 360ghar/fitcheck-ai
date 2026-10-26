import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import { SidebarLogo } from './SidebarLogo'
import { SidebarNav } from './SidebarNav'
import { SidebarItem } from './SidebarItem'
import { SidebarToggle } from './SidebarToggle'
import { SidebarUser } from './SidebarUser'
import { navigationItems } from './navigation-config'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useTranslation } from '@/i18n'

interface SidebarProps {
  className?: string
}

export function Sidebar({ className }: SidebarProps) {
  const { isCollapsed } = useSidebar()
  const { t } = useTranslation()

  return (
    <aside
      className={cn(
        // Logical sides throughout: on an RTL page the sidebar belongs on the
        // right (inline-start), and `start-0`/`border-r` would pin it to the
        // wrong edge with the border on its outer side.
        'fixed inset-y-0 start-0 z-40 flex flex-col border-e border-border bg-background transition-[width] duration-200 ease-out',
        isCollapsed ? 'w-16' : 'w-60',
        className
      )}
      aria-label={t('nav.mainNavigation')}
    >
      {/* Logo and collapse toggle */}
      <div
        className={cn(
          'flex items-center border-b border-border',
          isCollapsed ? 'justify-center px-2 py-2' : 'justify-between px-2 py-1'
        )}
      >
        {!isCollapsed && <SidebarLogo />}
        <SidebarToggle />
      </div>

      {/* Navigation */}
      <SidebarNav>
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

      <div className="px-3 pb-3">
        <Button asChild className={cn('w-full', isCollapsed && 'px-0')} aria-label={t('nav.addToWardrobe')}>
          <Link to="/wardrobe?action=add">
            <Plus className="h-4 w-4" />
            {!isCollapsed && t('nav.addItem')}
          </Link>
        </Button>
      </div>

      {/* User section */}
      <SidebarUser />
    </aside>
  )
}
