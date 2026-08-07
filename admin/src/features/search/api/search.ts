import { apiGet } from '@/shared/api/client'
import type { AdminSearchResponse } from '@/shared/api/schemaTypes'

/**
 * Global search (command palette): GET /api/v1/admin/search?q= returns
 * top-5 hits per entity kind. Typed against the generated schema — every
 * result array is `{[key: string]: unknown}[]`; the palette renders it
 * defensively via features/search/lib/results.ts.
 */
export function searchAll(q: string): Promise<AdminSearchResponse> {
  const params = new URLSearchParams({ q })
  return apiGet<AdminSearchResponse>(`/api/v1/admin/search?${params.toString()}`)
}
