import type { LucideIcon } from 'lucide-react'
import {
  LayoutDashboard,
  Shirt,
  Layers,
  Camera,
  Calendar,
  Sparkles,
  Flame,
} from 'lucide-react'

export interface NavItem {
  name: string
  href: string
  icon: LucideIcon
  badge?: string | number
}

export const navigationItems: NavItem[] = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Wardrobe', href: '/wardrobe', icon: Shirt },
  { name: 'Outfits', href: '/outfits', icon: Layers },
  { name: 'Try On', href: '/try-on', icon: Camera },
  { name: 'Calendar', href: '/calendar', icon: Calendar },
  { name: 'Recommendations', href: '/recommendations', icon: Sparkles },
  { name: 'Gamification', href: '/gamification', icon: Flame },
]
