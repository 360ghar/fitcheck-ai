import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type {
  AdminFeedbackListItem,
  PageResponse_AdminFeedbackListItem_,
} from '@/shared/api/schemaTypes'

/**
 * Feedback (support tickets) fixtures + handlers, typed against the
 * generated schema. Rows carry the joined `user` dict like the backend.
 */

export const adminFeedbackFixture: AdminFeedbackListItem[] = [
  {
    id: 'ticket_1',
    user_id: 'user_1',
    user: { email: 'alice@example.com', full_name: 'Alice Example' },
    category: 'bug_report',
    subject: 'Photoshoot stuck at 3 of 10',
    description: 'The job never completes after three images.',
    status: 'open',
    app_platform: 'ios',
    app_version: '1.4.2',
    contact_email: 'alice@example.com',
    created_at: '2026-08-06T10:00:00Z',
    updated_at: '2026-08-06T10:00:00Z',
  },
  {
    id: 'ticket_2',
    user_id: null,
    user: null,
    category: 'feature_request',
    subject: 'Dark mode for outfits',
    description: 'Would love a dark theme toggle.',
    status: 'resolved',
    app_platform: null,
    app_version: null,
    contact_email: 'bob@example.com',
    created_at: '2026-08-05T09:30:00Z',
    updated_at: '2026-08-06T08:00:00Z',
  },
]

export interface FeedbackHandlersState {
  rows: AdminFeedbackListItem[]
  requests: URL[]
}

function defaultState(): FeedbackHandlersState {
  return {
    rows: structuredClone(adminFeedbackFixture),
    requests: [],
  }
}

function paginate(
  rows: AdminFeedbackListItem[],
  page: number,
  pageSize: number,
): PageResponse_AdminFeedbackListItem_ {
  const start = (page - 1) * pageSize
  return {
    items: rows.slice(start, start + pageSize),
    total: rows.length,
    page,
    page_size: pageSize,
  }
}

export function createFeedbackHandlers(initial?: Partial<FeedbackHandlersState>) {
  const state: FeedbackHandlersState = { ...defaultState(), ...initial }
  const { rows, requests } = state

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/admin/feedback', ({ request }) => {
      const url = new URL(request.url)
      requests.push(url)
      const params = url.searchParams
      const status = params.get('status')
      const category = params.get('category')
      const q = params.get('q')
      const page = Number(params.get('page') ?? '1')
      const pageSize = Number(params.get('page_size') ?? '20')

      const filtered = rows.filter((row) => {
        if (status && row.status !== status) return false
        if (category && row.category !== category) return false
        if (q) {
          const haystack = `${row.subject ?? ''} ${row.description ?? ''}`.toLowerCase()
          if (!haystack.includes(q.toLowerCase())) return false
        }
        return true
      })
      return HttpResponse.json(paginate(filtered, page, pageSize))
    }),
  ]

  return { handlers, state }
}

export const feedbackHandlers = createFeedbackHandlers().handlers
