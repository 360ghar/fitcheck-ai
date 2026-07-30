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
} from '../types';
import * as subscriptionApi from '../api/subscription';
import { logger } from '../lib/logger';
import { getApiError } from '../lib/errors';

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
      const data = await subscriptionApi.getSubscription();
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
      const usage = await subscriptionApi.getUsage();
      set({ usage });
    } catch (error) {
      logger.error('Failed to fetch usage:', error);
    }
  },

  // Fetch available plans
  fetchPlans: async () => {
    try {
      const plans = await subscriptionApi.getPlans();
      set({ plans });
    } catch (error) {
      logger.error('Failed to fetch plans:', error);
    }
  },

  // Fetch referral code
  fetchReferralCode: async () => {
    try {
      const referralCode = await subscriptionApi.getReferralCode();
      set({ referralCode });
    } catch (error) {
      logger.error('Failed to fetch referral code:', error);
    }
  },

  // Fetch referral stats
  fetchReferralStats: async () => {
    try {
      const referralStats = await subscriptionApi.getReferralStats();
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

      // Redirect to Stripe Checkout
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

  // Clear error
  clearError: () => {
    set({ error: null });
  },

  // Reset store (on logout)
  reset: () => {
    set(initialState);
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
 * True when a higher tier exists to upsell (Free and Plus users).
 * Distinct from `selectIsPro`: a Plus user HAS paid features but can still
 * upgrade to Pro, so gating an upgrade CTA on `!isPro` would strand them.
 */
export const selectCanUpgrade = (state: SubscriptionState) =>
  state.subscription?.plan_type !== 'pro_monthly' &&
  state.subscription?.plan_type !== 'pro_yearly';

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
