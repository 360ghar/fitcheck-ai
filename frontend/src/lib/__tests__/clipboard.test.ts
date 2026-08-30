import { afterEach, describe, expect, it, vi } from 'vitest'

import { copyTextToClipboard } from '../clipboard'

describe('copyTextToClipboard', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('uses the asynchronous Clipboard API when available', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: { writeText },
    })

    await copyTextToClipboard('private gift link')

    expect(writeText).toHaveBeenCalledWith('private gift link')
    expect(document.querySelector('textarea')).toBeNull()
  })

  it('uses a temporary textarea when the Clipboard API is unavailable', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: undefined,
    })
    const execCommand = vi.fn().mockReturnValue(true)
    Object.defineProperty(document, 'execCommand', {
      configurable: true,
      value: execCommand,
    })

    await copyTextToClipboard('fallback gift link')

    expect(execCommand).toHaveBeenCalledWith('copy')
    expect(document.querySelector('textarea')).toBeNull()
  })

  it('rejects when neither copy mechanism succeeds', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: undefined,
    })
    Object.defineProperty(document, 'execCommand', {
      configurable: true,
      value: vi.fn().mockReturnValue(false),
    })

    await expect(copyTextToClipboard('uncopied link')).rejects.toThrow('could not be copied')
    expect(document.querySelector('textarea')).toBeNull()
  })
})
