import { useQuery } from '@tanstack/react-query'

import { apiGet } from '@/shared/api/client'
import type {
  AdminOverviewResponse,
  AdminReferralsResponse,
  AdminRevenueResponse,
  AdminTopUsersResponse,
  AdminTrendsResponse,
  PageResponse_AdminAuditEventItem_,
} from '@/shared/api/schemaTypes'
import { QUERY_RETRY, QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Dashboard API — read-only aggregates (spec §4 + revenue/trends wave):
 *
 *   GET /api/v1/admin/dashboards/overview   → AdminOverviewResponse
 *   GET /api/v1/admin/dashboards/top-users  → AdminTopUsersResponse
 *   GET /api/v1/admin/dashboards/referrals  → AdminReferralsResponse
 *   GET /api/v1/admin/dashboards/revenue    → AdminRevenueResponse
 *   GET /api/v1/admin/dashboards/trends     → AdminTrendsResponse
 *
 * Overview payload keys (from the backend service): signups/active_users are
 * `{ "7d": n, "30d": n }` maps, ai_jobs_7d is `{ total, succeeded, failed }`.
 * All fields are optional in the schema — pages read them defensively.
 *
 * "Recent admin activity" reuses the audit endpoint (page 1, 8 rows). It
 * lives here, not in features/audit, because the dashboard feature may only
 * import shared code (feature isolation).
 */

const dashboardBase = ['dashboard'] as const

export const dashboardKeys = {
  all: dashboardBase,
  overview: [...dashboardBase, 'overview'] as const,
  topUsers: [...dashboardBase, 'top-users'] as const,
  referrals: [...dashboardBase, 'referrals'] as const,
  revenue: [...dashboardBase, 'revenue'] as const,
  trends: (days: number) => [...dashboardBase, 'trends', days] as const,
  recentAudit: [...dashboardBase, 'recent-audit'] as const,
}

export function getOverview(): Promise<AdminOverviewResponse> {
  return apiGet<AdminOverviewResponse>('/api/v1/admin/dashboards/overview')
}

export function useOverviewQuery() {
  return useQuery({
    queryKey: dashboardKeys.overview,
    queryFn: getOverview,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getTopUsers(): Promise<AdminTopUsersResponse> {
  return apiGet<AdminTopUsersResponse>('/api/v1/admin/dashboards/top-users')
}

export function useTopUsersQuery() {
  return useQuery({
    queryKey: dashboardKeys.topUsers,
    queryFn: getTopUsers,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getReferrals(): Promise<AdminReferralsResponse> {
  return apiGet<AdminReferralsResponse>('/api/v1/admin/dashboards/referrals')
}

export function useReferralsQuery() {
  return useQuery({
    queryKey: dashboardKeys.referrals,
    queryFn: getReferrals,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getRevenue(): Promise<AdminRevenueResponse> {
  return apiGet<AdminRevenueResponse>('/api/v1/admin/dashboards/revenue')
}

export function useRevenueQuery() {
  return useQuery({
    queryKey: dashboardKeys.revenue,
    queryFn: getRevenue,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getTrends(days: number): Promise<AdminTrendsResponse> {
  return apiGet<AdminTrendsResponse>(`/api/v1/admin/dashboards/trends?days=${days}`)
}

export function useTrendsQuery(days: number) {
  return useQuery({
    queryKey: dashboardKeys.trends(days),
    queryFn: () => getTrends(days),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getRecentAuditEvents(): Promise<PageResponse_AdminAuditEventItem_> {
  return apiGet<PageResponse_AdminAuditEventItem_>('/api/v1/admin/audit?page=1&page_size=8')
}

export function useRecentAuditQuery() {
  return useQuery({
    queryKey: dashboardKeys.recentAudit,
    queryFn: getRecentAuditEvents,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}
