import type { Page, Route } from '@playwright/test'

import type { AdminUserListItem } from '../src/shared/api/schemaTypes'

import {
  auditEventsFixture,
  dashboardFixtures,
  feedbackListFixture,
  limitedSupportMe,
  loginEnvelope,
  opsHealthFixture,
  refundResponseFixture,
  searchFixtures,
  storageCleanupResponseFixture,
  storageInventoryFixture,
  subscriptionListFixture,
  superAdminMe,
  userFixtures,
  type AdminMeResponse,
  type AdminRefundResponse,
  type AdminStorageCleanupResponse,
  type AdminStorageResponse,
  type AdminSubscriptionListItem,
} from './fixtures'

/**
 * Playwright route-interception mock of `/api/**` (spec §10). Replaces MSW
 * in the browser: every endpoint a journey touches is stubbed with realistic
 * fixture JSON (the same objects the unit tests use), stateful where the
 * journey mutates (users PATCH), so tests never touch the real backend.
 */

export interface MockApiOptions {
  /** GET /api/v1/admin/me — default: super-admin with `*` permissions */
  me?: { status: number; body: AdminMeResponse | Record<string, unknown> } | null
  /** Users list rows (default: src/test/msw fixture) */
  users?: AdminUserListItem[]
  /** Subscriptions list rows */
  subscriptions?: AdminSubscriptionListItem[]
  /** GET /api/v1/admin/ops/storage */
  storage?: AdminStorageResponse
  /** POST /api/v1/admin/subscriptions/user/{id}/refund */
  refund?: { status?: number; body?: AdminRefundResponse | Record<string, unknown> }
  /** DELETE /api/v1/admin/ops/storage/temp */
  cleanup?: { status?: number; body?: AdminStorageCleanupResponse | Record<string, unknown> }
}

function respondJson(route: Route, body: unknown, status = 200): Promise<void> {
  return route.fulfill({
    status,
    contentType: 'application/json',
    body: typeof body === 'string' ? body : JSON.stringify(body),
  })
}

function unauthorizedBody(): Record<string, unknown> {
  return { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} }
}

/**
 * Seed the admin session (localStorage tokens) BEFORE the app boots, so
 * bootstrap() calls GET /api/v1/admin/me with an Authorization header.
 */
export async function seedAdminSession(page: Page): Promise<void> {
  await page.addInitScript(() => {
    window.localStorage.setItem(
      'fitcheck_admin_tokens',
      JSON.stringify({ access_token: 'e2e-access-token', refresh_token: 'e2e-refresh-token' }),
    )
  })
}

/** Install the `/api/**` interception layer. Call before page.goto(). */
export async function mockApi(page: Page, options: MockApiOptions = {}): Promise<void> {
  const users = structuredClone(options.users ?? userFixtures.list)
  const subscriptions = structuredClone(options.subscriptions ?? subscriptionListFixture)

  await page.route('**/api/**', async (route) => {
    const request = route.request()
    const method = request.method()
    const url = new URL(request.url())
    const path = url.pathname

    // ── Auth ─────────────────────────────────────────────────────────────
    if (method === 'POST' && path === '/api/v1/auth/login') {
      const body = (await request.postDataJSON()) as { password?: string } | null
      if (body?.password === 'wrong-password') {
        return respondJson(
          route,
          { error: 'Invalid email or password', code: 'AUTH_INVALID_CREDENTIALS', details: {} },
          401,
        )
      }
      return respondJson(route, loginEnvelope)
    }
    if (method === 'POST' && path === '/api/v1/auth/logout') {
      return route.fulfill({ status: 204 })
    }
    if (method === 'POST' && path === '/api/v1/auth/refresh') {
      return respondJson(route, {
        data: {
          access_token: 'e2e-refreshed-access-token',
          refresh_token: 'e2e-refreshed-refresh-token',
          user: { id: 'admin_1', email: 'admin@fitcheckaiapp.com' },
        },
        message: 'OK',
      })
    }

    // ── Session / ops ────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/me') {
      if (options.me === null) return respondJson(route, unauthorizedBody(), 401)
      const { status, body } = options.me ?? { status: 200, body: superAdminMe }
      return respondJson(route, body, status)
    }
    if (method === 'GET' && path === '/api/v1/admin/ops/health') {
      return respondJson(route, opsHealthFixture)
    }

    // ── Dashboard ────────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/dashboards/overview') {
      return respondJson(route, dashboardFixtures.overview)
    }
    if (method === 'GET' && path === '/api/v1/admin/dashboards/top-users') {
      return respondJson(route, dashboardFixtures.topUsers)
    }
    if (method === 'GET' && path === '/api/v1/admin/dashboards/referrals') {
      return respondJson(route, dashboardFixtures.referrals)
    }
    // Dashboard "Recent admin activity" panel (page 1, page_size 8).
    if (method === 'GET' && path === '/api/v1/admin/audit') {
      return respondJson(route, {
        items: auditEventsFixture,
        total: auditEventsFixture.length,
        page: 1,
        page_size: 8,
      })
    }

    // ── Users (list mirrors the backend service: q/status/role/plan + paging) ──
    const userDetailMatch = path.match(/^\/api\/v1\/admin\/users\/([^/]+)$/)
    const userActivityMatch = path.match(/^\/api\/v1\/admin\/users\/([^/]+)\/activity$/)
    const refundMatch = path.match(/^\/api\/v1\/admin\/subscriptions\/user\/([^/]+)\/refund$/)

    if (method === 'GET' && path === '/api/v1/admin/users') {
      const q = url.searchParams.get('q')?.toLowerCase() ?? ''
      const status = url.searchParams.get('status')
      const role = url.searchParams.get('role')
      const plan = url.searchParams.get('plan')
      const pageNum = Number(url.searchParams.get('page') ?? '1')
      const pageSize = Number(url.searchParams.get('page_size') ?? '20')

      const rows = users.filter((row) => {
        if (q && !`${row.email ?? ''} ${row.full_name ?? ''}`.toLowerCase().includes(q)) {
          return false
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
      const start = (pageNum - 1) * pageSize
      return respondJson(route, {
        items: rows.slice(start, start + pageSize),
        total: rows.length,
        page: pageNum,
        page_size: pageSize,
      })
    }
    if (method === 'GET' && userDetailMatch) {
      const userId = userDetailMatch[1]
      const row = users.find((user) => user.id === userId)
      if (!row) return respondJson(route, { error: 'User not found', code: 'USER_NOT_FOUND', details: {} }, 404)
      const detail = structuredClone(userFixtures.detail)
      detail.user = { ...(detail.user as Record<string, unknown>), ...row }
      return respondJson(route, detail)
    }
    if (method === 'PATCH' && userDetailMatch) {
      const userId = userDetailMatch[1]
      const row = users.find((user) => user.id === userId)
      if (!row) return respondJson(route, { error: 'User not found', code: 'USER_NOT_FOUND', details: {} }, 404)
      const body = (await request.postDataJSON()) as Record<string, unknown>
      row.is_active = (body.is_active as boolean | undefined) ?? row.is_active
      row.is_admin = (body.is_admin as boolean | undefined) ?? row.is_admin
      row.role = (body.role as AdminUserListItem['role'] | undefined) ?? row.role
      return respondJson(route, { user: row, changes: [{ action: 'user.updated', field: 'is_active' }] })
    }
    if (method === 'GET' && userActivityMatch) {
      return respondJson(route, userFixtures.activity)
    }

    // ── Subscriptions ────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/subscriptions') {
      const pageNum = Number(url.searchParams.get('page') ?? '1')
      const pageSize = Number(url.searchParams.get('page_size') ?? '20')
      const start = (pageNum - 1) * pageSize
      return respondJson(route, {
        items: subscriptions.slice(start, start + pageSize),
        total: subscriptions.length,
        page: pageNum,
        page_size: pageSize,
      })
    }
    if (method === 'POST' && refundMatch) {
      const { status = 200, body = refundResponseFixture } = options.refund ?? {}
      return respondJson(route, body, status)
    }

    // ── Storage ops ──────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/ops/storage') {
      return respondJson(route, options.storage ?? storageInventoryFixture)
    }
    if (method === 'DELETE' && path === '/api/v1/admin/ops/storage/temp') {
      const { status = 200, body = storageCleanupResponseFixture } = options.cleanup ?? {}
      return respondJson(route, body, status)
    }

    // ── Global search ─────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/search') {
      const q = url.searchParams.get('q')?.toLowerCase() ?? ''
      const match = (value: unknown): boolean =>
        typeof value === 'string' && value.toLowerCase().includes(q)
      const filter = (rows: Record<string, unknown>[] | undefined, fields: string[]) =>
        (rows ?? []).filter((row) => fields.some((field) => match(row[field])))
      return respondJson(route, {
        users: filter(searchFixtures.users, ['email', 'full_name', 'id']),
        posts: filter(searchFixtures.posts, ['title', 'slug', 'id']),
        tickets: filter(searchFixtures.tickets, ['subject', 'id']),
        promo_codes: filter(searchFixtures.promo_codes, ['code', 'id']),
      })
    }

    // ── Feedback ──────────────────────────────────────────────────────────
    if (method === 'GET' && path === '/api/v1/admin/feedback') {
      return respondJson(route, {
        items: feedbackListFixture,
        total: feedbackListFixture.length,
        page: 1,
        page_size: 20,
      })
    }

    // Anything a journey forgets to stub fails loudly instead of hitting the
    // real backend (there is none on :4173).
    return respondJson(
      route,
      { error: `No e2e mock for ${method} ${path}`, code: 'E2E_MOCK_MISSING', details: {} },
      404,
    )
  })
}

/** Standard authenticated super-admin session: tokens + authed /me. */
export async function authedPage(page: Page, options: MockApiOptions = {}): Promise<void> {
  await seedAdminSession(page)
  await mockApi(page, options)
}

/** Signed-in but permission-limited (support, no users.read). */
export async function limitedAdminPage(page: Page): Promise<void> {
  await seedAdminSession(page)
  await mockApi(page, { me: { status: 200, body: limitedSupportMe } })
}

export { superAdminMe, limitedSupportMe }
