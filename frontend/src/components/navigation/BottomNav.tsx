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
import { useTranslation } from '@/i18n'

// ============================================================================
// TYPES
// ============================================================================

interface NavItem {
  href: string
  icon: React.ElementType
  /** Message id — resolved at render so a language switch repaints the bar. */
  labelKey: string
}

// ============================================================================
// CONFIG
// ============================================================================

const navItems: NavItem[] = [
  { href: '/dashboard', icon: Home, labelKey: 'nav.home' },
  { href: '/wardrobe', icon: Shirt, labelKey: 'nav.closet' },
  // FAB placeholder will be in the middle
  { href: '/outfits', icon: Layers, labelKey: 'nav.outfits' },
  { href: '/profile', icon: User, labelKey: 'nav.profile' },
]

// ============================================================================
// COMPONENT
// ============================================================================

export function BottomNav() {
  const location = useLocation()
  const navigate = useNavigate()
  const { t } = useTranslation()

  // Determine context-aware FAB action
  const getFabAction = () => {
    if (location.pathname.startsWith('/wardrobe')) {
      return { action: '/wardrobe?action=add', label: t('nav.addItem') }
    }
    if (location.pathname.startsWith('/outfits')) {
      return { action: '/outfits/new', label: t('nav.createOutfit') }
    }
    return { action: '/wardrobe?action=add', label: t('nav.add') }
  }

  const fabAction = getFabAction()

  return (
    <nav
      aria-label={t('nav.primaryNavigation')}
      className={cn(
        // Fixed to bottom with safe area padding. `inset-x-0` rather than
        // `start-0 end-0` so the bar spans the viewport in either direction.
        'fixed bottom-0 inset-x-0 z-30 max-w-[100vw]',
        'bg-background',
        // Border
        'border-t border-border/50',
        // Safe area for notched devices
        'pb-[var(--safe-area-bottom)]',
        'ps-[var(--safe-area-left)] pe-[var(--safe-area-right)]',
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
              // Clay depth: pressed at rest, hard offset shadow on hover
              // (`.lift` = the press-then-offset pattern outside the Button
              // primitive; the translate is reduced-motion gated there).
              'lift',
              // Hover effects
              'hover:bg-primary/90 active:bg-primary-pressed',
              // Press feedback: mechanical dip, not a repaint alone
              'transition-[background-color,transform] duration-150 ease-out',
              'motion-safe:active:scale-90'
            )}
            aria-label={fabAction.label}
          >
            {/* Pairs with bg-primary in both themes; a hardcoded white drops
                to 3.5:1 on the lightened dark --primary. */}
            <Plus className="h-6 w-6 text-primary-foreground" strokeWidth={2.5} />
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
  const { t } = useTranslation()
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
        // Keyed by active state so re-mounting the pill replays the scale-in
        // every time the tab becomes active (CSS animations don't restart on
        // a class-only swap). Reduced-motion users get the plain color swap.
        key={isActive ? 'active' : 'inactive'}
        className={cn(
          'flex items-center justify-center',
          'w-10 h-7 rounded-full mb-0.5',
          'transition-colors duration-200',
          isActive
            ? 'bg-primary/15 text-primary motion-safe:animate-scale-in'
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
        {t(item.labelKey)}
      </span>
    </NavLink>
  )
}

export default BottomNav
