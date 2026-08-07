import { http, HttpResponse } from 'msw'

import type { LoginEnvelope, MeResponse } from '@/shared/api/types'
import { auditHandlers } from '@/test/msw/handlers/audit'
import { blogHandlers } from '@/test/msw/handlers/blog'
import { dashboardHandlers } from '@/test/msw/handlers/dashboard'
import { iapHandlers } from '@/test/msw/handlers/iap'
import { quotasHandlers } from '@/test/msw/handlers/quotas'
import { searchHandlers } from '@/test/msw/handlers/search'
import { subscriptionsHandlers } from '@/test/msw/handlers/subscriptions'
import { usersHandlers } from '@/test/msw/handlers/users'

/**
 * Global MSW registry — composed from per-feature handler modules
 * (`handlers/<feature>.ts`, typed against the generated schema) plus the
 * auth/session handlers the app shell needs. Individual tests override with
 * `server.use(...)` for specific failure modes.
 */

const adminUser: MeResponse['user'] = {
  id: 'admin_1',
  email: 'admin@fitcheckaiapp.com',
  full_name: 'Ada Admin',
  avatar_url: null,
  is_active: true,
  role: 'super_admin',
  created_at: '2026-01-01T00:00:00Z',
  last_login_at: '2026-08-01T00:00:00Z',
}

const meResponse: MeResponse = {
  user: adminUser,
  role: 'super_admin',
  permissions: ['*'],
}

const opsHealth = {
  status: 'ok',
  service: 'api',
  version: '1.0.0-test',
  commit: 'abc123',
  schema_ready: true,
}

export const handlers = [
  ...usersHandlers,
  ...dashboardHandlers,
  ...auditHandlers,
  ...quotasHandlers,
  ...searchHandlers,
  ...blogHandlers,
  ...subscriptionsHandlers,
  ...iapHandlers,

  http.get('*/api/v1/admin/me', () => HttpResponse.json(meResponse)),

  http.get('*/api/v1/admin/ops/health', () => HttpResponse.json(opsHealth)),

  http.post('*/api/v1/auth/logout', () => new HttpResponse(null, { status: 204 })),

  http.post('*/api/v1/auth/refresh', async ({ request }) => {
    const body = (await request.json()) as { refresh_token?: string }
    if (!body.refresh_token) {
      return HttpResponse.json(
        { error: 'Refresh token is required', code: 'VALIDATION_ERROR', details: {} },
        { status: 422 },
      )
    }
    if (body.refresh_token === 'dead-refresh-token') {
      return HttpResponse.json(
        { error: 'Invalid or expired refresh token', code: 'AUTH_TOKEN_EXPIRED', details: {} },
        { status: 401 },
      )
    }
    return HttpResponse.json({
      data: {
        access_token: 'refreshed-access-token',
        refresh_token: 'refreshed-refresh-token',
        user: { id: 'admin_1', email: 'admin@fitcheckaiapp.com' },
      },
      message: 'OK',
    })
  }),

  http.post('*/api/v1/auth/login', async ({ request }) => {
    const body = (await request.json()) as { email?: string; password?: string }
    if (body.password === 'wrong-password') {
      return HttpResponse.json(
        { error: 'Invalid email or password', code: 'AUTH_INVALID_CREDENTIALS', details: {} },
        { status: 401 },
      )
    }
    if (body.password === 'unconfirmed') {
      return HttpResponse.json(
        { error: 'Email not confirmed', code: 'AUTH_EMAIL_NOT_CONFIRMED', details: {} },
        { status: 401 },
      )
    }
    const envelope: LoginEnvelope = {
      data: {
        access_token: 'test-access-token',
        refresh_token: 'test-refresh-token',
        user: {
          id: 'admin_1',
          email: body.email ?? 'admin@fitcheckaiapp.com',
          full_name: 'Ada Admin',
          avatar_url: null,
          is_active: true,
          email_verified: true,
          created_at: '2026-01-01T00:00:00Z',
          last_login_at: '2026-08-01T00:00:00Z',
        },
      },
      message: 'OK',
    }
    return HttpResponse.json(envelope)
  }),
]
