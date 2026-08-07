import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type {
  AdminAuditEventItem,
  PageResponse_AdminAuditEventItem_,
} from '@/shared/api/schemaTypes'

/**
 * Audit fixtures + handlers, typed against the generated schema. Note the
 * backend joins the actor row into `actor: { email, full_name }` (there is
 * no flat `actor_email` field — that was legacy drift). Filters mirror the
 * backend service: action (ilike), entity_type (eq), actor_id (eq), and
 * from/to (created_at range).
 */

export const adminAuditEventFixture: AdminAuditEventItem[] = [
  {
    id: 'audit_1',
    actor_id: 'admin_1',
    actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
    action: 'user.suspended',
    entity_type: 'user',
    entity_id: 'user_2',
    payload: { field: 'is_active', before: true, after: false, reason: 'spam' },
    ip: '203.0.113.10',
    user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
    created_at: '2026-08-06T10:00:00Z',
  },
  {
    id: 'audit_2',
    actor_id: 'admin_1',
    actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
    action: 'user.role_changed',
    entity_type: 'user',
    entity_id: 'user_3',
    payload: { field: 'role', before: 'user', after: 'support' },
    ip: '203.0.113.10',
    user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
    created_at: '2026-08-06T09:30:00Z',
  },
  {
    id: 'audit_3',
    actor_id: 'admin_2',
    actor: { email: 'ops@fitcheckaiapp.com', full_name: 'Owen Ops' },
    action: 'promo.created',
    entity_type: 'promo_code',
    entity_id: 'promo_1',
    payload: { code: 'SUMMER2026', plan_type: 'pro_monthly', months: 1 },
    ip: '198.51.100.4',
    user_agent: 'Mozilla/5.0 (X11; Linux x86_64)',
    created_at: '2026-08-06T08:15:00Z',
  },
  {
    id: 'audit_4',
    actor_id: 'admin_1',
    actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
    action: 'feedback.updated',
    entity_type: 'support_ticket',
    entity_id: 'ticket_9',
    payload: { field: 'status', before: 'open', after: 'resolved' },
    ip: '203.0.113.10',
    user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
    created_at: '2026-08-05T16:45:00Z',
  },
  {
    id: 'audit_5',
    actor_id: 'admin_2',
    actor: { email: 'ops@fitcheckaiapp.com', full_name: 'Owen Ops' },
    action: 'quota.override',
    entity_type: 'user',
    entity_id: 'user_1',
    payload: { custom_daily_quota: 150 },
    ip: '198.51.100.4',
    user_agent: 'Mozilla/5.0 (X11; Linux x86_64)',
    created_at: '2026-08-05T12:00:00Z',
  },
  {
    id: 'audit_6',
    actor_id: 'admin_1',
    actor: { email: 'admin@fitcheckaiapp.com', full_name: 'Ada Admin' },
    action: 'subscription.refunded',
    entity_type: 'subscription',
    entity_id: 'sub_7',
    payload: { refund_id: 're_123', amount: 4900, currency: 'usd' },
    ip: '203.0.113.10',
    user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
    created_at: '2026-08-04T11:20:00Z',
  },
]

export interface AuditHandlersState {
  events: AdminAuditEventItem[]
  requests: URL[]
}

function paginateAudit(
  items: AdminAuditEventItem[],
  page: number,
  pageSize: number,
): PageResponse_AdminAuditEventItem_ {
  const start = (page - 1) * pageSize
  return {
    items: items.slice(start, start + pageSize),
    total: items.length,
    page,
    page_size: pageSize,
  }
}

export function createAuditHandlers(initial?: Partial<AuditHandlersState>) {
  const state: AuditHandlersState = {
    events: structuredClone(adminAuditEventFixture),
    requests: [],
    ...initial,
  }

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/audit', ({ request }) => {
      const url = new URL(request.url)
      state.requests.push(url)
      const params = url.searchParams
      const action = params.get('action')?.toLowerCase()
      const entityType = params.get('entity_type')
      const actorId = params.get('actor_id')
      const from = params.get('from')
      const to = params.get('to')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const rows = state.events.filter((event) => {
        if (action) {
          const matches = event.action.toLowerCase().includes(action)
          if (!matches) return false
        }
        if (entityType && event.entity_type !== entityType) return false
        if (actorId && event.actor_id !== actorId) return false
        if (from && typeof event.created_at === 'string' && event.created_at < from) {
          return false
        }
        if (to && typeof event.created_at === 'string' && event.created_at > to) return false
        return true
      })

      return HttpResponse.json(paginateAudit(rows, page, pageSize))
    }),
  ]

  return { handlers, state }
}

export const auditHandlers = createAuditHandlers().handlers
