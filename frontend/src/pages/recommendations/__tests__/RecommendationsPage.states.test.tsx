import { describe, expect, it } from 'vitest'
import { getRecommendationsClosetState } from '../RecommendationsPage'

describe('recommendations closet state', () => {
  it('does not treat a failed wardrobe request as an empty closet', () => {
    expect(getRecommendationsClosetState(0, false, { message: 'network down' })).toBe('error')
  })

  it('keeps a genuinely empty closet actionable', () => {
    expect(getRecommendationsClosetState(0, false, null)).toBe('empty')
  })

  it('keeps loading distinct from ready data', () => {
    expect(getRecommendationsClosetState(0, true, null)).toBe('loading')
    expect(getRecommendationsClosetState(2, false, null)).toBe('ready')
  })
})
