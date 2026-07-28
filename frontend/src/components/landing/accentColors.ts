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

export const ACCENT_CLASSES: Record<AccentColor, AccentClasses> = {
  orange: {
    text100: 'text-orange-100',
    text200: 'text-orange-200',
    iconBg: 'bg-orange-100 dark:bg-orange-900/50',
    iconText: 'text-orange-600 dark:text-orange-400',
    cardHoverBorder: 'hover:border-orange-200 dark:hover:border-orange-800',
  },
  indigo: {
    text100: 'text-indigo-100',
    text200: 'text-indigo-200',
    iconBg: 'bg-indigo-100 dark:bg-indigo-900/50',
    iconText: 'text-indigo-600 dark:text-indigo-400',
    cardHoverBorder: 'hover:border-indigo-200 dark:hover:border-indigo-800',
  },
  emerald: {
    text100: 'text-emerald-100',
    text200: 'text-emerald-200',
    iconBg: 'bg-emerald-100 dark:bg-emerald-900/50',
    iconText: 'text-emerald-600 dark:text-emerald-400',
    cardHoverBorder: 'hover:border-emerald-200 dark:hover:border-emerald-800',
  },
  purple: {
    text100: 'text-purple-100',
    text200: 'text-purple-200',
    iconBg: 'bg-purple-100 dark:bg-purple-900/50',
    iconText: 'text-purple-600 dark:text-purple-400',
    cardHoverBorder: 'hover:border-purple-200 dark:hover:border-purple-800',
  },
  blue: {
    text100: 'text-blue-100',
    text200: 'text-blue-200',
    iconBg: 'bg-blue-100 dark:bg-blue-900/50',
    iconText: 'text-blue-600 dark:text-blue-400',
    cardHoverBorder: 'hover:border-blue-200 dark:hover:border-blue-800',
  },
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
