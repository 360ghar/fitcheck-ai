/**
 * Subscription and Referral API endpoints
 */

import { apiClient, getApiError } from './client'
import type {
  ApiEnvelope,
  SubscriptionWithUsage,
  UsageLimits,
  ReferralCode,
  ReferralStats,
  ValidateReferralResponse,
  RedeemReferralResponse,
  CheckoutSession,
  PortalSession,
  PlansResponse,
  Subscription,
  PlanType,
} from '../types'

// ============================================================================
// SUBSCRIPTION ENDPOINTS
// ============================================================================

/**
 * Get current user's subscription status and usage
 */
export async function getSubscription(): Promise<SubscriptionWithUsage> {
  try {
    const response = await apiClient.get<ApiEnvelope<SubscriptionWithUsage>>('/api/v1/subscription')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get detailed monthly usage statistics
 */
export async function getUsage(): Promise<UsageLimits> {
  try {
    const response = await apiClient.get<ApiEnvelope<UsageLimits>>('/api/v1/subscription/usage')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get available subscription plans and pricing
 */
export async function getPlans(): Promise<PlansResponse> {
  try {
    const response = await apiClient.get<ApiEnvelope<PlansResponse>>('/api/v1/subscription/plans')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Create a Stripe Checkout session for upgrading to Pro
 */
export async function createCheckoutSession(
  planType: PlanType,
  successUrl: string,
  cancelUrl: string
): Promise<CheckoutSession> {
  try {
    const response = await apiClient.post<ApiEnvelope<CheckoutSession>>('/api/v1/subscription/checkout', {
      plan_type: planType,
      success_url: successUrl,
      cancel_url: cancelUrl,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Create a Stripe Customer Portal session for managing subscription
 */
export async function createPortalSession(returnUrl?: string): Promise<PortalSession> {
  try {
    const response = await apiClient.post<ApiEnvelope<PortalSession>>('/api/v1/subscription/portal', null, {
      params: returnUrl ? { return_url: returnUrl } : undefined,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Cancel subscription at the end of the current billing period
 */
export async function cancelSubscription(): Promise<Subscription> {
  try {
    const response = await apiClient.post<ApiEnvelope<Subscription>>('/api/v1/subscription/cancel')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

// ============================================================================
// REFERRAL ENDPOINTS
// ============================================================================

/**
 * Get the current user's referral code
 */
export async function getReferralCode(): Promise<ReferralCode> {
  try {
    const response = await apiClient.get<ApiEnvelope<ReferralCode>>('/api/v1/referral/code')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get detailed referral statistics
 */
export async function getReferralStats(): Promise<ReferralStats> {
  try {
    const response = await apiClient.get<ApiEnvelope<ReferralStats>>('/api/v1/referral/stats')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Validate a referral code without redeeming it
 * This is a public endpoint for use during signup
 */
export async function validateReferralCode(code: string): Promise<ValidateReferralResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<ValidateReferralResponse>>('/api/v1/referral/validate', {
      code,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Redeem a referral code
 * Applies credits to both the current user and the referrer
 */
export async function redeemReferral(referralCode: string): Promise<RedeemReferralResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<RedeemReferralResponse>>('/api/v1/referral/redeem', {
      referral_code: referralCode,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}
