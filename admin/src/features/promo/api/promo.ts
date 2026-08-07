import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { apiGet, apiPatch, apiPost } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Promo codes feature API.
 *
 *   GET   /api/v1/admin/promo-codes          → PageResponse[Dict[str, Any]]
 *   POST  /api/v1/admin/promo-codes          → Dict[str, Any] (201)
 *   PATCH /api/v1/admin/promo-codes/{code_id} → Dict[str, Any]
 *
 * The backend list returns untyped dicts (see backend/app/models/admin.py +
 * migration 031); `PromoCodeItem` is the local, defensively-parsed view of a
 * row (id, code, plan_type, months, max_uses, used_count, expires_at, active,
 * timestamps) plus the joined `redemptions_count`.
 */

type AdminPromoCodeCreate = components['schemas']['AdminPromoCodeCreate']
type AdminPromoCodeUpdate = components['schemas']['AdminPromoCodeUpdate']
type PageResponseDict = components['schemas']['PageResponse_Dict_str__Any__']

export const PROMO_PLAN_TYPES = [
  'plus_monthly',
  'plus_yearly',
  'pro_monthly',
  'pro_yearly',
] as const
export type PromoPlanType = (typeof PROMO_PLAN_TYPES)[number]

export interface PromoCodeItem {
  id: string
  code: string
  plan_type: string
  months: number
  max_uses: number | null
  used_count: number
  expires_at: string | null
  active: boolean
  created_at: string | null
  updated_at: string | null
  redemptions_count: number
}

export interface PageResponsePromo {
  items: PromoCodeItem[]
  total: number
  page: number
  page_size: number
}

export const promoKeys = {
  all: ['promo-codes'] as const,
  list: (params: TableStateParams) => [...promoKeys.all, 'list', params] as const,
}

function parseString(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 ? value : null
}

function parseNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

/** Defensive parse of a raw dict row into the local PromoCodeItem shape. */
export function toPromoCodeItem(row: Record<string, unknown>): PromoCodeItem {
  const redemptions = parseNumber(row['redemptions_count'])
  const used = parseNumber(row['used_count'])
  return {
    id: parseString(row['id']) ?? '',
    code: parseString(row['code']) ?? '',
    plan_type: parseString(row['plan_type']) ?? '',
    months: parseNumber(row['months']) ?? 1,
    max_uses: parseNumber(row['max_uses']),
    used_count: used ?? 0,
    expires_at: parseString(row['expires_at']),
    active: row['active'] === true,
    created_at: parseString(row['created_at']),
    updated_at: parseString(row['updated_at']),
    redemptions_count: redemptions ?? used ?? 0,
  }
}

export function listPromoCodes(params: TableStateParams): Promise<PageResponsePromo> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.q) search.set('q', params.q)
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  if (params.filters.active) search.set('active', params.filters.active)
  if (params.filters.plan_type) search.set('plan_type', params.filters.plan_type)
  return apiGet<PageResponseDict>(`/api/v1/admin/promo-codes?${search.toString()}`).then(
    (response) => ({
      items: response.items.map((item) => toPromoCodeItem(item)),
      total: response.total,
      page: response.page,
      page_size: response.page_size,
    }),
  )
}

export function usePromoCodesQuery(params: TableStateParams) {
  return useQuery({
    queryKey: promoKeys.list(params),
    queryFn: () => listPromoCodes(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function createPromoCode(body: AdminPromoCodeCreate): Promise<PromoCodeItem> {
  return apiPost<Record<string, unknown>>('/api/v1/admin/promo-codes', body).then((row) =>
    toPromoCodeItem(row),
  )
}

export function updatePromoCode(
  codeId: string,
  body: AdminPromoCodeUpdate,
): Promise<PromoCodeItem> {
  return apiPatch<Record<string, unknown>>(
    `/api/v1/admin/promo-codes/${encodeURIComponent(codeId)}`,
    body,
  ).then((row) => toPromoCodeItem(row))
}

export type { AdminPromoCodeCreate, AdminPromoCodeUpdate }
