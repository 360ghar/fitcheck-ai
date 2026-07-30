/**
 * Bottom Navigation Component
 *
 * Mobile-first bottom tab bar for primary navigation.
 * Features:
 * - Elevated central FAB for primary action
 * - Active state with filled icon background
 * - Glassmorphism background
 * - Safe area support for notched devices
 *
 * Only visible on mobile (md:hidden)
 */

import { NavLink, useLocation, useNavigate } from 'react-router-dom'
import { Home, Shirt, Plus, Layers, User } from 'lucide-react'
import { cn } from '@/lib/utils'

// ============================================================================
// TYPES
// ============================================================================

interface NavItem {
  href: string
  icon: React.ElementType
  label: string
}

// ============================================================================
// CONFIG
// ============================================================================

const navItems: NavItem[] = [
  { href: '/dashboard', icon: Home, label: 'Home' },
  { href: '/wardrobe', icon: Shirt, label: 'Closet' },
  // FAB placeholder will be in the middle
  { href: '/outfits', icon: Layers, label: 'Outfits' },
  { href: '/profile', icon: User, label: 'Profile' },
]

// ============================================================================
// COMPONENT
// ============================================================================

export function BottomNav() {
  const location = useLocation()
  const navigate = useNavigate()

  // Determine context-aware FAB action
  const getFabAction = () => {
    if (location.pathname.startsWith('/wardrobe')) {
      return { action: '/wardrobe?action=add', label: 'Add Item' }
    }
    if (location.pathname.startsWith('/outfits')) {
      return { action: '/outfits?action=create', label: 'Create Outfit' }
    }
    return { action: '/wardrobe?action=add', label: 'Add' }
  }

  const fabAction = getFabAction()

  return (
    <nav
      className={cn(
        // Fixed to bottom with safe area padding
        'fixed bottom-0 left-0 right-0 z-[100] w-screen max-w-[100vw]',
        'bg-background',
        // Border
        'border-t border-border/50',
        // Safe area for notched devices
        'pb-[var(--safe-area-bottom)]',
        'pl-[var(--safe-area-left)] pr-[var(--safe-area-right)]',
        // Only show on mobile
        'md:hidden'
      )}
    >
      <div className="flex h-16 items-center justify-around px-2">
        {/* Left nav items (Home, Wardrobe) */}
        {navItems.slice(0, 2).map((item) => (
          <NavItem key={item.href} item={item} location={location} />
        ))}

        {/* Center FAB */}
        <div className="flex flex-col items-center justify-center px-2">
          <button
            type="button"
            onClick={() => navigate(fabAction.action)}
            className={cn(
              // Size and shape
              'w-12 h-12 rounded-full',
              'bg-primary',
              // Flex center
              'flex items-center justify-center',
              // Offset to float above nav bar
              '-mt-6',
              // Hover effects
              'hover:bg-primary/90 active:bg-primary-pressed',
              // Transition
              'transition-colors duration-200'
            )}
            aria-label={fabAction.label}
          >
            <Plus className="h-6 w-6 text-white" strokeWidth={2.5} />
          </button>
        </div>

        {/* Right nav items (Outfits, Profile) */}
        {navItems.slice(2).map((item) => (
          <NavItem key={item.href} item={item} location={location} />
        ))}
      </div>
    </nav>
  )
}

// ============================================================================
// NAV ITEM COMPONENT
// ============================================================================

interface NavItemProps {
  item: NavItem
  location: ReturnType<typeof useLocation>
}

function NavItem({ item, location }: NavItemProps) {
  const isActive =
    location.pathname === item.href ||
    location.pathname.startsWith(`${item.href}/`)

  return (
    <NavLink
      to={item.href}
      className={cn(
        // Touch target
        'flex flex-1 max-w-[72px] flex-col items-center justify-center',
        'min-h-[44px] py-1.5 px-2',
        // Transition
        'transition-colors duration-200',
        // Text styling
        'text-[10px] font-medium'
      )}
    >
      <div
        className={cn(
          'flex items-center justify-center',
          'w-10 h-7 rounded-full mb-0.5',
          'transition-colors duration-200',
          isActive
            ? 'bg-primary/15 text-primary'
            : 'text-muted-foreground'
        )}
      >
        <item.icon
          className={cn(
            'h-5 w-5',
            isActive && 'stroke-[2.5px]'
          )}
        />
      </div>
      <span
        className={cn(
          isActive ? 'text-primary font-semibold' : 'text-muted-foreground'
        )}
      >
        {item.label}
      </span>
    </NavLink>
  )
}

export default BottomNav
