/**
 * Typed aliases over the generated OpenAPI schema (src/shared/api/schema.d.ts).
 *
 * The generator nests every model under `components['schemas']` (and every
 * route under `operations`), so feature code would otherwise write
 * `components['schemas']['AdminUserListItem']` everywhere. This seam re-exports
 * the admin-panel models as flat, stable names — still fully derived from the
 * authoritative generated file; `npm run generate:api` regenerates schema.d.ts
 * and these aliases follow automatically.
 */
import type { components } from './schema'

export type AdminAuditEventItem = components['schemas']['AdminAuditEventItem']
export type AdminFeedbackListItem = components['schemas']['AdminFeedbackListItem']
export type AdminOverviewResponse = components['schemas']['AdminOverviewResponse']
export type AdminQuotaOverride = components['schemas']['AdminQuotaOverride']
export type AdminQuotaUsageItem = components['schemas']['AdminQuotaUsageItem']
export type AdminReferralsResponse = components['schemas']['AdminReferralsResponse']
export type AdminRevenueResponse = components['schemas']['AdminRevenueResponse']
export type AdminSearchResponse = components['schemas']['AdminSearchResponse']
export type AdminTopUsersResponse = components['schemas']['AdminTopUsersResponse']
export type AdminTrendsResponse = components['schemas']['AdminTrendsResponse']
export type AdminUserActivity = components['schemas']['AdminUserActivity']
export type AdminUserDetail = components['schemas']['AdminUserDetail']
export type AdminUserListItem = components['schemas']['AdminUserListItem']
export type AdminUserPatch = components['schemas']['AdminUserPatch']
export type PageResponse_AdminAuditEventItem_ =
  components['schemas']['PageResponse_AdminAuditEventItem_']
export type PageResponse_AdminFeedbackListItem_ =
  components['schemas']['PageResponse_AdminFeedbackListItem_']
export type PageResponse_AdminQuotaUsageItem_ =
  components['schemas']['PageResponse_AdminQuotaUsageItem_']
export type PageResponse_AdminUserListItem_ =
  components['schemas']['PageResponse_AdminUserListItem_']
