import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type { components } from '@/shared/api/schema'

/**
 * Subscriptions feature fixtures + handlers (typed against
 * src/shared/api/schema.d.ts).
 *
 * AMOUNT UNITS MATTER: the backend list endpoint returns DISPLAY amounts
 * (major units, e.g. 19.99 — `plan_display_amount` in admin_service.py)
 * while AdminRefundResponse.amount is Stripe minor units (cents, e.g. 1999).
 * The fixtures encode both halves of that contract so tests cover the real
 * shapes: list rows carry 19.99, the refund response carries 1999.
 *
 * `createSubscriptionsHandlers()` returns a fresh state per call so tests
 * never leak mutations between cases.
 */

type AdminSubscriptionListItem = components['schemas']['AdminSubscriptionListItem']
type PageResponseSubscriptions = components['schemas']['PageResponse_AdminSubscriptionListItem_']
type AdminRefundResponse = components['schemas']['AdminRefundResponse']

export const adminSubscriptionListFixture: AdminSubscriptionListItem[] = [
  {
    id: 'sub_1',
    user_id: 'user_1',
    user: {
      email: 'alice@example.com',
      full_name: 'Alice Example',
    },
    plan_type: 'pro_monthly',
    status: 'active',
    // List amounts are DISPLAY dollars (backend plan_display_amount).
    amount: 19.99,
    currency: 'usd',
    billing_provider: 'stripe',
    stripe_customer_id: 'cus_1',
    cancel_at_period_end: false,
    current_period_start: '2026-07-10T00:00:00Z',
    current_period_end: '2026-08-10T00:00:00Z',
    created_at: '2026-07-10T00:00:00Z',
    updated_at: '2026-07-10T00:00:00Z',
  },
  {
    id: 'sub_2',
    user_id: 'user_2',
    user: {
      email: 'bob@example.com',
      full_name: null,
    },
    plan_type: 'plus_monthly',
    status: 'past_due',
    amount: 8.99,
    currency: 'usd',
    billing_provider: 'stripe',
    stripe_customer_id: 'cus_2',
    cancel_at_period_end: true,
    current_period_start: '2026-06-01T00:00:00Z',
    current_period_end: '2026-07-01T00:00:00Z',
    created_at: '2026-06-01T00:00:00Z',
    updated_at: '2026-07-02T00:00:00Z',
  },
  {
    id: 'sub_3',
    user_id: 'user_3',
    user: {
      email: 'carol@example.com',
      full_name: 'Carol Example',
    },
    plan_type: 'plus_yearly',
    status: 'active',
    amount: null,
    billing_provider: 'apple',
    apple_original_transaction_id: '1000000000000001',
    billing_product_id: 'plus_yearly_ios',
    cancel_at_period_end: false,
    current_period_start: '2026-01-01T00:00:00Z',
    current_period_end: '2027-01-01T00:00:00Z',
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-01-01T00:00:00Z',
  },
  {
    id: 'sub_4',
    user_id: 'user_4',
    user: {
      email: 'dave@example.com',
      full_name: 'Dave Example',
    },
    plan_type: 'pro_monthly',
    status: 'active',
    amount: 19.99,
    currency: 'usd',
    billing_provider: 'google',
    google_order_id: 'GPA.3300-1111-2222',
    google_purchase_token: 'token_google_4444',
    billing_product_id: 'pro_monthly_android',
    cancel_at_period_end: false,
    current_period_start: '2026-07-01T00:00:00Z',
    current_period_end: '2026-08-01T00:00:00Z',
    created_at: '2026-07-01T00:00:00Z',
    updated_at: '2026-07-01T00:00:00Z',
  },
]

export interface SubscriptionsHandlersState {
  subscriptions: AdminSubscriptionListItem[]
  /** Every list/refund request URL, for test assertions */
  requests: URL[]
  /** Last refund body target user id, for test assertions */
  lastRefundUserId: string | null
}

function defaultState(): SubscriptionsHandlersState {
  return {
    subscriptions: structuredClone(adminSubscriptionListFixture),
    requests: [],
    lastRefundUserId: null,
  }
}

function paginate<T>(
  items: T[],
  page: number,
  pageSize: number,
): PageResponseSubscriptions {
  const start = (page - 1) * pageSize
  return {
    items: items.slice(start, start + pageSize) as AdminSubscriptionListItem[],
    total: items.length,
    page,
    page_size: pageSize,
  }
}

export function createSubscriptionsHandlers(initial?: Partial<SubscriptionsHandlersState>) {
  const state: SubscriptionsHandlersState = { ...defaultState(), ...initial }
  const { subscriptions, requests } = state

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/subscriptions', ({ request }) => {
      const url = new URL(request.url)
      requests.push(url)
      const params = url.searchParams
      const plan = params.get('plan')
      const status = params.get('status')
      // Mirrors the backend: billing_provider=stripe includes legacy NULL rows.
      const provider = params.get('billing_provider')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const rows = subscriptions.filter((row) => {
        if (plan && row.plan_type !== plan) return false
        if (status && row.status !== status) return false
        if (provider) {
          const bp = row.billing_provider ?? 'stripe'
          if (bp !== provider) return false
        }
        return true
      })

      return HttpResponse.json(paginate(rows, page, pageSize))
    }),

    http.get('*/api/v1/admin/subscriptions/user/:userId', ({ request, params }) => {
      const url = new URL(request.url)
      requests.push(url)
      const userId = String(params.userId)
      const row = subscriptions.find((sub) => sub.user_id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'No subscription found for user', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      return HttpResponse.json({ subscription: row, user: row.user ?? {}, usage: {} })
    }),

    http.post('*/api/v1/admin/subscriptions/user/:userId/refund', ({ params }) => {
      const userId = String(params.userId)
      state.lastRefundUserId = userId
      const row = subscriptions.find((sub) => sub.user_id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'No subscription found for user', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      // A8-05: mirror the backend — only Stripe-billed rows are refundable.
      const provider = row.billing_provider ?? 'stripe'
      if (provider !== 'stripe' || !row.stripe_customer_id) {
        return HttpResponse.json(
          {
            error: 'This subscription has no Stripe customer; only Stripe-billed rows are refundable here',
            code: 'VALIDATION_ERROR',
            details: { user_id: userId, billing_provider: provider },
          },
          { status: 422 },
        )
      }
      // AdminSubscriptionListItem has no `currency` key in the schema (extra
      // keys are `unknown`), so guard before using it.
      const currency = typeof row.currency === 'string' ? row.currency : 'usd'
      const refund: AdminRefundResponse = {
        refund_id: 're_123',
        // AdminRefundResponse.amount is Stripe minor units (cents) — the
        // display-dollar fixture converts back to cents here.
        amount: Math.round((row.amount ?? 0) * 100),
        currency,
        status: 'succeeded',
        payment_intent: 'pi_123',
        charge_id: 'ch_123',
      }
      return HttpResponse.json(refund)
    }),
  ]

  return { handlers, state }
}

/** Pre-built handlers for quick `server.use(...subscriptionsHandlers)` usage. */
export const subscriptionsHandlers = createSubscriptionsHandlers().handlers
