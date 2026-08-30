import { describe, expect, it } from 'vitest'

import { giftErrorMessage } from '@/api/gifts'

describe('giftErrorMessage', () => {
  it('keeps allowlisted messages from plain ApiError objects', () => {
    expect(
      giftErrorMessage(
        { message: 'This gift has already been claimed' },
        'This gift could not be claimed.',
      ),
    ).toBe('This gift has already been claimed')
  })

  it('does not expose unallowlisted messages', () => {
    expect(
      giftErrorMessage(
        { message: 'internal database details' },
        'This gift could not be claimed.',
      ),
    ).toBe('This gift could not be claimed.')
  })
})
