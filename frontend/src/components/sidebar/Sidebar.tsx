import { cn } from '@/lib/utils'
import { useSidebar } from './sidebar-context'
import { SidebarLogo } from './SidebarLogo'
import { SidebarNav } from './SidebarNav'
import { SidebarItem } from './SidebarItem'
import { SidebarToggle } from './SidebarToggle'
import { SidebarUser } from './SidebarUser'
import { navigationItems } from './navigation-config'

interface SidebarProps {
  className?: string
}

export function Sidebar({ className }: SidebarProps) {
  const { isCollapsed } = useSidebar()

  return (
    <aside
      className={cn(
        'fixed inset-y-0 left-0 z-40 flex flex-col border-r border-border bg-background transition-all duration-200 ease-out',
        isCollapsed ? 'w-16' : 'w-60',
        className
      )}
      aria-label="Main sidebar"
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
              label={item.name}
              badge={item.badge}
            />
          ))}
        </div>
      </SidebarNav>

      {/* User section */}
      <SidebarUser />
    </aside>
  )
}
