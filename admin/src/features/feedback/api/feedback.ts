import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet, apiPatch } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Feedback feature API — support tickets.
 *
 *   GET   /api/v1/admin/feedback           → PageResponse[AdminFeedbackListItem]
 *   PATCH /api/v1/admin/feedback/{ticket_id} → Dict[str, Any] (status + internal notes)
 */

type AdminFeedbackListItem = components['schemas']['AdminFeedbackListItem']
type PageResponseFeedback = components['schemas']['PageResponse_AdminFeedbackListItem_']
type AdminFeedbackUpdate = components['schemas']['AdminFeedbackUpdate']

export const FEEDBACK_STATUSES = ['open', 'in_progress', 'resolved', 'closed'] as const
export type FeedbackStatus = (typeof FEEDBACK_STATUSES)[number]

export const feedbackKeys = {
  all: ['feedback'] as const,
  list: (params: TableStateParams) => [...feedbackKeys.all, 'list', params] as const,
  detail: (ticketId: string) => [...feedbackKeys.all, 'detail', ticketId] as const,
}

export function listFeedback(params: TableStateParams): Promise<PageResponseFeedback> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.q) search.set('q', params.q)
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  if (params.filters.status) search.set('status', params.filters.status)
  if (params.filters.category) search.set('category', params.filters.category)
  return apiGet<PageResponseFeedback>(`/api/v1/admin/feedback?${search.toString()}`)
}

export function useFeedbackQuery(params: TableStateParams) {
  return useQuery({
    queryKey: feedbackKeys.list(params),
    queryFn: () => listFeedback(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function updateFeedback(
  ticketId: string,
  body: AdminFeedbackUpdate,
): Promise<Record<string, unknown>> {
  return apiPatch<Record<string, unknown>>(
    `/api/v1/admin/feedback/${encodeURIComponent(ticketId)}`,
    body,
  )
}

export type { AdminFeedbackListItem, AdminFeedbackUpdate }
