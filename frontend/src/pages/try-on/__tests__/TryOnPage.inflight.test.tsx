/**
 * The try-on "request in flight" bit used to be a module-level `let`. It
 * survived remounts (which is required — the job pill must not vanish when the
 * user navigates away and back) but nothing outside `handleGenerate` could
 * reset it, so a request that never settled wedged the page in the generating
 * step for the rest of the SPA session.
 *
 * It now lives in `jobUiStore`, which keeps the survives-remount behaviour and
 * makes the state recoverable from anywhere via `clearJob('try-on')`.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { act, render, screen, waitFor } from '@testing-library/react'

vi.mock('react-dropzone', () => ({
  useDropzone: () => ({
    getRootProps: () => ({}),
    getInputProps: () => ({}),
    isDragActive: false,
  }),
}))

vi.mock('@/api/ai', () => ({ generateTryOn: vi.fn() }))
vi.mock('@/api/users', () => ({ uploadAvatar: vi.fn() }))

const authState = { setUser: vi.fn(), user: { id: 'u1' } }
vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (s: unknown) => unknown) => selector(authState),
  useCurrentUser: () => authState.user,
  useUserAvatar: () => 'https://example.test/avatar.png',
}))

import { useJobUiStore } from '@/stores/jobUiStore'
import TryOnPage from '@/pages/try-on/TryOnPage'
import { getTryOnErrorMessage } from '@/lib/try-on-errors'

const GENERATING = /Generating your try-on/i

describe('TryOnPage in-flight state', () => {
  beforeEach(() => {
    useJobUiStore.setState({ job: null })
  })

  it('restores the generating view on mount while the job is still active', async () => {
    useJobUiStore.getState().setJob({
      id: 'try-on',
      label: 'Generating try-on…',
      isActive: true,
      href: '/try-on',
    })

    render(<TryOnPage />)

    expect(await screen.findByText(GENERATING)).toBeTruthy()
  })

  it('is recoverable from outside the component via clearJob', async () => {
    useJobUiStore.getState().setJob({
      id: 'try-on',
      label: 'Generating try-on…',
      isActive: true,
      href: '/try-on',
    })

    render(<TryOnPage />)
    expect(await screen.findByText(GENERATING)).toBeTruthy()

    // A stuck request is cleared from anywhere — this is what the module-level
    // `let` made impossible.
    act(() => {
      useJobUiStore.getState().clearJob('try-on')
    })

    await waitFor(() => {
      expect(screen.queryByText(GENERATING)).toBeNull()
    })
  })

  it('does not restore the generating view when no job is active', () => {
    render(<TryOnPage />)
    expect(screen.queryByText(GENERATING)).toBeNull()
  })
})

describe('getTryOnErrorMessage', () => {
  it('maps a quota-exhausted 429 (RATE_LIMIT_EXCEEDED) to friendly quota copy', () => {
    const message = getTryOnErrorMessage({
      isAxiosError: true,
      message: 'Request failed with status code 429',
      response: { status: 429, data: { error: 'Daily limit exceeded', code: 'RATE_LIMIT_EXCEEDED' } },
    })
    expect(message).toContain('limit')
    expect(message).not.toContain('Request failed')
  })

  it('maps an upstream capacity failure to a retry-later message', () => {
    const message = getTryOnErrorMessage({
      isAxiosError: true,
      message: 'Request failed with status code 503',
      response: { status: 503, data: { error: 'provider down', error_kind: 'upstream_quota' } },
    })
    expect(message).toContain('busy')
  })

  it('maps an axios transport failure (no response) to connection copy', () => {
    const message = getTryOnErrorMessage({
      isAxiosError: true,
      message: 'Network Error',
      request: {},
    })
    expect(message).toContain('connection')
  })

  it('falls back to generic copy for unknown errors', () => {
    const message = getTryOnErrorMessage(new Error('boom'))
    expect(message).toContain('Couldn’t generate')
  })
})
