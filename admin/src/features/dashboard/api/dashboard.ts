import { useQuery } from '@tanstack/react-query'

import { apiGet } from '@/shared/api/client'
import { isApiError } from '@/shared/api/errors'
import type { components } from '@/shared/api/schema'
import type {
  AdminFunnelResponse,
  AdminOverviewResponse,
  AdminReferralsResponse,
  AdminRetentionResponse,
  AdminRevenueResponse,
  AdminTopUsersResponse,
  AdminTrendsResponse,
  PageResponse_AdminAuditEventItem_,
} from '@/shared/api/schemaTypes'
import { usePermission } from '@/shared/hooks/usePermission'
import { QUERY_RETRY, QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Dashboard API — read-only aggregates (spec §4 + revenue/trends wave + Phase 1a):
 *
 *   GET /api/v1/admin/dashboards/overview   → AdminOverviewResponse
 *   GET /api/v1/admin/dashboards/top-users  → AdminTopUsersResponse
 *   GET /api/v1/admin/dashboards/referrals  → AdminReferralsResponse
 *   GET /api/v1/admin/dashboards/revenue    → AdminRevenueResponse
 *   GET /api/v1/admin/dashboards/trends     → AdminTrendsResponse
 *   GET /api/v1/admin/dashboards/funnel     → JsonRecord (optional, graceful fallback)
 *   GET /api/v1/admin/dashboards/retention  → JsonRecord (optional, graceful fallback)
 *   GET /api/v1/admin/ops/health            → AdminOpsHealthResponse (shared with ops feature)
 *
 * Overview payload keys (from the backend service): signups/active_users are
 * `{ "7d": n, "30d": n }` maps, ai_jobs_7d is `{ total, succeeded, failed }`.
 * All fields are optional in the schema — pages read them defensively.
 * Extended keys `trials_ending_7d` / `tickets_open_48h` are read defensively
 * with "—" fallback when the backend has not yet exposed them.
 *
 * "Recent admin activity" reuses the audit endpoint (page 1, 8 rows). It
 * lives here, not in features/audit, because the dashboard feature may only
 * import shared code (feature isolation).
 *
 * Funnel / retention / ops-health are optional: when the backend does not
 * yet expose the endpoint (404) or the caller lacks permission (403), the
 * query resolves to null and the page renders an EmptyState + client-side
 * approximation — never a hard ErrorState. This is the build-time-flag
 * path (no migration) for Phase 1a single-page dashboard.
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
  funnel: (days: number) => [...dashboardBase, 'funnel', days] as const,
  retention: (weeks: number) => [...dashboardBase, 'retention', weeks] as const,
  // Shares the ops feature's query key ('ops', 'health') so the dashboard and
  // the Topbar deployment pill hit the cache once, not the network twice.
  opsHealth: ['ops', 'health'] as const,
}

export type AdminOpsHealthResponse = components['schemas']['AdminOpsHealthResponse']

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

// ────────────────────────────────────────────────────────────────────────────
// Optional Phase 1a endpoints — graceful 404/403 → null, never a hard error.
// These are build-time-flag gated (no migration); the dashboard renders an
// EmptyState + client-side approximation when the backend does not yet expose
// them, satisfying the "degrade gracefully" constraint.
// ────────────────────────────────────────────────────────────────────────────

async function swallowNotFound<T>(promise: Promise<T>): Promise<T | null> {
  try {
    return await promise
  } catch (error) {
    if (isApiError(error) && (error.status === 404 || error.status === 403)) return null
    throw error
  }
}

export function getFunnel(days: number): Promise<AdminFunnelResponse | null> {
  return swallowNotFound(
    apiGet<AdminFunnelResponse>(`/api/v1/admin/dashboards/funnel?days=${days}`),
  )
}

export function useFunnelQuery(days: number) {
  return useQuery({
    queryKey: dashboardKeys.funnel(days),
    queryFn: () => getFunnel(days),
    staleTime: 60_000,
    retry: 1,
    enabled: true,
  })
}

export function getRetention(weeks: number): Promise<AdminRetentionResponse | null> {
  return swallowNotFound(
    apiGet<AdminRetentionResponse>(`/api/v1/admin/dashboards/retention?weeks=${weeks}`),
  )
}

export function useRetentionQuery(weeks: number) {
  return useQuery({
    queryKey: dashboardKeys.retention(weeks),
    queryFn: () => getRetention(weeks),
    staleTime: 60_000,
    retry: 1,
    enabled: true,
  })
}

export function getOpsHealth(): Promise<AdminOpsHealthResponse | null> {
  return swallowNotFound(apiGet<AdminOpsHealthResponse>('/api/v1/admin/ops/health'))
}

export function useOpsHealthQuery() {
  // GET /admin/ops/health requires ops.read — don't request it (or 403) for
  // roles without the permission; the shared key reuses the Topbar's cache.
  const { can } = usePermission()
  return useQuery({
    queryKey: dashboardKeys.opsHealth,
    queryFn: getOpsHealth,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: false,
    enabled: can('ops.read'),
  })
}
