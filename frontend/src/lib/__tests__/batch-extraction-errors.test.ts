/**
 * Tests for getBatchExtractionErrorMessage - the upload-flow error renderer.
 *
 * Regression (2026-07-31): the batch upload UI showed Axios's generic
 * "Request failed with status code 503" because it used `error.message`
 * directly, discarding the backend's response body. The backend now logs the
 * diagnostic detail ("AI quota reservation is unavailable: ...") server-side;
 * this helper must NEVER render that raw body — only friendly, stable copy
 * derived from the error's machine fields.
 */
import { describe, expect, it } from 'vitest';

import {
  BATCH_START_ERROR_FALLBACK,
  BATCH_START_ERROR_NETWORK,
  BATCH_START_ERROR_SERVICE,
  getBatchExtractionErrorMessage,
} from '@/lib/batch-extraction-errors';

/** Axios errors are duck-typed via the `isAxiosError` flag; build one without importing axios. */
function makeAxiosError(
  message: string,
  status: number,
  data?: Record<string, unknown>,
): Error {
  return Object.assign(new Error(message), {
    isAxiosError: true,
    response: { status, data, headers: {} },
  })
}

describe('getBatchExtractionErrorMessage', () => {
  it('shows friendly service copy for a 503 AI_SERVICE_ERROR, never the raw body', () => {
    const err = makeAxiosError('Request failed with status code 503', 503, {
      error:
        'AI quota reservation is unavailable: the reserve_ai_usage database ' +
        'function is missing (hosted Supabase migrations 022/024/026 not applied).',
      code: 'AI_SERVICE_ERROR',
    })

    const message = getBatchExtractionErrorMessage(err)
    expect(message).toBe(BATCH_START_ERROR_SERVICE)
    expect(message).not.toContain('reserve_ai_usage')
    expect(message).not.toContain('022/024/026')
    expect(message).not.toContain('Request failed with status code 503')
  })

  it('shows friendly service copy for a generic 5xx without a body', () => {
    const err = makeAxiosError('Request failed with status code 500', 500)

    expect(getBatchExtractionErrorMessage(err)).toBe(BATCH_START_ERROR_SERVICE)
  })

  it('shows network copy when the request never reached the server', () => {
    const err = Object.assign(new Error('Network Error'), {
      isAxiosError: true,
      response: undefined,
    })

    expect(getBatchExtractionErrorMessage(err)).toBe(BATCH_START_ERROR_NETWORK)
  })

  it('uses the flow-specific fallback for a plain Error', () => {
    expect(getBatchExtractionErrorMessage(new Error('boom'))).toBe(
      BATCH_START_ERROR_FALLBACK,
    )
  })

  it('uses the flow-specific fallback for non-errors', () => {
    expect(getBatchExtractionErrorMessage(undefined)).toBe(BATCH_START_ERROR_FALLBACK)
    expect(getBatchExtractionErrorMessage(null)).toBe(BATCH_START_ERROR_FALLBACK)
  })
})
