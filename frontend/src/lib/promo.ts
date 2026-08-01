/**
 * Promo code helpers shared across the auth pages and the plan page.
 */

/**
 * localStorage key for a promo code stashed by the register/login page so it
 * survives the Google OAuth round-trip (same pattern as `pending_referral_code`).
 * The plan page (`/profile?tab=plan`) consumes it once on mount.
 */
export const PENDING_PROMO_KEY = "pending_promo_code";

/** Human-readable plan name from a plan variant ("pro_monthly" -> "Pro"). */
export const planDisplayName = (planType?: string | null): string =>
  planType?.startsWith("pro")
    ? "Pro"
    : planType?.startsWith("plus")
      ? "Plus"
      : "your new plan";

/** Persist a promo code so it survives the auth round-trip. */
export const stashPromoCode = (code: string | null | undefined): void => {
  const trimmed = (code || "").trim();
  if (trimmed.length >= 3) {
    localStorage.setItem(PENDING_PROMO_KEY, trimmed);
  }
};
