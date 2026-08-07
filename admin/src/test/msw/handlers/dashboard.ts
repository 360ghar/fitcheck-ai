import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type {
  AdminOverviewResponse,
  AdminReferralsResponse,
  AdminRevenueResponse,
  AdminTopUsersResponse,
  AdminTrendsResponse,
} from '@/shared/api/schemaTypes'

/**
 * Dashboard fixtures + handlers, typed against the generated schema.
 * Payload keys mirror the backend service (`signups: {7d, 30d}`, `ai_jobs_7d:
 * {total, succeeded, failed}`, top-user rows `{user_id, email, full_name,
 * count}`; revenue `{mrr: {total, stripe, iap}, churn_events_30d: {...}}`;
 * trends rows `{day, count}` / `{day, total, succeeded, failed}` /
 * `{day, provider, count}`).
 */

export const adminOverviewFixture: AdminOverviewResponse = {
  signups: { '7d': 42, '30d': 180 },
  active_users: { '7d': 58, '30d': 204 },
  paid_subscriptions: 47,
  ai_jobs_7d: { total: 321, succeeded: 301, failed: 20 },
}

export const adminRevenueFixture: AdminRevenueResponse = {
  as_of: '2026-08-07T12:00:00+00:00',
  mrr: { total: 1240.5, stripe: 930.25, iap: 310.25 },
  paid_subscriptions: 47,
  trial_subscriptions: 5,
  churn_events_30d: { total: 3, stripe: 1, apple: 1, google: 1 },
  refunds_30d: 2,
}

export const adminTrendsFixture: AdminTrendsResponse = {
  days: 30,
  signups: [
    { day: '2026-07-09', count: 3 },
    { day: '2026-07-10', count: 5 },
  ],
  jobs: [
    { day: '2026-07-10', total: 12, succeeded: 11, failed: 1 },
    { day: '2026-07-11', total: 9, succeeded: 9, failed: 0 },
  ],
  paid: [
    { day: '2026-07-10', provider: 'stripe', count: 2 },
    { day: '2026-07-10', provider: 'iap', count: 1 },
    { day: '2026-07-11', provider: 'stripe', count: 1 },
    { day: '2026-07-11', provider: 'iap', count: 0 },
  ],
  active: [
    { day: '2026-07-10', count: 4 },
    { day: '2026-07-11', count: 6 },
  ],
}

export const adminTopUsersFixture: AdminTopUsersResponse = {
  top_outfits: [
    { user_id: 'user_1', email: 'alice@example.com', full_name: 'Alice Example', count: 12 },
    { user_id: 'user_5', email: 'erin@example.com', full_name: null, count: 9 },
    { user_id: 'user_3', email: 'carol@example.com', full_name: 'Carol Example', count: 6 },
  ],
  top_items: [
    { user_id: 'user_1', email: 'alice@example.com', full_name: 'Alice Example', count: 42 },
    { user_id: 'user_6', email: 'frank@example.com', full_name: 'Frank Example', count: 31 },
    { user_id: 'user_3', email: 'carol@example.com', full_name: 'Carol Example', count: 28 },
  ],
  top_referrers: [
    { user_id: 'user_7', email: 'grace@example.com', full_name: 'Grace Example', count: 5 },
    { user_id: 'user_1', email: 'alice@example.com', full_name: 'Alice Example', count: 3 },
  ],
}

export const adminReferralsFixture: AdminReferralsResponse = {
  codes_issued: 84,
  redemptions: 61,
  credits_granted: 112,
  credits_pending: 10,
}

export function createDashboardHandlers(): HttpHandler[] {
  return [
    http.get('*/api/v1/admin/dashboards/overview', () =>
      HttpResponse.json(adminOverviewFixture),
    ),
    http.get('*/api/v1/admin/dashboards/top-users', () =>
      HttpResponse.json(adminTopUsersFixture),
    ),
    http.get('*/api/v1/admin/dashboards/referrals', () =>
      HttpResponse.json(adminReferralsFixture),
    ),
    http.get('*/api/v1/admin/dashboards/revenue', () =>
      HttpResponse.json(adminRevenueFixture),
    ),
    http.get('*/api/v1/admin/dashboards/trends', () =>
      HttpResponse.json(adminTrendsFixture),
    ),
  ]
}

export const dashboardHandlers = createDashboardHandlers()
