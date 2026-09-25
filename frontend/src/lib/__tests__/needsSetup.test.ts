import { describe, expect, it } from 'vitest'
import { isSetupDone, markSetupDone, needsSetup, shouldShowSetup } from '../activation'

const NOW = Date.parse('2026-09-25T12:00:00Z')
const day = 24 * 60 * 60 * 1000
const created = (daysAgo: number) => new Date(NOW - daysAgo * day).toISOString()

describe('needsSetup', () => {
  it('sends a new account without a gender to setup', () => {
    expect(needsSetup({ gender: null, created_at: created(0) }, false, NOW)).toBe(true)
  })

  it('skips accounts that finished, chose a gender, or are older than 7 days', () => {
    expect(needsSetup({ gender: null, created_at: created(0) }, true, NOW)).toBe(false)
    expect(needsSetup({ gender: 'female', created_at: created(0) }, false, NOW)).toBe(false)
    expect(needsSetup({ gender: null, created_at: created(8) }, false, NOW)).toBe(false)
  })

  it('skips a missing user or an unreadable date', () => {
    expect(needsSetup(null, false, NOW)).toBe(false)
    expect(needsSetup({ gender: null, created_at: 'nope' }, false, NOW)).toBe(false)
  })
})

describe('shouldShowSetup', () => {
  it('gates on styles when gender is unknown', () => {
    expect(shouldShowSetup({ createdAt: created(0), styles: [], done: false, now: NOW })).toBe(true)
    expect(shouldShowSetup({ createdAt: created(0), styles: ['Casual'], done: false, now: NOW })).toBe(false)
  })

  it('gates on either field when both are known', () => {
    expect(
      shouldShowSetup({ createdAt: created(0), gender: 'female', styles: [], done: false, now: NOW }),
    ).toBe(true)
    expect(
      shouldShowSetup({ createdAt: created(0), gender: 'female', styles: ['Casual'], done: false, now: NOW }),
    ).toBe(false)
  })

  it('never traps on unknown profile data or an old account', () => {
    expect(shouldShowSetup({ createdAt: created(0), done: false, now: NOW })).toBe(false)
    expect(shouldShowSetup({ createdAt: created(8), gender: null, done: false, now: NOW })).toBe(false)
    expect(shouldShowSetup({ createdAt: created(0), gender: null, done: true, now: NOW })).toBe(false)
  })
})

describe('setup done flag', () => {
  it('round-trips per user', () => {
    localStorage.clear()
    expect(isSetupDone('u1')).toBe(false)
    markSetupDone('u1')
    expect(isSetupDone('u1')).toBe(true)
    expect(isSetupDone('u2')).toBe(false)
  })
})
