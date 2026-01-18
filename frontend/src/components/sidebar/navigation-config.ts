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

export interface NavItem {
  name: string
  href: string
  icon: LucideIcon
  badge?: string | number
}

export const navigationItems: NavItem[] = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Photoshoot', href: '/photoshoot', icon: Camera },
  { name: 'Wardrobe', href: '/wardrobe', icon: Shirt },
  { name: 'Outfits', href: '/outfits', icon: Layers },
  { name: 'Try On', href: '/try-on', icon: Wand2 },
  { name: 'Calendar', href: '/calendar', icon: Calendar },
  { name: 'Recommendations', href: '/recommendations', icon: Sparkles },
  { name: 'Gamification', href: '/gamification', icon: Flame },
]
