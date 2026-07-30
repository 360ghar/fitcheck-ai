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
  plus: {
    monthlyExtractions: 100,
    monthlyGenerations: 350,
    monthlyEmbeddings: 2000,
    dailyPhotoshootImages: 30,
  },
  pro: {
    monthlyExtractions: 200,
    monthlyGenerations: 1000,
    monthlyEmbeddings: 5000,
    dailyPhotoshootImages: 50,
  },
} as const

/** Display prices (USD). Stripe is the authoritative charge amount. */
export const PLAN_PRICES = {
  free: { monthly: 0, yearly: 0 },
  plus: { monthly: 10, yearly: 100 },
  pro: { monthly: 20, yearly: 200 },
} as const

/** Yearly savings vs paying monthly for 12 months. */
export function yearlySavings(plan: keyof typeof PLAN_PRICES): number {
  const p = PLAN_PRICES[plan]
  return p.monthly * 12 - p.yearly
}

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

/**
 * Feature bullets shared by every paid plan. Plus and Pro unlock the SAME
 * features — only the usage limits differ — so both lists are derived from
 * this one function to keep them from drifting apart.
 */
function paidPlanFeatureBullets(plan: 'plus' | 'pro'): string[] {
  const p = PLAN_LIMITS[plan]
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

/** Short marketing bullets for Plus plan (same features as Pro, lower limits) */
export function plusPlanFeatureBullets(): string[] {
  return paidPlanFeatureBullets('plus')
}

/** Short marketing bullets for Pro plan */
export function proPlanFeatureBullets(): string[] {
  return paidPlanFeatureBullets('pro')
}

/** FAQ-style plan comparison summary */
export function freeVsProSummary(): string {
  const f = PLAN_LIMITS.free
  const s = PLAN_LIMITS.plus
  const p = PLAN_LIMITS.pro
  return `Free includes ${f.monthlyExtractions} item extractions, ${f.monthlyGenerations} AI outfit visualizations, and ${f.dailyPhotoshootImages} photoshoot images per day. Plus ($${PLAN_PRICES.plus.monthly}/month) unlocks every paid feature — try-on, analytics, calendar planning, and priority support — with ${s.monthlyExtractions} extractions, ${s.monthlyGenerations} visualizations, and ${s.dailyPhotoshootImages} photoshoot images daily. Pro ($${PLAN_PRICES.pro.monthly}/month) has the same features at the highest limits: ${p.monthlyExtractions} extractions, ${p.monthlyGenerations.toLocaleString()} visualizations, and ${p.dailyPhotoshootImages} photoshoot images daily.`
}

export function platformsSummary(): string {
  return 'The web app works in any modern browser, and the Android app is on Google Play. iOS is on the waitlist — leave your email for updates.'
}
