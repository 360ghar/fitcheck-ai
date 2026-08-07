import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type { components } from '@/shared/api/schema'

/**
 * Promo codes fixtures + handlers. The backend list returns untyped dicts;
 * the feature parses them locally (features/promo/api/promo.ts), so fixture
 * rows carry the raw backend keys (`used_count`, joined `redemptions_count`).
 */

type PageResponseDict = components['schemas']['PageResponse_Dict_str__Any__']

export const adminPromoFixture: Record<string, unknown>[] = [
  {
    id: 'code_1',
    code: 'SUMMER25',
    plan_type: 'plus_monthly',
    months: 3,
    max_uses: 100,
    used_count: 12,
    redemptions_count: 12,
    active: true,
    expires_at: '2026-09-30T00:00:00Z',
    created_at: '2026-07-01T00:00:00Z',
    updated_at: '2026-07-01T00:00:00Z',
  },
  {
    id: 'code_2',
    code: 'PRO-FRIENDS',
    plan_type: 'pro_yearly',
    months: 1,
    max_uses: null,
    used_count: 0,
    redemptions_count: 0,
    active: false,
    expires_at: null,
    created_at: '2026-06-15T00:00:00Z',
    updated_at: '2026-06-15T00:00:00Z',
  },
]

export interface PromoHandlersState {
  rows: Record<string, unknown>[]
  requests: URL[]
}

function defaultState(): PromoHandlersState {
  return {
    rows: structuredClone(adminPromoFixture),
    requests: [],
  }
}

function paginate(rows: Record<string, unknown>[], page: number, pageSize: number): PageResponseDict {
  const start = (page - 1) * pageSize
  return {
    items: rows.slice(start, start + pageSize),
    total: rows.length,
    page,
    page_size: pageSize,
  }
}

export function createPromoHandlers(initial?: Partial<PromoHandlersState>) {
  const state: PromoHandlersState = { ...defaultState(), ...initial }
  const { rows, requests } = state

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/promo-codes', ({ request }) => {
      const url = new URL(request.url)
      requests.push(url)
      const params = url.searchParams
      const active = params.get('active')
      const planType = params.get('plan_type')
      const q = params.get('q')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const filtered = rows.filter((row) => {
        if (active === 'true' && row.active !== true) return false
        if (active === 'false' && row.active !== false) return false
        if (planType && row.plan_type !== planType) return false
        if (q && !String(row.code).toLowerCase().includes(q.toLowerCase())) return false
        return true
      })
      return HttpResponse.json(paginate(filtered, page, pageSize))
    }),
  ]

  return { handlers, state }
}

export const promoHandlers = createPromoHandlers().handlers
