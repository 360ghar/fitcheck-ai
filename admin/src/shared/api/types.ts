/**
 * Hand-written admin API contract.
 *
 * ⚠️ M3 PLACEHOLDER — these types are REPLACED by openapi-typescript codegen
 * (`npm run generate:api` → src/shared/api/schema.d.ts) once the backend
 * agent publishes `contracts/openapi.json`. Until then this file is the
 * single source of truth for the wire shapes; keep it isolated here so the
 * swap is a one-file change (features import from `@/shared/api/types` only).
 *
 * Contract assumptions (report to backend agent):
 *   - base path `/api/v1/admin/*`
 *   - list responses: `{ items, total, page, page_size }` (Paginated<T>)
 *   - auth: Supabase JWT bearer; login via `POST /api/v1/auth/login`
 *     returning `{ data: { access_token, refresh_token, user }, message }`
 *   - errors: `{ error, code, details }` with HTTP status
 */

// ────────────────────────────────────────────────────────────────────────────
// Pagination envelope
// ────────────────────────────────────────────────────────────────────────────

export interface Paginated<T> {
  items: T[]
  total: number
  page: number
  page_size: number
}

// ────────────────────────────────────────────────────────────────────────────
// Auth / me
// ────────────────────────────────────────────────────────────────────────────

export type AdminRole =
  | 'super_admin'
  | 'admin'
  | 'ops'
  | 'support'
  | 'content_editor'

export interface AdminUser {
  id: string
  email: string
  full_name: string | null
  avatar_url: string | null
  is_active: boolean
  role: AdminRole
  created_at: string
  last_login_at: string | null
}

export interface MeResponse {
  user: AdminUser
  role: AdminRole
  /** '*' grants everything */
  permissions: string[]
}

export interface LoginEnvelope {
  data: {
    access_token: string
    refresh_token: string
    user: {
      id: string
      email: string
      full_name: string | null
      avatar_url: string | null
      is_active: boolean
      email_verified: boolean
      created_at: string | null
      last_login_at: string | null
    }
  }
  message: string
}

/**
 * `POST /api/v1/auth/refresh` envelope (backend auth.py returns
 * `{ data: { access_token, refresh_token, user }, message: "OK" }`).
 * The generated schema types the body as `{[key: string]: unknown}`; this
 * hand-written alias pins the shape the client actually consumes. The
 * refreshed user record is not used by the admin surface (identity always
 * comes from `GET /api/v1/admin/me`).
 */
export interface RefreshEnvelope {
  data: {
    access_token: string
    refresh_token: string
    user?: { id: string; email: string }
  }
  message: string
}

// ────────────────────────────────────────────────────────────────────────────
// Users
// ────────────────────────────────────────────────────────────────────────────

export type UserStatus = 'active' | 'suspended' | 'pending'

export interface UserSummary {
  id: string
  email: string
  full_name: string | null
  avatar_url: string | null
  status: UserStatus
  role: AdminRole | 'user'
  plan: string | null
  items_count: number
  outfits_count: number
  created_at: string
  last_login_at: string | null
}

export interface UserDetail extends UserSummary {
  email_verified: boolean
  subscription: SubscriptionSummary | null
  quota: QuotaUsage | null
  is_admin: boolean
}

// ────────────────────────────────────────────────────────────────────────────
// Subscriptions & IAP
// ────────────────────────────────────────────────────────────────────────────

export type SubscriptionStatus =
  | 'active'
  | 'trialing'
  | 'past_due'
  | 'cancelled'
  | 'expired'

export interface SubscriptionSummary {
  id: string
  user_id: string
  user_email: string
  plan: string
  status: SubscriptionStatus
  current_period_start: string | null
  current_period_end: string | null
  cancel_at_period_end: boolean
  created_at: string
}

export interface IapTransaction {
  id: string
  user_id: string
  user_email: string
  platform: 'ios' | 'android'
  product_id: string
  amount_cents: number
  currency: string
  status: string
  transaction_id: string
  created_at: string
}

// ────────────────────────────────────────────────────────────────────────────
// Quotas (AI usage)
// ────────────────────────────────────────────────────────────────────────────

export interface QuotaUsage {
  user_id: string
  user_email: string
  plan: string
  extraction_used: number
  extraction_limit: number | null
  generation_used: number
  generation_limit: number | null
  photoshoot_used: number
  photoshoot_limit: number | null
  period_start: string | null
  period_end: string | null
}

// ────────────────────────────────────────────────────────────────────────────
// Promo codes
// ────────────────────────────────────────────────────────────────────────────

export interface PromoCode {
  id: string
  code: string
  description: string | null
  discount_percent: number | null
  credit_months: number | null
  max_redemptions: number | null
  redemptions: number
  expires_at: string | null
  is_active: boolean
  created_at: string
}

// ────────────────────────────────────────────────────────────────────────────
// Feedback tickets
// ────────────────────────────────────────────────────────────────────────────

export type FeedbackStatus = 'open' | 'in_progress' | 'resolved' | 'closed'

export interface FeedbackTicket {
  id: string
  user_id: string
  user_email: string
  subject: string
  message: string
  status: FeedbackStatus
  priority: 'low' | 'normal' | 'high' | 'urgent'
  created_at: string
  updated_at: string
}

// ────────────────────────────────────────────────────────────────────────────
// Audit log
// ────────────────────────────────────────────────────────────────────────────

export interface AuditEvent {
  id: string
  actor_id: string
  actor_email: string | null
  action: string
  entity_type: string
  entity_id: string | null
  payload: Record<string, unknown> | null
  ip: string | null
  user_agent: string | null
  created_at: string
}

// ────────────────────────────────────────────────────────────────────────────
// Dashboard
// ────────────────────────────────────────────────────────────────────────────

export interface DashboardOverview {
  signups_7d: number
  signups_30d: number
  active_users_7d: number
  active_users_30d: number
  paid_subscriptions: number
  mrr_cents: number
  jobs_today: number
  storage_bytes: number
  storage_limit_bytes: number | null
}

export interface DashboardTrendPoint {
  date: string
  signups: number
  active_users: number
  jobs: number
}

export interface TopUsersEntry {
  user_id: string
  user_email: string
  full_name: string | null
  metric_value: number
}

export interface TopUsers {
  most_items: TopUsersEntry[]
  most_outfits: TopUsersEntry[]
  referral_counts: TopUsersEntry[]
}

export interface ReferralStats {
  total_codes_created: number
  total_redemptions: number
  credit_months_granted: number
  pending_redemptions: number
}

// ────────────────────────────────────────────────────────────────────────────
// Search (command palette)
// ────────────────────────────────────────────────────────────────────────────

export interface SearchPostResult {
  id: string
  title: string
  status: string
  published_at: string | null
}

export interface SearchResults {
  users: UserSummary[]
  posts: SearchPostResult[]
  tickets: FeedbackTicket[]
  promo_codes: PromoCode[]
}

// ────────────────────────────────────────────────────────────────────────────
// Ops
// ────────────────────────────────────────────────────────────────────────────

// Matches the backend's GET /api/v1/admin/ops/health (verified against
// contracts/openapi.json → src/shared/api/schema.d.ts, AdminOpsHealthResponse).
export interface OpsHealth {
  status: string // 'ok' | 'degraded' | 'down' — backend free-form string
  service: string
  version: string
  commit: string
  schema_ready?: boolean | null
  rss_mb?: number | null
}

export interface StorageInfo {
  total_bytes: number
  used_bytes: number
  temp_bytes: number
  by_bucket: Array<{ bucket: string; bytes: number }>
  limit_bytes: number | null
}
