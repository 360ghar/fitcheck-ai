import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  captureGiftClaimCredentialFromLocation,
  forgetGiftClaimCredential,
  readGiftClaimCredential,
} from '../gift-claim-credential'

const PUBLIC_ID = '44444444-4444-4444-8444-444444444444'
const SECRET = 'abcdefghijklmnopqrstuvwxyz0123456789_ABCD-EF'

describe('gift claim credential storage', () => {
  beforeEach(() => {
    forgetGiftClaimCredential(PUBLIC_ID)
    localStorage.clear()
    window.history.replaceState(null, '', '/')
    vi.useFakeTimers()
    vi.setSystemTime(new Date('2026-08-27T12:00:00Z'))
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('captures and removes a valid gift secret before page analytics can read it', () => {
    window.history.replaceState(
      null,
      '',
      `/gift/${PUBLIC_ID}?campaign=friend#claim=${SECRET}`,
    )

    expect(captureGiftClaimCredentialFromLocation()).toEqual({
      publicId: PUBLIC_ID,
      credential: SECRET,
    })
    expect(window.location.hash).toBe('')
    expect(window.location.pathname).toBe(`/gift/${PUBLIC_ID}`)
    expect(window.location.search).toBe('?campaign=friend')
    expect(readGiftClaimCredential(PUBLIC_ID)).toBe(SECRET)
  })

  it('strips an invalid claim fragment without storing it', () => {
    window.history.replaceState(null, '', `/gift/${PUBLIC_ID}#claim=too-short`)

    expect(captureGiftClaimCredentialFromLocation()).toEqual({
      publicId: PUBLIC_ID,
      credential: '',
    })
    expect(window.location.hash).toBe('')
    expect(readGiftClaimCredential(PUBLIC_ID)).toBe('')
  })

  it('expires a stored credential after seven days and supports explicit removal', () => {
    window.history.replaceState(null, '', `/gift/${PUBLIC_ID}#claim=${SECRET}`)
    captureGiftClaimCredentialFromLocation()
    expect(readGiftClaimCredential(PUBLIC_ID)).toBe(SECRET)

    forgetGiftClaimCredential(PUBLIC_ID)
    expect(readGiftClaimCredential(PUBLIC_ID)).toBe('')

    window.history.replaceState(null, '', `/gift/${PUBLIC_ID}#claim=${SECRET}`)
    captureGiftClaimCredentialFromLocation()
    vi.advanceTimersByTime(7 * 24 * 60 * 60 * 1_000 + 1)
    expect(readGiftClaimCredential(PUBLIC_ID)).toBe('')
  })
})
