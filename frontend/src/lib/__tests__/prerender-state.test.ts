/**
 * Tests for the prerendered-query-state hydration helper (lib/prerenderState).
 *
 * The /blog prerender (entry-prerender.tsx) bakes a dehydrated React Query
 * cache into `#__FITCHECK_QUERY_STATE__`; main.tsx restores it via
 * hydratePrerenderedState. Every other route ships no state at all, and a
 * stale deploy can ship corrupt JSON — both must be silent no-ops.
 */

import { describe, it, expect } from 'vitest'
import { QueryClient, dehydrate } from '@tanstack/react-query'
import { hydratePrerenderedState } from '../prerenderState'

describe('hydratePrerenderedState', () => {
  it('restores dehydrated query data into a fresh client', () => {
    const source = new QueryClient()
    source.setQueryData(['blog', 'infinite', { category: undefined, search: '' }], {
      pages: [{ posts: [{ id: 1, title: 'Hello' }] }],
      pageParams: [1],
    })
    const rawJson = JSON.stringify(dehydrate(source))

    const target = new QueryClient()
    const hydrated = hydratePrerenderedState(target, rawJson)

    expect(hydrated).toBe(true)
    expect(target.getQueryData(['blog', 'infinite', { category: undefined, search: '' }])).toEqual({
      pages: [{ posts: [{ id: 1, title: 'Hello' }] }],
      pageParams: [1],
    })
  })

  it('returns false for corrupt JSON without throwing or touching the cache', () => {
    const target = new QueryClient()

    expect(() => hydratePrerenderedState(target, '{bad json')).not.toThrow()
    expect(hydratePrerenderedState(target, '{bad json')).toBe(false)
    expect(target.getQueryCache().getAll()).toHaveLength(0)
  })

  it.each([null, '', undefined])('returns false for %j', (rawJson) => {
    const target = new QueryClient()

    expect(hydratePrerenderedState(target, rawJson)).toBe(false)
    expect(target.getQueryCache().getAll()).toHaveLength(0)
  })
})
