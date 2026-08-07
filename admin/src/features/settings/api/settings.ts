import { useQuery } from '@tanstack/react-query'

import { apiGet } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import { QUERY_STALE_TIMES } from '@/shared/lib/constants'

/**
 * Settings feature API — read-only deployment info (no mutations).
 *
 *   GET /api/v1/admin/settings → AdminSettingsResponse
 */

export type AdminSettingsResponse = components['schemas']['AdminSettingsResponse']

export const settingsKeys = {
  all: ['settings'] as const,
}

export function fetchSettings(): Promise<AdminSettingsResponse> {
  return apiGet<AdminSettingsResponse>('/api/v1/admin/settings')
}

export function useSettingsQuery() {
  return useQuery({
    queryKey: settingsKeys.all,
    queryFn: fetchSettings,
    staleTime: QUERY_STALE_TIMES.static,
  })
}
