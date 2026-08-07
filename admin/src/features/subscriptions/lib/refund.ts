import { isApiError } from '@/shared/api/errors'

/**
 * Refund failure → i18n key mapping (subscriptions namespace).
 *
 * Backend error codes (app/core/exceptions.py):
 *   BILLING_NOT_CONFIGURED — Stripe not configured for this deployment (503)
 *   NOT_FOUND             — no subscription for this user (404)
 *   VALIDATION_ERROR      — subscription has no Stripe customer (422,
 *                           e.g. store-billed rows)
 *   SERVICE_UNAVAILABLE   — Stripe call failed (503)
 */
const REFUND_ERROR_KEYS: Record<string, string> = {
  BILLING_NOT_CONFIGURED: 'refund.errorBillingNotConfigured',
  NOT_FOUND: 'refund.errorNotFound',
  VALIDATION_ERROR: 'refund.errorNoStripeCustomer',
  SERVICE_UNAVAILABLE: 'refund.errorGeneric',
}

export function refundErrorKey(error: unknown): string {
  if (!isApiError(error)) return 'refund.errorGeneric'
  return REFUND_ERROR_KEYS[error.code] ?? 'refund.errorGeneric'
}

/** Pull the joined user's email out of a list item (schema: `user.email`). */
export function subscriptionUserEmail(
  user: { [key: string]: unknown } | null | undefined,
): string | undefined {
  if (!user || typeof user !== 'object') return undefined
  const email = user['email']
  return typeof email === 'string' && email.length > 0 ? email : undefined
}
