import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type {
  AdminUserActivity,
  AdminUserDetail,
  AdminUserListItem,
  AdminUserPatch,
  PageResponse_AdminUserListItem_,
} from '@/shared/api/schemaTypes'

/**
 * Users feature fixtures + handlers (typed against src/shared/api/schema.d.ts
 * — NOT the legacy shared/api/types.ts drift shapes: status → is_active,
 * plan → subscription.plan_type).
 *
 * `createUsersHandlers()` returns a fresh state per call so tests never leak
 * mutations between cases. The list handler mirrors the backend service:
 * q/status/role/plan filters, sort_by/sort_dir, and page/page_size slicing.
 */

export const adminUserListFixture: AdminUserListItem[] = [
  {
    id: 'user_1',
    email: 'alice@example.com',
    full_name: 'Alice Example',
    avatar_url: null,
    is_active: true,
    is_admin: false,
    role: 'user',
    custom_daily_quota: 150,
    created_at: '2026-05-01T08:30:00Z',
    updated_at: '2026-08-05T09:00:00Z',
    last_login_at: '2026-08-05T09:00:00Z',
    email_verified: true,
    subscription: {
      plan_type: 'pro_monthly',
      status: 'active',
      current_period_start: '2026-07-10T00:00:00Z',
      current_period_end: '2026-08-10T00:00:00Z',
      billing_provider: 'stripe',
    },
    outfits_count: 12,
    items_count: 42,
  },
  {
    id: 'user_2',
    email: 'bob@example.com',
    full_name: null,
    avatar_url: null,
    is_active: false,
    is_admin: false,
    role: 'user',
    custom_daily_quota: null,
    created_at: '2026-06-15T12:00:00Z',
    updated_at: '2026-07-30T16:45:00Z',
    last_login_at: null,
    email_verified: false,
    subscription: {
      plan_type: 'free',
      status: 'active',
      billing_provider: null,
    },
    outfits_count: 0,
    items_count: 3,
  },
  {
    id: 'user_3',
    email: 'carol@example.com',
    full_name: 'Carol Example',
    avatar_url: 'https://cdn.example.com/avatars/carol.jpg',
    is_active: true,
    is_admin: true,
    role: 'support',
    custom_daily_quota: null,
    created_at: '2026-07-20T14:00:00Z',
    updated_at: '2026-08-06T10:00:00Z',
    last_login_at: '2026-08-06T10:00:00Z',
    email_verified: true,
    subscription: {
      plan_type: 'plus_yearly',
      status: 'active',
      current_period_start: '2026-01-01T00:00:00Z',
      current_period_end: '2027-01-01T00:00:00Z',
      billing_provider: 'apple',
    },
    outfits_count: 2,
    items_count: 8,
  },
  {
    id: 'user_4',
    email: 'dave@example.com',
    full_name: 'Dave Example',
    avatar_url: null,
    is_active: true,
    is_admin: false,
    role: 'user',
    custom_daily_quota: null,
    created_at: '2026-08-01T09:15:00Z',
    updated_at: '2026-08-04T11:20:00Z',
    last_login_at: '2026-08-04T11:20:00Z',
    email_verified: true,
    subscription: {
      plan_type: 'free',
      status: 'active',
      billing_provider: null,
    },
    outfits_count: 1,
    items_count: 5,
  },
]

export const adminUserDetailFixture: AdminUserDetail = {
  user: {
    id: 'user_1',
    email: 'alice@example.com',
    full_name: 'Alice Example',
    avatar_url: null,
    is_active: true,
    is_admin: false,
    role: 'user',
    custom_daily_quota: 150,
    email_verified: true,
    created_at: '2026-05-01T08:30:00Z',
    updated_at: '2026-08-05T09:00:00Z',
    last_login_at: '2026-08-05T09:00:00Z',
  },
  subscription: {
    plan_type: 'pro_monthly',
    status: 'active',
    current_period_start: '2026-07-10T00:00:00Z',
    current_period_end: '2026-08-10T00:00:00Z',
    cancel_at_period_end: false,
    billing_provider: 'stripe',
    stripe_customer_id: 'cus_test_1',
    referral_credit_months: 0,
    trial_end: null,
  },
  usage: {
    ai: {
      daily_extraction_count: 14,
      daily_generation_count: 6,
      daily_embedding_count: 22,
      last_reset_date: '2026-08-06',
      total_extractions: 411,
      total_generations: 208,
    },
    subscription_usage: {
      period_start: '2026-08-01',
      monthly_extractions: 14,
      monthly_generations: 6,
      monthly_embeddings: 22,
      daily_photoshoot_images: 3,
      last_photoshoot_reset: '2026-08-06T00:00:00Z',
    },
  },
  counts: {
    outfits: 12,
    items: 42,
    referral_codes: 2,
  },
  recent_jobs: [
    {
      id: 'job_1',
      user_id: 'user_1',
      job_type: 'batch_extraction',
      status: 'completed',
      created_at: '2026-08-06T08:00:00Z',
      completed_at: '2026-08-06T08:04:00Z',
      error_message: null,
    },
    {
      id: 'job_2',
      user_id: 'user_1',
      job_type: 'photoshoot',
      status: 'failed',
      created_at: '2026-08-05T18:00:00Z',
      completed_at: '2026-08-05T18:01:00Z',
      error_message: 'Image generation failed: provider timeout',
    },
  ],
}

export const adminUserActivityFixture: AdminUserActivity = {
  user_id: 'user_1',
  audit_events: [
    {
      id: 'audit_9',
      actor_id: 'admin_1',
      actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
      action: 'user.role_changed',
      entity_type: 'user',
      entity_id: 'user_1',
      payload: { field: 'role', before: 'user', after: 'ops' },
      ip: '203.0.113.10',
      user_agent: 'Mozilla/5.0 (test)',
      created_at: '2026-08-06T10:00:00Z',
    },
    {
      id: 'audit_8',
      actor_id: 'admin_1',
      actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
      action: 'quota.override',
      entity_type: 'user',
      entity_id: 'user_1',
      payload: { custom_daily_quota: 150 },
      ip: '203.0.113.10',
      user_agent: 'Mozilla/5.0 (test)',
      created_at: '2026-08-06T09:30:00Z',
    },
  ],
  recent_jobs: [
    {
      id: 'job_1',
      user_id: 'user_1',
      job_type: 'batch_extraction',
      status: 'completed',
      created_at: '2026-08-06T08:00:00Z',
      completed_at: '2026-08-06T08:04:00Z',
      error_message: null,
    },
  ],
}

export interface UsersHandlersState {
  users: AdminUserListItem[]
  /** Every list/detail request URL, for test assertions */
  requests: URL[]
  /** Body of the most recent PATCH, for test assertions */
  lastPatchBody: AdminUserPatch | null
}

function defaultState(): UsersHandlersState {
  return {
    users: structuredClone(adminUserListFixture),
    requests: [],
    lastPatchBody: null,
  }
}

function paginate<T>(items: T[], page: number, pageSize: number): PageResponse_AdminUserListItem_ {
  const start = (page - 1) * pageSize
  return {
    items: items.slice(start, start + pageSize) as AdminUserListItem[],
    total: items.length,
    page,
    page_size: pageSize,
  }
}

export function createUsersHandlers(initial?: Partial<UsersHandlersState>) {
  const state: UsersHandlersState = { ...defaultState(), ...initial }
  const { users, requests } = state

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/users', ({ request }) => {
      const url = new URL(request.url)
      requests.push(url)
      const params = url.searchParams
      const q = params.get('q')?.toLowerCase()
      const status = params.get('status')
      const role = params.get('role')
      const plan = params.get('plan')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')
      const sortBy = params.get('sort_by') ?? 'created_at'
      const sortDir = params.get('sort_dir') ?? 'desc'

      let rows = users.filter((row) => {
        if (q) {
          const haystack = `${row.email ?? ''} ${row.full_name ?? ''}`.toLowerCase()
          if (!haystack.includes(q)) return false
        }
        if (status === 'active' && row.is_active !== true) return false
        if (status === 'suspended' && row.is_active !== false) return false
        if (role && row.role !== role) return false
        if (plan) {
          const rowPlan =
            row.subscription && typeof row.subscription === 'object'
              ? (row.subscription as Record<string, unknown>)['plan_type']
              : undefined
          if (rowPlan !== plan) return false
        }
        return true
      })

      const sorted = [...rows].sort((a, b) => {
        const getValue = (row: AdminUserListItem): string | number => {
          switch (sortBy) {
            case 'email':
              return row.email ?? ''
            case 'full_name':
              return row.full_name ?? ''
            case 'last_login_at':
              return typeof row.last_login_at === 'string' ? row.last_login_at : ''
            default:
              return typeof row.created_at === 'string' ? row.created_at : ''
          }
        }
        const av = getValue(a)
        const bv = getValue(b)
        const cmp = av < bv ? -1 : av > bv ? 1 : 0
        return sortDir === 'asc' ? cmp : -cmp
      })
      rows = sorted

      return HttpResponse.json(paginate(rows, page, pageSize))
    }),

    http.get('*/api/v1/admin/users/:userId', ({ request, params }) => {
      const url = new URL(request.url)
      requests.push(url)
      const userId = params.userId as string
      const row = users.find((user) => user.id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'User not found', code: 'USER_NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      const detail = structuredClone(adminUserDetailFixture)
      detail.user = {
        ...(detail.user as Record<string, unknown>),
        id: row.id,
        email: row.email ?? null,
        full_name: row.full_name ?? null,
        avatar_url: row.avatar_url ?? null,
        is_active: row.is_active ?? null,
        is_admin: row.is_admin ?? null,
        role: row.role ?? null,
        custom_daily_quota: row.custom_daily_quota ?? null,
        created_at: row.created_at ?? null,
        updated_at: row.updated_at ?? null,
        last_login_at: row.last_login_at ?? null,
      }
      detail.subscription = row.subscription ?? null
      detail.counts = {
        ...(detail.counts as Record<string, unknown>),
        outfits: row.outfits_count ?? 0,
        items: row.items_count ?? 0,
      }
      return HttpResponse.json(detail)
    }),

    http.patch('*/api/v1/admin/users/:userId', async ({ request, params }) => {
      const userId = params.userId as string
      const body = (await request.json()) as AdminUserPatch
      state.lastPatchBody = body
      const row = users.find((user) => user.id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'User not found', code: 'USER_NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      const changes: Array<{ action: string; field: string; before: unknown; after: unknown }> =
        []
      if (body.is_active !== undefined) {
        changes.push({
          action: body.is_active ? 'user.activated' : 'user.suspended',
          field: 'is_active',
          before: row.is_active,
          after: body.is_active,
        })
        row.is_active = body.is_active
      }
      if (body.is_admin !== undefined) {
        changes.push({
          action: body.is_admin ? 'user.admin_granted' : 'user.admin_revoked',
          field: 'is_admin',
          before: row.is_admin,
          after: body.is_admin,
        })
        row.is_admin = body.is_admin
      }
      if (body.role !== undefined && body.role !== null) {
        changes.push({
          action: 'user.role_changed',
          field: 'role',
          before: row.role,
          after: body.role,
        })
        row.role = body.role
      }
      return HttpResponse.json({ user: row, changes })
    }),

    http.get('*/api/v1/admin/users/:userId/activity', ({ request, params }) => {
      const url = new URL(request.url)
      requests.push(url)
      const userId = params.userId as string
      const row = users.find((user) => user.id === userId)
      if (!row) {
        return HttpResponse.json(
          { error: 'User not found', code: 'USER_NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      return HttpResponse.json(adminUserActivityFixture)
    }),
  ]

  return { handlers, state }
}

/** Pre-built handlers for quick `server.use(...usersHandlers)` usage. */
export const usersHandlers = createUsersHandlers().handlers
