import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type {
  AdminQuotaUsageItem,
  PageResponse_AdminQuotaUsageItem_,
} from '@/shared/api/schemaTypes'

/**
 * Quotas fixtures + handlers, typed against the generated schema. Rows carry
 * today's per-op daily counters; the effective limit is either
 * `custom_daily_quota` or the plan default (the backend doesn't return the
 * computed limit, so the UI renders "Plan default").
 */

export const adminQuotaUsageFixture: AdminQuotaUsageItem[] = [
  {
    user_id: 'user_1',
    email: 'alice@example.com',
    full_name: 'Alice Example',
    plan_type: 'pro_monthly',
    daily_extraction_count: 14,
    daily_generation_count: 6,
    daily_embedding_count: 22,
    daily_photoshoot_images: 3,
    last_reset_date: '2026-08-06',
    custom_daily_quota: 150,
  },
  {
    user_id: 'user_2',
    email: 'bob@example.com',
    full_name: null,
    plan_type: 'free',
    daily_extraction_count: 0,
    daily_generation_count: 0,
    daily_embedding_count: 1,
    daily_photoshoot_images: 0,
    last_reset_date: '2026-08-06',
    custom_daily_quota: null,
  },
  {
    user_id: 'user_3',
    email: 'carol@example.com',
    full_name: 'Carol Example',
    plan_type: 'plus_yearly',
    daily_extraction_count: 8,
    daily_generation_count: 4,
    daily_embedding_count: 10,
    daily_photoshoot_images: 2,
    last_reset_date: '2026-08-06',
    custom_daily_quota: null,
  },
  {
    user_id: 'user_4',
    email: 'dave@example.com',
    full_name: 'Dave Example',
    plan_type: 'free',
    daily_extraction_count: 2,
    daily_generation_count: 1,
    daily_embedding_count: 5,
    daily_photoshoot_images: 0,
    last_reset_date: '2026-08-06',
    custom_daily_quota: null,
  },
]

export interface QuotasHandlersState {
  rows: AdminQuotaUsageItem[]
  requests: URL[]
  /** Body of the most recent override PATCH */
  lastPatchBody: { daily_limit?: number | null } | null
}

function paginateQuotas(
  items: AdminQuotaUsageItem[],
  page: number,
  pageSize: number,
): PageResponse_AdminQuotaUsageItem_ {
  const start = (page - 1) * pageSize
  return {
    items: items.slice(start, start + pageSize),
    total: items.length,
    page,
    page_size: pageSize,
  }
}

export function createQuotasHandlers(initial?: Partial<QuotasHandlersState>) {
  const state: QuotasHandlersState = {
    rows: structuredClone(adminQuotaUsageFixture),
    requests: [],
    lastPatchBody: null,
    ...initial,
  }

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/quotas', ({ request }) => {
      const url = new URL(request.url)
      state.requests.push(url)
      const params = url.searchParams
      const q = params.get('q')?.toLowerCase()
      const plan = params.get('plan')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const rows = state.rows.filter((row) => {
        if (q) {
          const haystack = `${row.email ?? ''} ${row.full_name ?? ''}`.toLowerCase()
          if (!haystack.includes(q)) return false
        }
        if (plan && row.plan_type !== plan) return false
        return true
      })

      return HttpResponse.json(paginateQuotas(rows, page, pageSize))
    }),

    http.patch('*/api/v1/admin/users/:userId/quota-override', async ({ request, params }) => {
      const userId = params.userId as string
      const body = (await request.json()) as { daily_limit?: number | null }
      state.lastPatchBody = body
      const row = state.rows.find((item) => item.user_id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'User not found', code: 'USER_NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      const customDailyQuota = body.daily_limit ?? null
      row.custom_daily_quota = customDailyQuota
      return HttpResponse.json({ user_id: userId, custom_daily_quota: customDailyQuota })
    }),
  ]

  return { handlers, state }
}

export const quotasHandlers = createQuotasHandlers().handlers
