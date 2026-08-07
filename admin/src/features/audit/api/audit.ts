import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet } from '@/shared/api/client'
import type { PageResponse_AdminAuditEventItem_ } from '@/shared/api/schemaTypes'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_RETRY, QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Audit trail API (spec §4):
 *
 *   GET /api/v1/admin/audit?actor_id=&action=&entity_type=&entity_id=&from=&to=&page=&page_size=&sort_dir=
 *   → PageResponse[AdminAuditEventItem]
 *
 * Verified against the generated schema: the backend exposes actor_id /
 * action / entity_type / entity_id / from / to (datetime aliases) / page /
 * page_size / sort_dir. There is NO free-text `q` param — the page's search
 * box therefore filters the current page client-side (documented in the
 * page) while every select here maps to a real server filter.
 */

export const auditKeys = {
  all: ['audit'] as const,
  list: (params: TableStateParams) => [...auditKeys.all, 'list', params] as const,
}

const SERVER_FILTER_KEYS = ['actor_id', 'action', 'entity_type', 'from', 'to'] as const

export function listAudit(params: TableStateParams): Promise<PageResponse_AdminAuditEventItem_> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  for (const key of SERVER_FILTER_KEYS) {
    const value = params.filters[key]
    if (value) search.set(key, value)
  }
  return apiGet<PageResponse_AdminAuditEventItem_>(`/api/v1/admin/audit?${search.toString()}`)
}

export function useAuditQuery(params: TableStateParams) {
  return useQuery({
    queryKey: auditKeys.list(params),
    queryFn: () => listAudit(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}
