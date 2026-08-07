import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet, apiPost } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * IAP transactions feature API — store-billed subscriptions (Apple/Google).
 *
 *   GET  /api/v1/admin/iap/transactions             → PageResponse[AdminIapTransactionListItem]
 *   GET  /api/v1/admin/iap/transactions/{txn_id}    → { [key: string]: unknown }
 *   POST /api/v1/admin/iap/transactions/{txn_id}/mark-refunded → { [key: string]: unknown }
 *
 * Detail + mark-refunded return untyped dicts in the generated schema; the
 * local `IapTransactionDetail` type mirrors the backend's `_iap_item` shape
 * and is applied defensively (every field optional).
 */

type AdminIapTransactionListItem = components['schemas']['AdminIapTransactionListItem']
type PageResponseIap = components['schemas']['PageResponse_AdminIapTransactionListItem_']

export const iapKeys = {
  all: ['iap-transactions'] as const,
  list: (params: TableStateParams) => [...iapKeys.all, 'list', params] as const,
  detail: (txnId: string) => [...iapKeys.all, 'detail', txnId] as const,
}

/** Local view of the untyped detail response — defensive, never asserted. */
export interface IapTransactionDetail {
  subscription_id?: string
  transaction_id?: string | null
  user_id?: string
  user_email?: string | null
  platform?: string | null
  plan_type?: string | null
  amount?: number | null
  status?: string | null
  created_at?: string | null
  billing_product_id?: string | null
  apple_original_transaction_id?: string | null
  google_order_id?: string | null
  google_purchase_token?: string | null
  [key: string]: unknown
}

export function listIapTransactions(params: TableStateParams): Promise<PageResponseIap> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  if (params.filters.platform) search.set('platform', params.filters.platform)
  if (params.filters.status) search.set('status', params.filters.status)
  return apiGet<PageResponseIap>(`/api/v1/admin/iap/transactions?${search.toString()}`)
}

export function useIapTransactionsQuery(params: TableStateParams) {
  return useQuery({
    queryKey: iapKeys.list(params),
    queryFn: () => listIapTransactions(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function getIapTransaction(txnId: string): Promise<Record<string, unknown>> {
  return apiGet<Record<string, unknown>>(
    `/api/v1/admin/iap/transactions/${encodeURIComponent(txnId)}`,
  )
}

export function markIapRefunded(txnId: string): Promise<Record<string, unknown>> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/iap/transactions/${encodeURIComponent(txnId)}/mark-refunded`,
  )
}

export type { AdminIapTransactionListItem }
