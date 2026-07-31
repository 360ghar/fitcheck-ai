import type { LucideIcon } from 'lucide-react'
import {
  LayoutDashboard,
  Camera,
  Shirt,
  Layers,
  Calendar,
  Sparkles,
  Flame,
  Wand2,
} from 'lucide-react'
import { FEATURES } from '@/lib/feature-flags'

export interface NavItem {
  name: string
  href: string
  icon: LucideIcon
  badge?: string | number
}

/**
 * Every nav destination the app knows about, flag-gated or not.
 *
 * The gamification entry stays declared here rather than being deleted, so
 * turning `VITE_ENABLE_GAMIFICATION=true` back on needs no code edit — only an
 * env change and a rebuild.
 */
const ALL_NAV_ITEMS: NavItem[] = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Photoshoot', href: '/photoshoot', icon: Camera },
  { name: 'Closet', href: '/wardrobe', icon: Shirt },
  { name: 'Outfits', href: '/outfits', icon: Layers },
  { name: 'Try On', href: '/try-on', icon: Wand2 },
  { name: 'Calendar', href: '/calendar', icon: Calendar },
  { name: 'Recommendations', href: '/recommendations', icon: Sparkles },
  { name: 'Gamification', href: '/gamification', icon: Flame },
]

/**
 * The nav as rendered. Filtered once at module scope, not per render, so both
 * consumers (`Sidebar`, `SidebarMobile`) stay untouched and cannot disagree.
 */
export const navigationItems: NavItem[] = ALL_NAV_ITEMS.filter(
  (item) => item.href !== '/gamification' || FEATURES.gamification,
)
