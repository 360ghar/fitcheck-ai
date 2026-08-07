import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { apiGet, apiPatch } from '@/shared/api/client'
import type { PageResponse_AdminQuotaUsageItem_ } from '@/shared/api/schemaTypes'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_RETRY, QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Quotas API (spec §4):
 *
 *   GET   /api/v1/admin/quotas?q=&plan=&page=&page_size=&sort_by=&sort_dir=
 *         → PageResponse[AdminQuotaUsageItem]
 *   PATCH /api/v1/admin/users/{user_id}/quota-override {daily_limit: number|null}
 *         → { user_id, custom_daily_quota } (null clears the override)
 *
 * sort_by vocabulary (backend): extraction | generation | embedding | user.
 * The write endpoint is gated by require_admin backend-side (any admin role),
 * so the UI gates the button on quotas.read to match.
 */

export const quotaKeys = {
  all: ['quotas'] as const,
  list: (params: TableStateParams) => [...quotaKeys.all, 'list', params] as const,
}

export function listQuotas(params: TableStateParams): Promise<PageResponse_AdminQuotaUsageItem_> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.q) search.set('q', params.q)
  if (params.sort_by) search.set('sort_by', params.sort_by)
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  const plan = params.filters['plan']
  if (plan) search.set('plan', plan)
  return apiGet<PageResponse_AdminQuotaUsageItem_>(`/api/v1/admin/quotas?${search.toString()}`)
}

export function useQuotasQuery(params: TableStateParams) {
  return useQuery({
    queryKey: quotaKeys.list(params),
    queryFn: () => listQuotas(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function setQuotaOverride(
  userId: string,
  dailyLimit: number | null,
): Promise<Record<string, unknown>> {
  return apiPatch<Record<string, unknown>>(`/api/v1/admin/users/${userId}/quota-override`, {
    daily_limit: dailyLimit,
  })
}

/** Override mutation — never auto-retried; invalidates the quotas list. */
export function useSetQuotaOverride() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ userId, dailyLimit }: { userId: string; dailyLimit: number | null }) =>
      setQuotaOverride(userId, dailyLimit),
    onSettled: () => {
      void queryClient.invalidateQueries({ queryKey: quotaKeys.all })
    },
    retry: QUERY_RETRY.mutations,
  })
}
