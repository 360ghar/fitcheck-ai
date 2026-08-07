import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

import type { AdminSearchResponse } from '@/shared/api/schemaTypes'

/**
 * Global search fixtures + handler, typed against the generated schema.
 * Result objects are `{[key: string]: unknown}` dicts per the contract — the
 * keys mirror the backend search service selects (users: id/email/full_name,
 * posts: id/slug/title/category, tickets: id/subject/status,
 * promo_codes: id/code/plan_type/active).
 */

export const adminSearchFixture: AdminSearchResponse = {
  users: [
    {
      id: 'user_1',
      email: 'alice@example.com',
      full_name: 'Alice Example',
      avatar_url: null,
      is_active: true,
      role: 'user',
      created_at: '2026-05-01T08:30:00Z',
    },
    {
      id: 'user_8',
      email: 'amir@example.com',
      full_name: 'Amir Haddad',
      avatar_url: null,
      is_active: true,
      role: 'user',
      created_at: '2026-07-02T10:00:00Z',
    },
  ],
  posts: [
    {
      id: 'post_3',
      slug: 'capsule-wardrobe-guide',
      title: 'Capsule Wardrobe Guide',
      category: 'style',
      is_published: true,
      created_at: '2026-07-15T09:00:00Z',
    },
  ],
  tickets: [
    {
      id: 'ticket_9',
      subject: 'Trial not activating',
      category: 'billing',
      status: 'open',
      created_at: '2026-08-05T14:00:00Z',
    },
  ],
  promo_codes: [
    {
      id: 'promo_1',
      code: 'SUMMER2026',
      plan_type: 'pro_monthly',
      active: true,
      used_count: 12,
      expires_at: '2026-09-01T00:00:00Z',
      created_at: '2026-07-20T10:00:00Z',
    },
  ],
}

export function createSearchHandlers(): HttpHandler[] {
  return [
    http.get('*/api/v1/admin/search', ({ request }) => {
      const q = new URL(request.url).searchParams.get('q')?.toLowerCase() ?? ''
      const match = (value: unknown): boolean => {
        if (typeof value !== 'string') return false
        return value.toLowerCase().includes(q)
      }
      // Mirror the backend: each group is filtered by a contains-match on its
      // searchable fields; an unmatched query returns empty groups.
      const filter = (rows: Record<string, unknown>[] | undefined, fields: string[]) =>
        (rows ?? []).filter((row) => fields.some((field) => match(row[field])))
      return HttpResponse.json({
        users: filter(adminSearchFixture.users, ['email', 'full_name', 'id']),
        posts: filter(adminSearchFixture.posts, ['title', 'slug', 'id']),
        tickets: filter(adminSearchFixture.tickets, ['subject', 'id']),
        promo_codes: filter(adminSearchFixture.promo_codes, ['code', 'id']),
      })
    }),
  ]
}

export const searchHandlers = createSearchHandlers()
