/**
 * First-month-free Pro trial offer (marketing-only).
 *
 * The offer is delivered through the existing promo-code machinery: landing
 * CTAs link to /auth/register?promo=TRIAL_PROMO_CODE, RegisterPage stashes the
 * code, and the plan page redeems it after signup. No backend changes.
 *
 * Keep this in sync with the live `promo_codes` row created via
 * backend/scripts/create_promo_code.py. If the code is retired or replaced,
 * update TRIAL_PROMO_CODE here and the copy stays correct everywhere.
 */

export const TRIAL_PROMO_CODE = 'TRYPRO'

/** CTA href that carries the trial promo into registration. */
export function trialRegisterHref(): string {
  return `/auth/register?promo=${TRIAL_PROMO_CODE}`
}

/** CTA href for a paid plan card that also carries the trial promo. */
export function trialPlanHref(planType: 'plus' | 'pro', isYearly: boolean): string {
  return `/auth/register?plan_type=${planType}_${isYearly ? 'yearly' : 'monthly'}&promo=${TRIAL_PROMO_CODE}`
}
