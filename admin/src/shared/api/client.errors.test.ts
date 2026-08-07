import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { apiGet } from './client'

import { clearTokens } from '@/shared/api/tokens'
import { server } from '@/test/msw/server'

/**
 * Error normalization (client): backend error envelopes — including the
 * correlation_id support reference — must reduce to a typed ApiError so
 * features can map them to i18n copy (see features/auth/lib/loginError.ts).
 */

beforeEach(() => {
  clearTokens()
})

describe('client error normalization', () => {
  it('captures correlation_id from a backend HTTP error envelope', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          {
            error: 'Not Found',
            code: 'HTTP_ERROR',
            details: {},
            correlation_id: 'cid-abc-123',
          },
          { status: 404 },
        ),
      ),
    )
    await expect(apiGet('/api/v1/admin/me')).rejects.toMatchObject({
      status: 404,
      code: 'HTTP_ERROR',
      message: 'Not Found',
      correlationId: 'cid-abc-123',
    })
  })

  it('omits correlationId when the envelope does not carry one', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Internal Server Error', code: 'HTTP_ERROR', details: {} },
          { status: 500 },
        ),
      ),
    )
    await expect(apiGet('/api/v1/admin/me')).rejects.toMatchObject({
      status: 500,
      code: 'HTTP_ERROR',
      correlationId: undefined,
    })
  })
})
