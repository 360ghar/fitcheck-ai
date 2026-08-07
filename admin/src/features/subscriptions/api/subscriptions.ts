import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet, apiPost } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Subscriptions feature API — built against the generated OpenAPI contract
 * (src/shared/api/schema.d.ts), never the hand-written types.
 *
 *   GET  /api/v1/admin/subscriptions                      → PageResponse[AdminSubscriptionListItem]
 *   GET  /api/v1/admin/subscriptions/user/{user_id}       → AdminSubscriptionDetail
 *   POST /api/v1/admin/subscriptions/user/{user_id}/refund → AdminRefundResponse
 */

type AdminSubscriptionListItem = components['schemas']['AdminSubscriptionListItem']
type PageResponseSubscriptions = components['schemas']['PageResponse_AdminSubscriptionListItem_']
type AdminRefundResponse = components['schemas']['AdminRefundResponse']

export const subscriptionKeys = {
  all: ['subscriptions'] as const,
  list: (params: TableStateParams) => [...subscriptionKeys.all, 'list', params] as const,
  detail: (userId: string) => [...subscriptionKeys.all, 'detail', userId] as const,
}

/** Sortable columns accepted by the backend (`sort_by` enum). */
export const SUBSCRIPTION_SORT_COLUMNS = [
  'created_at',
  'current_period_start',
  'plan_type',
  'status',
] as const

export function listSubscriptions(params: TableStateParams): Promise<PageResponseSubscriptions> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.sort_by && (SUBSCRIPTION_SORT_COLUMNS as readonly string[]).includes(params.sort_by)) {
    search.set('sort_by', params.sort_by)
  }
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  if (params.filters.plan) search.set('plan', params.filters.plan)
  if (params.filters.status) search.set('status', params.filters.status)
  return apiGet<PageResponseSubscriptions>(`/api/v1/admin/subscriptions?${search.toString()}`)
}

export function useSubscriptionsQuery(params: TableStateParams) {
  return useQuery({
    queryKey: subscriptionKeys.list(params),
    queryFn: () => listSubscriptions(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function refundSubscription(userId: string): Promise<AdminRefundResponse> {
  return apiPost<AdminRefundResponse>(
    `/api/v1/admin/subscriptions/user/${encodeURIComponent(userId)}/refund`,
  )
}

export type { AdminSubscriptionListItem, AdminRefundResponse }
