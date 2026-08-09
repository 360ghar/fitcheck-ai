import { describe, expect, it } from 'vitest'

import { unwrapGenerationResult } from '@/lib/unwrap-generation-result'

const RESULT = { image_url: 'https://cdn.test/x.webp', image_base64: '' }

describe('unwrapGenerationResult — response-shape immunity', () => {
  it('unwraps the canonical envelope {data: T, message}', () => {
    expect(unwrapGenerationResult({ data: RESULT, message: 'OK' })).toEqual(RESULT)
  })

  it('unwraps an array-of-envelope [{data: T}] (observed production shape)', () => {
    expect(unwrapGenerationResult([{ data: RESULT, message: 'OK' }])).toEqual(RESULT)
  })

  it('unwraps an array-of-result [T]', () => {
    expect(unwrapGenerationResult([RESULT])).toEqual(RESULT)
  })

  it('passes a bare result object through', () => {
    expect(unwrapGenerationResult(RESULT)).toEqual(RESULT)
  })

  it('throws a coded UNEXPECTED_RESPONSE_FORMAT error for unusable payloads', () => {
    for (const payload of [null, undefined, '', 42, [], [null], 'plain string']) {
      let thrown: unknown = null
      try {
        unwrapGenerationResult(payload)
      } catch (e) {
        thrown = e
      }
      expect(thrown, `payload ${JSON.stringify(payload)} must throw`).toBeInstanceOf(Error)
      expect((thrown as Error & { code?: string }).code).toBe('UNEXPECTED_RESPONSE_FORMAT')
    }
  })
})
