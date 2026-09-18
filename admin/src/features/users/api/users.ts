import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { apiGet, apiPatch, apiPost } from '@/shared/api/client'
import type {
  AdminUserActivity,
  AdminUserBilling,
  AdminUserBodyProfile,
  AdminUserDetail,
  AdminUserGeneration,
  AdminUserGenerationsPage,
  AdminUserPatch,
  AdminUserReferrals,
  PageResponse_AdminUserListItem_,
} from '@/shared/api/schemaTypes'
import type { TableStateParams } from '@/shared/hooks/useTableState'
import { QUERY_RETRY, QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Users feature API — query-key factory + URL-table-state pattern (spec §2).
 * Every type and endpoint is built against the generated OpenAPI schema
 * (`src/shared/api/schema.d.ts`), not the legacy hand-written types:
 *
 *   GET    /api/v1/admin/users                 → PageResponse[AdminUserListItem]
 *   GET    /api/v1/admin/users/{user_id}       → AdminUserDetail
 *   PATCH  /api/v1/admin/users/{user_id}       → { user, changes }
 *   GET    /api/v1/admin/users/{user_id}/activity → AdminUserActivity
 *
 * List params (verified against the backend route): q, status (active|
 * suspended), role, plan, page, page_size (≤100), sort_by (created_at|
 * last_login_at|email|full_name), sort_dir.
 */

export const userKeys = {
  all: ['users'] as const,
  list: (params: TableStateParams) => [...userKeys.all, 'list', params] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
  activity: (id: string) => [...userKeys.all, 'activity', id] as const,
  generations: (id: string, params: GenerationsParams) =>
    [...userKeys.all, 'generations', id, params] as const,
  generation: (id: string, kind: string, generationId: string) =>
    [...userKeys.all, 'generation', id, kind, generationId] as const,
  billing: (id: string) => [...userKeys.all, 'billing', id] as const,
  referrals: (id: string) => [...userKeys.all, 'referrals', id] as const,
  bodyProfile: (id: string) => [...userKeys.all, 'bodyProfile', id] as const,
}

export interface GenerationsParams {
  kind: string
  status: string | null
  page: number
  pageSize: number
}

export function listUsers(
  params: TableStateParams,
): Promise<PageResponse_AdminUserListItem_> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
  })
  if (params.q) search.set('q', params.q)
  if (params.sort_by) search.set('sort_by', params.sort_by)
  if (params.sort_dir) search.set('sort_dir', params.sort_dir)
  for (const key of ['status', 'role', 'plan'] as const) {
    const value = params.filters[key]
    if (value) search.set(key, value)
  }
  return apiGet<PageResponse_AdminUserListItem_>(
    `/api/v1/admin/users?${search.toString()}`,
  )
}

export function useUsersQuery(params: TableStateParams) {
  return useQuery({
    queryKey: userKeys.list(params),
    queryFn: () => listUsers(params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
  })
}

export function getUserDetail(userId: string): Promise<AdminUserDetail> {
  return apiGet<AdminUserDetail>(`/api/v1/admin/users/${userId}`)
}

export function useUserDetailQuery(userId: string, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => getUserDetail(userId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: options?.enabled ?? true,
  })
}

export function getUserActivity(userId: string): Promise<AdminUserActivity> {
  return apiGet<AdminUserActivity>(`/api/v1/admin/users/${userId}/activity`)
}

export function useUserActivityQuery(userId: string, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: userKeys.activity(userId),
    queryFn: () => getUserActivity(userId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: options?.enabled ?? true,
  })
}

/**
 * Generations explorer — one normalized payload across item extraction runs,
 * saved outfits, outfit render runs, photoshoot jobs, and social imports.
 * `kind=all` merges each kind's recent window (see backend contract); the
 * per-kind tabs page exactly.
 */
export function getUserGenerations(
  userId: string,
  params: GenerationsParams,
): Promise<AdminUserGenerationsPage> {
  const search = new URLSearchParams({
    kind: params.kind,
    page: String(params.page),
    page_size: String(params.pageSize),
  })
  if (params.status) search.set('status', params.status)
  return apiGet<AdminUserGenerationsPage>(
    `/api/v1/admin/users/${userId}/generations?${search.toString()}`,
  )
}

export function useUserGenerationsQuery(
  userId: string,
  params: GenerationsParams,
  options?: { enabled?: boolean },
) {
  return useQuery({
    queryKey: userKeys.generations(userId, params),
    queryFn: () => getUserGenerations(userId, params),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: (options?.enabled ?? true) && userId !== '',
  })
}

export function getUserGeneration(
  userId: string,
  kind: string,
  generationId: string,
): Promise<AdminUserGeneration> {
  return apiGet<AdminUserGeneration>(
    `/api/v1/admin/users/${userId}/generations/${kind}/${generationId}`,
  )
}

export function useGenerationQuery(
  userId: string,
  kind: string,
  generationId: string,
  options?: { enabled?: boolean },
) {
  return useQuery({
    queryKey: userKeys.generation(userId, kind, generationId),
    queryFn: () => getUserGeneration(userId, kind, generationId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: (options?.enabled ?? true) && userId !== '' && kind !== '' && generationId !== '',
  })
}

export function getUserBilling(userId: string): Promise<AdminUserBilling> {
  return apiGet<AdminUserBilling>(`/api/v1/admin/users/${userId}/billing`)
}

export function useUserBillingQuery(userId: string, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: userKeys.billing(userId),
    queryFn: () => getUserBilling(userId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: options?.enabled ?? true,
  })
}

export function getUserReferrals(userId: string): Promise<AdminUserReferrals> {
  return apiGet<AdminUserReferrals>(`/api/v1/admin/users/${userId}/referrals`)
}

export function useUserReferralsQuery(userId: string, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: userKeys.referrals(userId),
    queryFn: () => getUserReferrals(userId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: options?.enabled ?? true,
  })
}

export function getUserBodyProfile(userId: string): Promise<AdminUserBodyProfile> {
  return apiGet<AdminUserBodyProfile>(`/api/v1/admin/users/${userId}/body-profile`)
}

export function useUserBodyProfileQuery(userId: string, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: userKeys.bodyProfile(userId),
    queryFn: () => getUserBodyProfile(userId),
    staleTime: QUERY_STALE_TIMES.lists,
    retry: QUERY_RETRY.get,
    enabled: options?.enabled ?? true,
  })
}

export function patchUser(userId: string, body: AdminUserPatch): Promise<Record<string, unknown>> {
  return apiPatch<Record<string, unknown>>(`/api/v1/admin/users/${userId}`, body)
}

export function extendTrial(
  userId: string,
  days: number,
): Promise<Record<string, unknown>> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/users/${userId}/subscription/extend-trial`,
    {
      days,
    },
  )
}

export function clearDailyCounters(userId: string): Promise<Record<string, unknown>> {
  return apiPost<Record<string, unknown>>(
    `/api/v1/admin/users/${userId}/ai/clear-daily`,
  )
}

export function useExtendTrial() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ userId, days }: { userId: string; days: number }) =>
      extendTrial(userId, days),
    onSettled: (_data, _error, { userId }) => {
      void queryClient.invalidateQueries({ queryKey: userKeys.detail(userId) })
      void queryClient.invalidateQueries({ queryKey: userKeys.activity(userId) })
      // Trial length feeds the subscriptions feature's cached lists/detail.
      // Feature isolation forbids importing its key factory, so invalidate
      // by the documented root (features/subscriptions/api/subscriptions.ts).
      void queryClient.invalidateQueries({ queryKey: ['subscriptions'] })
    },
    retry: QUERY_RETRY.mutations,
  })
}

export function useClearDailyCounters() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ userId }: { userId: string }) => clearDailyCounters(userId),
    onSettled: (_data, _error, { userId }) => {
      void queryClient.invalidateQueries({ queryKey: userKeys.detail(userId) })
      void queryClient.invalidateQueries({ queryKey: userKeys.activity(userId) })
      // Daily counters feed the quotas feature's cached pages. Feature
      // isolation forbids importing its key factory, so invalidate by the
      // documented root (features/quotas/api/quotas.ts).
      void queryClient.invalidateQueries({ queryKey: ['quotas'] })
    },
    retry: QUERY_RETRY.mutations,
  })
}

/**
 * Single-user mutation with an optimistic detail-cache update + rollback.
 * List keys are invalidated on settle (server-driven pages can't be patched
 * in place safely). Mutations are never auto-retried (spec §6).
 */
export function usePatchUser() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ userId, body }: { userId: string; body: AdminUserPatch }) =>
      patchUser(userId, body),
    onMutate: async ({ userId, body }) => {
      await queryClient.cancelQueries({ queryKey: userKeys.detail(userId) })
      const previous = queryClient.getQueryData<AdminUserDetail>(userKeys.detail(userId))
      if (previous) {
        queryClient.setQueryData<AdminUserDetail>(userKeys.detail(userId), {
          ...previous,
          user: {
            ...(previous.user as Record<string, unknown>),
            ...(body.is_active !== undefined ? { is_active: body.is_active } : {}),
            ...(body.is_admin !== undefined ? { is_admin: body.is_admin } : {}),
            ...(body.role !== undefined ? { role: body.role } : {}),
          },
        })
      }
      return { previous }
    },
    onError: (_error, { userId }, context) => {
      if (context?.previous) {
        queryClient.setQueryData(userKeys.detail(userId), context.previous)
      }
    },
    onSettled: (_data, _error, { userId }) => {
      void queryClient.invalidateQueries({ queryKey: userKeys.detail(userId) })
      void queryClient.invalidateQueries({ queryKey: userKeys.all })
    },
    retry: QUERY_RETRY.mutations,
  })
}
