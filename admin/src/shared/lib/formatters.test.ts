import { describe, expect, it } from 'vitest'

import {
  formatBytes,
  formatDate,
  formatDateTime,
  formatMoney,
  formatNumber,
  relativeTime,
  truncate,
} from './formatters'

describe('formatDate', () => {
  it('formats ISO dates (TZ is UTC in tests)', () => {
    expect(formatDate('2026-08-01T12:00:00Z')).toBe('Aug 1, 2026')
  })

  it('returns an em dash for null/undefined/invalid input', () => {
    expect(formatDate(null)).toBe('—')
    expect(formatDate(undefined)).toBe('—')
    expect(formatDate('not-a-date')).toBe('—')
  })
})

describe('formatDateTime', () => {
  it('formats date + time', () => {
    expect(formatDateTime('2026-08-01T12:30:00Z')).toBe('Aug 1, 2026, 12:30 PM')
  })

  it('handles invalid input', () => {
    expect(formatDateTime(null)).toBe('—')
    expect(formatDateTime('garbage')).toBe('—')
  })
})

describe('relativeTime', () => {
  it('produces human-relative output', () => {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString()
    expect(relativeTime(fiveMinutesAgo)).toMatch(/5 minutes ago/)
  })

  it('handles invalid input', () => {
    expect(relativeTime(null)).toBe('—')
    expect(relativeTime('garbage')).toBe('—')
  })
})

describe('formatMoney', () => {
  it('formats USD with cents', () => {
    expect(formatMoney(1234.5)).toBe('$1,234.50')
    expect(formatMoney(0.1)).toBe('$0.10')
    expect(formatMoney(0)).toBe('$0.00')
  })

  it('supports other currencies', () => {
    expect(formatMoney(5, 'EUR')).toBe('€5.00')
  })
})

describe('formatBytes', () => {
  it('handles bytes, KB, MB, GB', () => {
    expect(formatBytes(0)).toBe('0 B')
    expect(formatBytes(512)).toBe('512 B')
    expect(formatBytes(1536)).toBe('1.5 KB')
    expect(formatBytes(3 * 1024 ** 3)).toBe('3 GB')
  })

  it('handles invalid input', () => {
    expect(formatBytes(-1)).toBe('—')
    expect(formatBytes(Number.NaN)).toBe('—')
  })
})

describe('formatNumber', () => {
  it('adds thousands separators', () => {
    expect(formatNumber(1234567)).toBe('1,234,567')
    expect(formatNumber(42)).toBe('42')
  })
})

describe('truncate', () => {
  it('truncates with an ellipsis, keeping the total under maxLength', () => {
    expect(truncate('hello world', 5)).toBe('hell…')
    expect(truncate('short', 10)).toBe('short')
    expect(truncate('hi', 1)).toBe('…')
  })
})
