import { describe, expect, it } from 'vitest'
import { isValidCalendarRange } from '../CalendarPage'

describe('calendar event validation', () => {
  it('rejects an end time before or equal to the start time', () => {
    expect(isValidCalendarRange('2026-07-31T10:00', '2026-07-31T09:00')).toBe(false)
    expect(isValidCalendarRange('2026-07-31T10:00', '2026-07-31T10:00')).toBe(false)
  })

  it('accepts a valid chronological range', () => {
    expect(isValidCalendarRange('2026-07-31T10:00', '2026-07-31T11:00')).toBe(true)
  })
})
