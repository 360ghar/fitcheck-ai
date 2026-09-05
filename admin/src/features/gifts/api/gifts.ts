import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet, apiGetText, apiPatch, apiPost } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

export type AdminGiftCreate = components['schemas']['AdminGiftCreate']
export type AdminGiftAssign = components['schemas']['AdminGiftAssign']
export type AdminGiftAction = components['schemas']['AdminGiftAction']
export type AdminGiftAllowanceAdjust = components['schemas']['AdminGiftAllowanceAdjust']
export type GiftUpdate = components['schemas']['GiftUpdate']

export const GIFT_SOURCES = ['paid', 'complimentary', 'admin'] as const
export const GIFT_DURATIONS = [1, 3, 12] as const
export const GIFT_OCCASIONS = ['birthday', 'anniversary', 'other'] as const
export type GiftOccasion = (typeof GIFT_OCCASIONS)[number]
export const GIFT_STATUSES = [
  'pending',
  'issued',
  'claimed',
  'expired',
  'voided',
  'revoked',
  'payment_failed',
  'payment_review',
] as const

export interface GiftSummary {
  total_issued: number
  paid_revenue_cents: number
  complimentary_count: number
  claimed_count: number
  redemption_rate: number
  queued_months: number
  expired_count: number
  expiring_30_days: number
}

export interface GiftItem {
  id: string
  public_id: string
  source: string
  duration_months: number
  retail_value_cents: number
  currency: string
  from_name: string
  to_name: string
  message: string | null
  occasion: GiftOccasion | null
  occasion_greeting: string | null
  status: string
  payment_status: string | null
  issued_at: string | null
  expires_at: string | null
  claimed_at: string | null
  created_at: string | null
  artwork_version: number
  share_url: string | null
  claim_code: string | null
  og_image_url: string | null
  entitlement_status: string | null
  entitlement_starts_at: string | null
  entitlement_ends_at: string | null
  amount_paid_cents: number | null
  amount_refunded_cents: number
  stripe_checkout_session_id: string | null
}

export interface GiftDetail extends GiftItem {
  recipient_email: string | null
  purchaser_user_id: string | null
  claimed_by_user_id: string | null
  stripe_payment_intent_id: string | null
  payment_completed_at: string | null
  admin_note: string | null
  entitlement: Record<string, unknown> | null
}

export interface GiftPage {
  items: GiftItem[]
  total: number
  page: number
  page_size: number
}

export const giftKeys = {
  all: ['gift-vouchers'] as const,
  list: (params: TableStateParams) => [...giftKeys.all, 'list', params] as const,
  summary: () => [...giftKeys.all, 'summary'] as const,
  detail: (id: string) => [...giftKeys.all, 'detail', id] as const,
}

function text(row: Record<string, unknown>, key: string): string | null {
  const value = row[key]
  return typeof value === 'string' && value.length > 0 ? value : null
}

function number(row: Record<string, unknown>, key: string): number | null {
  const value = row[key]
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

export function toGiftItem(row: Record<string, unknown>): GiftItem {
  return {
    id: text(row, 'id') ?? '',
    public_id: text(row, 'public_id') ?? '',
    source: text(row, 'source') ?? '',
    duration_months: number(row, 'duration_months') ?? 0,
    retail_value_cents: number(row, 'retail_value_cents') ?? 0,
    currency: text(row, 'currency') ?? 'USD',
    from_name: text(row, 'from_name') ?? '',
    to_name: text(row, 'to_name') ?? '',
    message: text(row, 'message'),
    occasion: text(row, 'occasion') as GiftOccasion | null,
    occasion_greeting: text(row, 'occasion_greeting'),
    status: text(row, 'status') ?? 'pending',
    payment_status: text(row, 'payment_status'),
    issued_at: text(row, 'issued_at'),
    expires_at: text(row, 'expires_at'),
    claimed_at: text(row, 'claimed_at'),
    created_at: text(row, 'created_at'),
    artwork_version: number(row, 'artwork_version') ?? 1,
    share_url: text(row, 'share_url'),
    claim_code: text(row, 'claim_code'),
    og_image_url: text(row, 'og_image_url'),
    entitlement_status: text(row, 'entitlement_status'),
    entitlement_starts_at: text(row, 'entitlement_starts_at'),
    entitlement_ends_at: text(row, 'entitlement_ends_at'),
    amount_paid_cents: number(row, 'amount_paid_cents'),
    amount_refunded_cents: number(row, 'amount_refunded_cents') ?? 0,
    stripe_checkout_session_id: text(row, 'stripe_checkout_session_id'),
  }
}

function toGiftDetail(row: Record<string, unknown>): GiftDetail {
  return {
    ...toGiftItem(row),
    recipient_email: text(row, 'recipient_email'),
    purchaser_user_id: text(row, 'purchaser_user_id'),
    claimed_by_user_id: text(row, 'claimed_by_user_id'),
    stripe_payment_intent_id: text(row, 'stripe_payment_intent_id'),
    payment_completed_at: text(row, 'payment_completed_at'),
    admin_note: text(row, 'admin_note'),
    entitlement:
      typeof row['entitlement'] === 'object' && row['entitlement'] !== null
        ? (row['entitlement'] as Record<string, unknown>)
        : null,
  }
}

function giftSearchParams(params: TableStateParams, paginate: boolean): URLSearchParams {
  const search = new URLSearchParams()
  if (paginate) {
    search.set('page', String(params.page))
    search.set('page_size', String(params.page_size))
  }
  if (params.q) search.set('q', params.q)
  for (const key of ['source', 'duration_months', 'status', 'created_from', 'created_to']) {
    const value = params.filters[key]
    if (value) search.set(key, value)
  }
  return search
}

export function listGifts(params: TableStateParams): Promise<GiftPage> {
  const search = giftSearchParams(params, true)
  return apiGet<Record<string, unknown>>(`/api/v1/admin/gifts?${search.toString()}`).then(
    (response) => {
      const rows = Array.isArray(response['items']) ? response['items'] : []
      return {
        items: rows.map((row) => toGiftItem(row as Record<string, unknown>)),
        total: typeof response['total'] === 'number' ? response['total'] : rows.length,
        page: typeof response['page'] === 'number' ? response['page'] : params.page,
        page_size:
          typeof response['page_size'] === 'number' ? response['page_size'] : params.page_size,
      }
    },
  )
}

export function exportGifts(params: TableStateParams): Promise<string> {
  const search = giftSearchParams(params, false)
  const query = search.toString()
  return apiGetText(`/api/v1/admin/gifts/export.csv${query ? `?${query}` : ''}`)
}

export function useGiftsQuery(params: TableStateParams) {
  return useQuery({
    queryKey: giftKeys.list(params),
    queryFn: () => listGifts(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function getGiftSummary(): Promise<GiftSummary> {
  return apiGet<GiftSummary>('/api/v1/admin/gifts/summary')
}

export function useGiftSummaryQuery() {
  return useQuery({
    queryKey: giftKeys.summary(),
    queryFn: getGiftSummary,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function getGift(id: string): Promise<GiftDetail> {
  return apiGet<Record<string, unknown>>(
    `/api/v1/admin/gifts/${encodeURIComponent(id)}`,
  ).then(toGiftDetail)
}

export function useGiftDetailQuery(id: string | null) {
  return useQuery({
    queryKey: giftKeys.detail(id ?? ''),
    queryFn: () => getGift(id ?? ''),
    enabled: Boolean(id),
  })
}

export function createGift(body: AdminGiftCreate): Promise<GiftItem> {
  return apiPost<Record<string, unknown>>('/api/v1/admin/gifts', body).then(toGiftItem)
}

export function editGift(id: string, body: GiftUpdate): Promise<GiftItem> {
  return apiPatch<Record<string, unknown>>(
    `/api/v1/admin/gifts/${encodeURIComponent(id)}`,
    body,
  ).then(toGiftItem)
}

export function rotateGift(id: string, body: AdminGiftAction): Promise<GiftItem> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/gifts/${encodeURIComponent(id)}/rotate`,
    body,
  ).then(toGiftItem)
}

export function assignGift(id: string, body: AdminGiftAssign): Promise<Record<string, unknown>> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/gifts/${encodeURIComponent(id)}/assign`,
    body,
  )
}

export function voidOrRevokeGift(id: string, body: AdminGiftAction): Promise<GiftItem> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/gifts/${encodeURIComponent(id)}/void-or-revoke`,
    body,
  ).then(toGiftItem)
}

export function adjustGiftAllowance(
  userId: string,
  body: AdminGiftAllowanceAdjust,
): Promise<Record<string, unknown>> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/gifts/allowances/${encodeURIComponent(userId)}`,
    body,
  )
}
