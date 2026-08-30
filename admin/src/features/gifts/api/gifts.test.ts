import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { exportGifts } from './gifts'

import { clearTokens } from '@/shared/api/tokens'
import { server } from '@/test/msw/server'

beforeEach(() => {
  clearTokens()
})

describe('gift voucher export', () => {
  it('downloads every filtered row from the server export endpoint', async () => {
    const requestedUrls: URL[] = []
    server.use(
      http.get('*/api/v1/admin/gifts/export.csv', ({ request }) => {
        requestedUrls.push(new URL(request.url))
        return new HttpResponse('Recipient,Status\r\nTaylor,claimed', {
          headers: { 'Content-Type': 'text/csv' },
        })
      }),
    )

    const csv = await exportGifts({
      page: 4,
      page_size: 20,
      q: 'Taylor',
      sort_by: undefined,
      sort_dir: undefined,
      filters: {
        source: 'paid',
        duration_months: '3',
        status: 'claimed',
        created_from: '2026-08-01',
        created_to: '2026-08-27',
      },
    })

    const searchParams = requestedUrls[0]?.searchParams
    expect(csv).toBe('Recipient,Status\r\nTaylor,claimed')
    expect(searchParams?.get('q')).toBe('Taylor')
    expect(searchParams?.get('source')).toBe('paid')
    expect(searchParams?.get('duration_months')).toBe('3')
    expect(searchParams?.get('status')).toBe('claimed')
    expect(searchParams?.get('created_from')).toBe('2026-08-01')
    expect(searchParams?.get('created_to')).toBe('2026-08-27')
    expect(searchParams?.has('page')).toBe(false)
    expect(searchParams?.has('page_size')).toBe(false)
  })
})
