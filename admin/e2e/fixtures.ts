import type { components } from '../src/shared/api/schema'
import { adminAuditEventFixture } from '../src/test/msw/handlers/audit'
import {
  adminOverviewFixture,
  adminReferralsFixture,
  adminTopUsersFixture,
} from '../src/test/msw/handlers/dashboard'
import { adminSearchFixture } from '../src/test/msw/handlers/search'
import {
  adminUserActivityFixture,
  adminUserDetailFixture,
  adminUserListFixture,
} from '../src/test/msw/handlers/users'

/**
 * E2E fixtures — the SAME plain objects the unit tests mock with MSW
 * (src/test/msw/handlers/*), plus the subscription/storage payloads those
 * modules don't cover (typed against the generated OpenAPI schema). The
 * handler modules only use `import type` for schema imports, so Playwright's
 * esbuild bundling erases them and the fixtures import cleanly.
 */

export type AdminMeResponse = components['schemas']['AdminMeResponse']
export type AdminSubscriptionListItem = components['schemas']['AdminSubscriptionListItem']
export type AdminStorageResponse = components['schemas']['AdminStorageResponse']
export type AdminStorageCleanupResponse = components['schemas']['AdminStorageCleanupResponse']
export type AdminRefundResponse = components['schemas']['AdminRefundResponse']
export type AdminFeedbackListItem = components['schemas']['AdminFeedbackListItem']

export const dashboardFixtures = {
  overview: adminOverviewFixture,
  topUsers: adminTopUsersFixture,
  referrals: adminReferralsFixture,
}

export const searchFixtures = adminSearchFixture

/** Audit events for the dashboard "Recent admin activity" panel. */
export const auditEventsFixture = adminAuditEventFixture

export const userFixtures = {
  list: adminUserListFixture,
  detail: adminUserDetailFixture,
  activity: adminUserActivityFixture,
}

/** Super-admin /me — grants every permission (`*`). */
export const superAdminMe: AdminMeResponse = {
  user: {
    id: 'admin_1',
    email: 'admin@fitcheckaiapp.com',
    full_name: 'Ada Admin',
    avatar_url: null,
    is_active: true,
    is_admin: true,
    role: 'super_admin',
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-08-01T00:00:00Z',
    last_login_at: '2026-08-06T09:00:00Z',
    email_verified: true,
    custom_daily_quota: null,
  },
  role: 'super_admin',
  permissions: ['*'],
}

/** Non-admin /me — signed in, but no users.* access (→ 403 page on /users). */
export const limitedSupportMe: AdminMeResponse = {
  user: {
    id: 'admin_2',
    email: 'support@fitcheckaiapp.com',
    full_name: 'Sofia Support',
    avatar_url: null,
    is_active: true,
    is_admin: false,
    role: 'support',
    created_at: '2026-02-01T00:00:00Z',
    updated_at: '2026-08-01T00:00:00Z',
    last_login_at: '2026-08-06T09:00:00Z',
    email_verified: true,
    custom_daily_quota: null,
  },
  role: 'support',
  permissions: ['dashboards.read', 'feedback.read'],
}

export const loginEnvelope = {
  data: {
    access_token: 'e2e-access-token',
    refresh_token: 'e2e-refresh-token',
    user: {
      id: 'admin_1',
      email: 'admin@fitcheckaiapp.com',
      full_name: 'Ada Admin',
      avatar_url: null,
      is_active: true,
      email_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      last_login_at: '2026-08-06T09:00:00Z',
    },
  },
  message: 'OK',
}

export const subscriptionListFixture: AdminSubscriptionListItem[] = [
  {
    id: 'sub_1',
    user_id: 'user_1',
    user: { id: 'user_1', email: 'alice@example.com', full_name: 'Alice Example' },
    plan_type: 'pro_monthly',
    status: 'active',
    amount: 19.99,
    currency: 'usd',
    cancel_at_period_end: false,
    billing_provider: 'stripe',
    current_period_start: '2026-07-10T00:00:00Z',
    current_period_end: '2026-08-10T00:00:00Z',
    created_at: '2026-07-10T00:00:00Z',
  },
  {
    id: 'sub_2',
    user_id: 'user_3',
    user: { id: 'user_3', email: 'carol@example.com', full_name: 'Carol Example' },
    plan_type: 'plus_yearly',
    status: 'canceled',
    amount: 49.99,
    currency: 'usd',
    cancel_at_period_end: true,
    billing_provider: 'apple',
    current_period_start: '2026-01-01T00:00:00Z',
    current_period_end: '2027-01-01T00:00:00Z',
    created_at: '2026-01-01T00:00:00Z',
  },
]

export const refundResponseFixture: AdminRefundResponse = {
  refund_id: 're_e2e_123',
  // Backend returns Stripe minor units (cents) — the page divides by 100.
  amount: 1999,
  currency: 'usd',
  status: 'succeeded',
  charge_id: 'ch_e2e_123',
}

export const storageInventoryFixture: AdminStorageResponse = {
  bucket: 'preview-temp',
  count: 12,
  scanned_keys: 12,
  total_bytes: 3_456_789,
  truncated: false,
  oldest: { last_modified: '2026-08-01T00:00:00Z', key: 'preview/tmp/oldest.jpg' },
  newest: { last_modified: '2026-08-06T00:00:00Z', key: 'preview/tmp/newest.jpg' },
  items: [
    { key: 'preview/tmp/oldest.jpg', size: 2_400_000, last_modified: '2026-08-01T00:00:00Z' },
    { key: 'preview/tmp/mid.jpg', size: 950_000, last_modified: '2026-08-03T00:00:00Z' },
    { key: 'preview/tmp/newest.jpg', size: 106_789, last_modified: '2026-08-06T00:00:00Z' },
  ],
}

export const storageCleanupResponseFixture: AdminStorageCleanupResponse = {
  deleted: 12,
  bytes_freed: 3_456_789,
  remaining: 0,
  truncated: false,
}

export const opsHealthFixture = {
  status: 'ok',
  service: 'api',
  version: '1.0.0-e2e',
  commit: 'e2e',
  schema_ready: true,
}

export const feedbackListFixture: AdminFeedbackListItem[] = [
  {
    id: 'ticket_9',
    user_id: 'user_1',
    user: { id: 'user_1', email: 'alice@example.com', full_name: 'Alice Example' },
    subject: 'Trial not activating',
    description: 'My trial never started after subscribing.',
    category: 'billing',
    status: 'open',
    app_platform: 'ios',
    app_version: '1.2.3',
    created_at: '2026-08-05T14:00:00Z',
    updated_at: '2026-08-05T14:00:00Z',
  },
  {
    id: 'ticket_10',
    user_id: null,
    contact_email: 'anon@example.com',
    subject: 'Dark mode request',
    description: 'Would love a dark theme.',
    category: 'feature_request',
    status: 'in_progress',
    app_platform: 'android',
    app_version: '1.2.0',
    created_at: '2026-08-04T09:00:00Z',
    updated_at: '2026-08-05T10:00:00Z',
  },
]
