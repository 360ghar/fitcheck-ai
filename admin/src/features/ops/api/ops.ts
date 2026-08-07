import { useQuery } from '@tanstack/react-query'

import { apiDelete, apiGet } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Ops feature API — deployment health + temp-storage inventory/cleanup.
 *
 *   GET    /api/v1/admin/ops/health      → AdminOpsHealthResponse
 *   GET    /api/v1/admin/ops/storage     → AdminStorageResponse
 *   DELETE /api/v1/admin/ops/storage/temp → AdminStorageCleanupResponse
 *
 * The health query is polled by the Topbar deployment-status pill
 * (app/layout/DeploymentStatus.tsx) every 60s.
 */

export type AdminOpsHealthResponse = components['schemas']['AdminOpsHealthResponse']
export type AdminStorageResponse = components['schemas']['AdminStorageResponse']
export type AdminStorageTempItem = components['schemas']['AdminStorageTempItem']
export type AdminStorageCleanupResponse = components['schemas']['AdminStorageCleanupResponse']

export const opsKeys = {
  health: ['ops', 'health'] as const,
  storage: ['ops', 'storage'] as const,
}

export function fetchOpsHealth(): Promise<AdminOpsHealthResponse> {
  return apiGet<AdminOpsHealthResponse>('/api/v1/admin/ops/health')
}

export function useOpsHealthQuery(options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: opsKeys.health,
    queryFn: fetchOpsHealth,
    refetchInterval: 60_000,
    staleTime: QUERY_STALE_TIMES.lists,
    retry: 1,
    // Critical list: refetch when the tab regains focus (spec §6)
    refetchOnWindowFocus: true,
    // GET /admin/ops/health requires ops.read — roles without it must never
    // poll (a permanent 403 would render a red "Down" pill).
    enabled: options?.enabled ?? true,
  })
}

export function fetchStorageInventory(): Promise<AdminStorageResponse> {
  return apiGet<AdminStorageResponse>('/api/v1/admin/ops/storage')
}

export function useStorageQuery() {
  return useQuery({
    queryKey: opsKeys.storage,
    queryFn: fetchStorageInventory,
    staleTime: QUERY_STALE_TIMES.lists,
  })
}

export function cleanupTempObjects(): Promise<AdminStorageCleanupResponse> {
  return apiDelete('/api/v1/admin/ops/storage/temp')
}
