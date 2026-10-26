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
  Gift,
} from 'lucide-react'
import { FEATURES } from '@/lib/feature-flags'

export interface NavItem {
  /** Message id for the visible name. Resolved with `t()` at render, never here. */
  labelKey: string
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
 *
 * Labels are message ids, not English text: this array is built once at module
 * scope, and resolving a translation here would freeze the nav in whatever
 * language happened to be active at import time. The sidebar resolves
 * `labelKey` per render so a language switch repaints the nav.
 */
const ALL_NAV_ITEMS: NavItem[] = [
  { labelKey: 'nav.dashboard', href: '/dashboard', icon: LayoutDashboard },
  { labelKey: 'nav.photoshoot', href: '/photoshoot', icon: Camera },
  { labelKey: 'nav.closet', href: '/wardrobe', icon: Shirt },
  { labelKey: 'nav.outfits', href: '/outfits', icon: Layers },
  { labelKey: 'nav.tryOn', href: '/try-on', icon: Wand2 },
  { labelKey: 'nav.calendar', href: '/calendar', icon: Calendar },
  { labelKey: 'nav.recommendations', href: '/recommendations', icon: Sparkles },
  { labelKey: 'nav.giftPro', href: '/gifts', icon: Gift },
  { labelKey: 'nav.gamification', href: '/gamification', icon: Flame },
]

/**
 * The nav as rendered. Filtered once at module scope, not per render, so both
 * consumers (`Sidebar`, `SidebarMobile`) stay untouched and cannot disagree.
 */
export const navigationItems: NavItem[] = ALL_NAV_ITEMS.filter(
  (item) =>
    (item.href !== '/gamification' || FEATURES.gamification) &&
    (item.href !== '/gifts' || FEATURES.gifts),
)
