/**
 * Single source of truth for plan limits and platform availability
 * shown in marketing copy, FAQ, pricing, and settings.
 *
 * Keep in sync with backend/app/core/config.py PLAN_* settings.
 */

export const PLAN_LIMITS = {
  free: {
    monthlyExtractions: 25,
    monthlyGenerations: 50,
    monthlyEmbeddings: 200,
    dailyPhotoshootImages: 10,
  },
  pro: {
    monthlyExtractions: 200,
    monthlyGenerations: 1000,
    monthlyEmbeddings: 5000,
    dailyPhotoshootImages: 50,
  },
} as const

export const PLATFORM_AVAILABILITY = {
  web: true,
  android: true,
  ios: 'waitlist' as const,
  androidStoreUrl:
    'https://play.google.com/store/apps/details?id=com.fitcheckaiapp.fitcheckai&hl=en_IN',
}

/** Short marketing bullets for Free plan */
export function freePlanFeatureBullets(): string[] {
  const f = PLAN_LIMITS.free
  return [
    `${f.monthlyExtractions} item extractions/month`,
    `${f.monthlyGenerations} outfit visualizations/month`,
    `${f.dailyPhotoshootImages} AI photoshoot images/day`,
    'Basic wardrobe management',
    'Weather-based suggestions',
    'Web + Android app',
  ]
}

/** Short marketing bullets for Pro plan */
export function proPlanFeatureBullets(): string[] {
  const p = PLAN_LIMITS.pro
  return [
    `${p.monthlyExtractions} item extractions/month`,
    `${p.monthlyGenerations.toLocaleString()} outfit visualizations/month`,
    `${p.dailyPhotoshootImages} AI photoshoot images/day`,
    'Virtual try-on visualization',
    'Advanced wardrobe analytics',
    'Calendar planning',
    'Priority support',
    'AI style recommendations',
    'Early access to new features',
  ]
}

/** FAQ-style free vs pro summary */
export function freeVsProSummary(): string {
  const f = PLAN_LIMITS.free
  const p = PLAN_LIMITS.pro
  return `Free includes ${f.monthlyExtractions} item extractions, ${f.monthlyGenerations} AI outfit visualizations, and ${f.dailyPhotoshootImages} photoshoot images per day. Pro raises those limits to ${p.monthlyExtractions} extractions, ${p.monthlyGenerations.toLocaleString()} visualizations, and ${p.dailyPhotoshootImages} photoshoot images daily, plus higher-capacity try-on, analytics, calendar planning, and priority support.`
}

export function platformsSummary(): string {
  return 'The web app works in any modern browser, and the Android app is on Google Play. iOS is on the waitlist — leave your email for updates.'
}
