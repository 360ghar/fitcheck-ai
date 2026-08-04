/**
 * Subscription store using Zustand
 * Manages subscription status, usage limits, and referral data
 */

import { create } from 'zustand';
import type {
  UsageLimits,
  ReferralCode,
  ReferralStats,
  PlanType,
  Subscription,
  PlansResponse,
  ValidatePromoResponse,
  RedeemPromoResponse,
} from '../types';
import * as subscriptionApi from '../api/subscription';
import { logger } from '../lib/logger';
import { getApiError } from '../lib/errors';
import {
  request as cacheRequest,
  invalidateRequest,
  clearRequestCache,
  __requestCacheInternals,
} from '../lib/requestCache';
import { getAccessToken } from '../lib/auth';

// ============================================================================
// REQUEST CACHE KEYS
// ============================================================================

/**
 * Stable, user-scoped cache keys for subscription/referral reads. Multiple
 * components (dashboard referral banner, profile SubscriptionPanel) request
 * the same resources; coalescing + freshness make them share one request.
 */
const subKey = (resource: string) => `subscription:${resource}:${getAccessToken() || 'anon'}`
const referralKey = (resource: string) => `referral:${resource}:${getAccessToken() || 'anon'}`

/** Freshness: subscription data changes rarely; 60s is safe and cuts refetch churn. */
const SUB_FRESHNESS_MS = 60_000

/**
 * Drop cached subscription reads (subscription/usage/plans) for the current
 * user. Call after entitlement-changing mutations (checkout, cancel, redeem).
 */
function invalidateSubscriptionDomain(): void {
  const userId = getAccessToken() || 'anon'
  const { cachedKeys, inFlightKeys } = __requestCacheInternals.debugSnapshot()
  for (const key of [...cachedKeys, ...inFlightKeys]) {
    if (key.startsWith(`subscription:`) && key.endsWith(`:${userId}`)) {
      invalidateRequest(key)
    }
  }
}

/** Clear all subscription/referral request-cache entries (logout / user switch). */
export function resetSubscriptionRequestCache(): void {
  clearRequestCache()
}

// ============================================================================
// SUBSCRIPTION STATE INTERFACE
// ============================================================================

interface SubscriptionState {
  // State
  subscription: Subscription | null;
  usage: UsageLimits | null;
  referralCode: ReferralCode | null;
  referralStats: ReferralStats | null;
  plans: PlansResponse | null;
  isLoading: boolean;
  isCheckingOut: boolean;
  error: string | null;

  // Promo code state
  promoValidation: ValidatePromoResponse | null;
  isPromoValidating: boolean;
  isRedeemingPromo: boolean;
  promoError: string | null;

  // Actions
  fetchSubscription: () => Promise<void>;
  fetchUsage: () => Promise<void>;
  fetchPlans: () => Promise<void>;
  fetchReferralCode: () => Promise<void>;
  fetchReferralStats: () => Promise<void>;
  startCheckout: (planType: PlanType) => Promise<void>;
  openBillingPortal: () => Promise<void>;
  cancelSubscription: () => Promise<void>;
  copyReferralLink: () => Promise<boolean>;
  validatePromo: (code: string) => Promise<ValidatePromoResponse | null>;
  redeemPromo: (code: string) => Promise<RedeemPromoResponse | null>;
  clearPromo: () => void;
  clearError: () => void;
  reset: () => void;
}

// ============================================================================
// INITIAL STATE
// ============================================================================

const initialState = {
  subscription: null,
  usage: null,
  referralCode: null,
  referralStats: null,
  plans: null,
  isLoading: false,
  isCheckingOut: false,
  error: null,
  promoValidation: null,
  isPromoValidating: false,
  isRedeemingPromo: false,
  promoError: null,
};

// ============================================================================
// SUBSCRIPTION STORE
// ============================================================================

export const useSubscriptionStore = create<SubscriptionState>()((set, get) => ({
  ...initialState,

  // Fetch subscription with usage
  fetchSubscription: async () => {
    set({ isLoading: true, error: null });
    try {
      const data = await cacheRequest(
        subKey('subscription'),
        () => subscriptionApi.getSubscription(),
        { freshnessMs: SUB_FRESHNESS_MS, label: 'subscription.fetchSubscription' }
      );
      set({
        subscription: data.subscription,
        usage: data.usage,
        isLoading: false,
      });
    } catch (error) {
      const message = getApiError(error).message || 'Failed to fetch subscription';
      set({ isLoading: false, error: message });
    }
  },

  // Fetch just usage (for lightweight updates)
  fetchUsage: async () => {
    try {
      const usage = await cacheRequest(
        subKey('usage'),
        () => subscriptionApi.getUsage(),
        { freshnessMs: SUB_FRESHNESS_MS, label: 'subscription.fetchUsage' }
      );
      set({ usage });
    } catch (error) {
      logger.error('Failed to fetch usage:', error);
    }
  },

  // Fetch available plans
  fetchPlans: async () => {
    try {
      const plans = await cacheRequest(
        subKey('plans'),
        () => subscriptionApi.getPlans(),
        { freshnessMs: SUB_FRESHNESS_MS, label: 'subscription.fetchPlans' }
      );
      set({ plans });
    } catch (error) {
      logger.error('Failed to fetch plans:', error);
    }
  },

  // Fetch referral code
  fetchReferralCode: async () => {
    try {
      const referralCode = await cacheRequest(
        referralKey('code'),
        () => subscriptionApi.getReferralCode(),
        { freshnessMs: SUB_FRESHNESS_MS, label: 'subscription.fetchReferralCode' }
      );
      set({ referralCode });
    } catch (error) {
      logger.error('Failed to fetch referral code:', error);
    }
  },

  // Fetch referral stats
  fetchReferralStats: async () => {
    try {
      const referralStats = await cacheRequest(
        referralKey('stats'),
        () => subscriptionApi.getReferralStats(),
        { freshnessMs: SUB_FRESHNESS_MS, label: 'subscription.fetchReferralStats' }
      );
      set({ referralStats });
    } catch (error) {
      logger.error('Failed to fetch referral stats:', error);
    }
  },

  // Start Stripe checkout
  startCheckout: async (planType: PlanType) => {
    set({ isCheckingOut: true, error: null });
    try {
      const successUrl = `${window.location.origin}/profile?tab=plan&success=true`;
      const cancelUrl = `${window.location.origin}/profile?tab=plan&cancelled=true`;

      const session = await subscriptionApi.createCheckoutSession(
        planType,
        successUrl,
        cancelUrl
      );

      if (session.updated) {
        // Entitlement changed server-side; drop the cache so fetchSubscription
        // re-reads instead of serving the pre-checkout snapshot.
        invalidateSubscriptionDomain();
        await get().fetchSubscription();
        // fetchSubscription swallows its own failure into store `error`;
        // surface it so the caller (upgrade prompt) does not silently
        // resolve with stale subscription state.
        const fetchError = get().error;
        if (fetchError) {
          throw new Error(fetchError);
        }
        set({ isCheckingOut: false });
        return;
      }

      if (!session.checkout_url) {
        throw new Error('Checkout did not return a redirect URL');
      }
      // Redirect to Stripe Checkout for a new subscription.
      window.location.href = session.checkout_url;
    } catch (error) {
      const message = getApiError(error).message || 'Failed to start checkout';
      set({ isCheckingOut: false, error: message });
      throw error;
    }
  },

  // Open Stripe billing portal
  openBillingPortal: async () => {
    set({ isLoading: true, error: null });
    try {
      const returnUrl = `${window.location.origin}/profile?tab=plan`;
      const session = await subscriptionApi.createPortalSession(returnUrl);
      window.location.href = session.portal_url;
    } catch (error) {
      const message = getApiError(error).message || 'Failed to open billing portal';
      set({ isLoading: false, error: message });
      throw error;
    }
  },

  // Cancel subscription
  cancelSubscription: async () => {
    set({ isLoading: true, error: null });
    try {
      const subscription = await subscriptionApi.cancelSubscription();
      invalidateSubscriptionDomain();
      set({ subscription, isLoading: false });
    } catch (error) {
      const message = getApiError(error).message || 'Failed to cancel subscription';
      set({ isLoading: false, error: message });
      throw error;
    }
  },

  // Copy referral link to clipboard
  copyReferralLink: async () => {
    const { referralCode } = get();
    if (!referralCode?.share_url) {
      // Fetch if not loaded
      await get().fetchReferralCode();
    }

    const code = get().referralCode;
    if (code?.share_url) {
      try {
        await navigator.clipboard.writeText(code.share_url);
        return true;
      } catch {
        return false;
      }
    }
    return false;
  },

  // Validate a promo code (public, non-mutating)
  validatePromo: async (code: string) => {
    set({ isPromoValidating: true, promoError: null, promoValidation: null });
    try {
      const promoValidation = await subscriptionApi.validatePromoCode(code);
      set({ promoValidation, isPromoValidating: false });
      return promoValidation;
    } catch (error) {
      const message = getApiError(error).message || 'Failed to validate promo code';
      set({ isPromoValidating: false, promoError: message });
      return null;
    }
  },

  // Redeem a promo code for the current user; refreshes the subscription on
  // success so the plan card and upgrade offers reflect the new entitlement.
  redeemPromo: async (code: string) => {
    set({ isRedeemingPromo: true, promoError: null });
    try {
      const result = await subscriptionApi.redeemPromoCode(code);
      if (result.success) {
        set({ promoValidation: null, isRedeemingPromo: false });
        // Entitlement changed; force a fresh read.
        invalidateSubscriptionDomain();
        await get().fetchSubscription();
      } else {
        set({
          isRedeemingPromo: false,
          promoError: result.message || 'This promo code could not be applied',
        });
      }
      return result;
    } catch (error) {
      const message = getApiError(error).message || 'Failed to redeem promo code';
      set({ isRedeemingPromo: false, promoError: message });
      return null;
    }
  },

  // Clear promo validation state (e.g. after a successful redemption)
  clearPromo: () => {
    set({ promoValidation: null, isPromoValidating: false, isRedeemingPromo: false, promoError: null });
  },

  // Clear error
  clearError: () => {
    set({ error: null });
  },

  // Reset store (on logout)
  reset: () => {
    set(initialState);
    // Drop every cached subscription/referral read so the next user cannot
    // reuse the previous user's cached data.
    clearRequestCache();
  },
}));

// ============================================================================
// SELECTORS
// ============================================================================

export const selectSubscription = (state: SubscriptionState) => state.subscription;
export const selectUsage = (state: SubscriptionState) => state.usage;
export const selectReferralCode = (state: SubscriptionState) => state.referralCode;
export const selectIsLoading = (state: SubscriptionState) => state.isLoading;
export const selectError = (state: SubscriptionState) => state.error;
/**
 * True for any paid plan. Plus unlocks the same features as Pro (only the
 * usage limits differ), so it counts as entitled here — matching the
 * backend's SubscriptionService.is_paid_plan.
 */
export const selectIsPro = (state: SubscriptionState) =>
  state.subscription?.plan_type === 'plus_monthly' ||
  state.subscription?.plan_type === 'plus_yearly' ||
  state.subscription?.plan_type === 'pro_monthly' ||
  state.subscription?.plan_type === 'pro_yearly';

/**
 * True only for the top Pro tier. Distinct from `selectIsPro` (paid
 * entitlement): a Plus user has paid features but can still upgrade to Pro.
 */
export const selectIsProTier = (state: SubscriptionState) =>
  state.subscription?.plan_type === 'pro_monthly' ||
  state.subscription?.plan_type === 'pro_yearly';

/**
 * True when a higher tier exists to upsell (Free and Plus users).
 * Distinct from `selectIsPro`: a Plus user HAS paid features but can still
 * upgrade to Pro, so gating an upgrade CTA on `!isPro` would strand them.
 * An unknown subscription (still null) is NOT upgradeable — the backend
 * auto-creates a `free` row, so a real Free user still gets true here.
 */
export const selectCanUpgrade = (state: SubscriptionState) =>
  state.subscription != null &&
  state.subscription.plan_type !== 'pro_monthly' &&
  state.subscription.plan_type !== 'pro_yearly';

// ============================================================================
// HOOKS
// ============================================================================

/**
 * Hook to get subscription data
 */
export function useSubscription() {
  return useSubscriptionStore(selectSubscription);
}

/**
 * Hook to get usage data
 */
export function useUsage() {
  return useSubscriptionStore(selectUsage);
}

/**
 * Hook to check if user is on Pro plan
 */
export function useIsPro() {
  return useSubscriptionStore(selectIsPro);
}

/**
 * Hook to check whether the user is on the top Pro tier (badges/CTA gating).
 * A Plus user is paid (selectIsPro) but is not Pro-tier.
 */
export function useIsProTier() {
  return useSubscriptionStore(selectIsProTier);
}

/**
 * Hook to check whether a higher tier is available to upsell
 */
export function useCanUpgrade() {
  return useSubscriptionStore(selectCanUpgrade);
}

/**
 * Hook to get referral code
 */
export function useReferralCode() {
  return useSubscriptionStore(selectReferralCode);
}

/**
 * Hook to get plan name for display
 */
export function usePlanName(): string {
  const subscription = useSubscription();
  if (!subscription) return 'Free';
  switch (subscription.plan_type) {
    case 'plus_monthly':
      return 'Plus (Monthly)';
    case 'plus_yearly':
      return 'Plus (Yearly)';
    case 'pro_monthly':
      return 'Pro (Monthly)';
    case 'pro_yearly':
      return 'Pro (Yearly)';
    default:
      return 'Free';
  }
}

/**
 * Hook to check if user is near usage limit (>80%)
 */
export function useIsNearLimit(): { extractions: boolean; generations: boolean } {
  const usage = useUsage();
  if (!usage) return { extractions: false, generations: false };

  const extractionPercent = (usage.monthly_extractions / usage.monthly_extractions_limit) * 100;
  const generationPercent = (usage.monthly_generations / usage.monthly_generations_limit) * 100;

  return {
    extractions: extractionPercent >= 80,
    generations: generationPercent >= 80,
  };
}
