/**
 * Bottom Navigation Component
 * Mobile-first bottom tab bar for primary navigation
 * Only visible on mobile (md:hidden)
 */

import { NavLink, useLocation } from 'react-router-dom'
import { Home, Shirt, Layers, Calendar, User } from 'lucide-react'
import { cn } from '@/lib/utils'

interface NavItem {
  href: string
  icon: React.ElementType
  label: string
}

const navItems: NavItem[] = [
  { href: '/dashboard', icon: Home, label: 'Home' },
  { href: '/wardrobe', icon: Shirt, label: 'Wardrobe' },
  { href: '/outfits', icon: Layers, label: 'Outfits' },
  { href: '/calendar', icon: Calendar, label: 'Calendar' },
  { href: '/profile', icon: User, label: 'Profile' },
]

export function BottomNav() {
  const location = useLocation()

  return (
    <nav
      className={cn(
        // Fixed to bottom with safe area padding
        'fixed bottom-0 inset-x-0 z-[100] w-full',
        // Background with blur
        'bg-background/95 backdrop-blur-sm',
        // Border
        'border-t border-border',
        // Safe area for notched devices
        'pb-[var(--safe-area-bottom)]',
        // Only show on mobile
        'md:hidden'
      )}
    >
      <div className="flex items-center justify-around h-16">
        {navItems.map((item) => {
          const isActive =
            location.pathname === item.href ||
            location.pathname.startsWith(`${item.href}/`)

          return (
            <NavLink
              key={item.href}
              to={item.href}
              className={cn(
                // Touch target
                'flex flex-col items-center justify-center',
                'min-w-[64px] min-h-[44px] py-1 px-2',
                // Text styling
                'text-xs font-medium',
                // Transition
                'transition-colors duration-200',
                // Active/inactive states
                isActive
                  ? 'text-primary'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <item.icon
                className={cn(
                  'h-5 w-5 mb-0.5',
                  isActive && 'stroke-[2.5px]'
                )}
              />
              <span>{item.label}</span>
            </NavLink>
          )
        })}
      </div>
    </nav>
  )
}

export default BottomNav
