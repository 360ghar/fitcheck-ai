import type { LucideIcon } from 'lucide-react'

/**
 * Accent color keys supported across the public feature landing pages.
 * Each page picks one accent that drives hero copy, icon chips, card hover
 * borders, and CTA text. Classes are spelled out statically so Tailwind's
 * JIT can detect them.
 */
export type AccentColor = 'orange' | 'indigo' | 'emerald' | 'purple' | 'blue'

export interface AccentClasses {
  /** Light tint used for hero subtitles and CTA subtext (`{color}-100`). */
  text100: string
  /** Slightly deeper tint used for hero descriptions and CTA footnotes (`{color}-200`). */
  text200: string
  /** Background for icon chips in benefit/stat cards. */
  iconBg: string
  /** Foreground color for icons in benefit/stat cards. */
  iconText: string
  /** Hover border color for benefit cards. */
  cardHoverBorder: string
}

const wardrobeStudioAccent: AccentClasses = {
  text100: 'text-white/90',
  text200: 'text-white/70',
  iconBg: 'bg-secondary',
  iconText: 'text-primary',
  cardHoverBorder: 'hover:border-primary/40',
}

// Feature pages previously used an unrelated accent per route. Keep the
// public prop for compatibility while mapping all non-semantic decoration to
// the one Wardrobe Studio visual language.
export const ACCENT_CLASSES: Record<AccentColor, AccentClasses> = {
  orange: wardrobeStudioAccent,
  indigo: wardrobeStudioAccent,
  emerald: wardrobeStudioAccent,
  purple: wardrobeStudioAccent,
  blue: wardrobeStudioAccent,
}

export interface CTAButton {
  text: string
  to: string
}

export interface BenefitItem {
  icon: LucideIcon
  title: string
  description: string
}
