import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type { components } from '@/shared/api/schema'

/**
 * IAP transactions fixtures + handlers (typed against
 * src/shared/api/schema.d.ts).
 *
 * The detail + mark-refunded endpoints return untyped dicts in the generated
 * schema; the local detail fixture mirrors the backend `_iap_item` shape.
 * One fixture row has NO provider transaction id (store-billed) to exercise
 * the dialog's explicit "no provider transaction id" state.
 *
 * `createIapHandlers()` returns a fresh state per call so tests never leak
 * mutations between cases.
 */

type AdminIapTransactionListItem = components['schemas']['AdminIapTransactionListItem']
type PageResponseIap = components['schemas']['PageResponse_AdminIapTransactionListItem_']

export const iapTransactionListFixture: AdminIapTransactionListItem[] = [
  {
    subscription_id: 'sub_iap_1',
    transaction_id: 'txn_apple_1001',
    user_id: 'user_1',
    user_email: 'alice@example.com',
    platform: 'apple',
    billing_product_id: 'plus_monthly_ios',
    plan_type: 'plus_monthly',
    status: 'active',
    amount: 899,
    created_at: '2026-07-15T10:00:00Z',
  },
  {
    subscription_id: 'sub_iap_2',
    transaction_id: 'txn_google_2002',
    user_id: 'user_2',
    user_email: 'bob@example.com',
    platform: 'google',
    billing_product_id: 'pro_monthly_android',
    plan_type: 'pro_monthly',
    status: 'refunded',
    amount: 1999,
    created_at: '2026-06-01T09:00:00Z',
  },
  {
    // Store-billed row — no provider transaction id.
    subscription_id: 'sub_iap_3',
    transaction_id: null,
    user_id: 'user_3',
    user_email: 'carol@example.com',
    platform: null,
    billing_product_id: null,
    plan_type: 'plus_yearly',
    status: 'active',
    amount: null,
    created_at: '2026-01-01T00:00:00Z',
  },
]

export const iapDetailFixture: Record<string, unknown> = {
  subscription_id: 'sub_iap_1',
  transaction_id: 'txn_apple_1001',
  user_id: 'user_1',
  user_email: 'alice@example.com',
  platform: 'apple',
  billing_product_id: 'plus_monthly_ios',
  plan_type: 'plus_monthly',
  status: 'active',
  amount: 899,
  created_at: '2026-07-15T10:00:00Z',
  apple_original_transaction_id: '1000000000000001',
}

export interface IapHandlersState {
  transactions: AdminIapTransactionListItem[]
  /** Every list/detail/mark-refunded request URL, for test assertions */
  requests: URL[]
  /** Transaction ids that were marked refunded, for test assertions */
  markedRefunded: string[]
}

function defaultState(): IapHandlersState {
  return {
    transactions: structuredClone(iapTransactionListFixture),
    requests: [],
    markedRefunded: [],
  }
}

export function createIapHandlers(initial?: Partial<IapHandlersState>) {
  const state: IapHandlersState = { ...defaultState(), ...initial }
  const { transactions, requests } = state

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/iap/transactions', ({ request }) => {
      const url = new URL(request.url)
      requests.push(url)
      const params = url.searchParams
      const platform = params.get('platform')
      const status = params.get('status')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const rows = transactions.filter((row) => {
        if (platform && row.platform !== platform) return false
        if (status && row.status !== status) return false
        return true
      })

      const start = (page - 1) * pageSize
      const response: PageResponseIap = {
        items: rows.slice(start, start + pageSize),
        total: rows.length,
        page,
        page_size: pageSize,
      }
      return HttpResponse.json(response)
    }),

    http.get('*/api/v1/admin/iap/transactions/:txnId', ({ request, params }) => {
      const url = new URL(request.url)
      requests.push(url)
      const txnId = String(params.txnId)
      const row = transactions.find((txn) => txn.transaction_id === txnId)
      if (!row) {
        return HttpResponse.json(
          { error: 'Transaction not found', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      return HttpResponse.json({ ...iapDetailFixture, transaction_id: txnId })
    }),

    http.post('*/api/v1/admin/iap/transactions/:txnId/mark-refunded', ({ params }) => {
      const txnId = String(params.txnId)
      state.markedRefunded.push(txnId)
      const row = transactions.find((txn) => txn.transaction_id === txnId)
      if (!row) {
        return HttpResponse.json(
          { error: 'Transaction not found', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      row.status = 'refunded'
      return HttpResponse.json({ subscription_id: row.subscription_id, status: 'refunded' })
    }),
  ]

  return { handlers, state }
}

/** Pre-built handlers for quick `server.use(...iapHandlers)` usage. */
export const iapHandlers = createIapHandlers().handlers
