import { render, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const { getSupabase, trackEvent, useAuthStore, authState } = vi.hoisted(() => {
  const state: {
    hasHydrated: boolean
    tokens: { access_token: string; refresh_token: string } | null
    refreshToken: ReturnType<typeof vi.fn>
  } = {
    hasHydrated: true,
    tokens: {
      access_token: 'app-access-token',
      refresh_token: 'app-refresh-token',
    },
    refreshToken: vi.fn(),
  }
  const store = Object.assign(
    <T,>(selector: (value: typeof state) => T) => selector(state),
    { getState: () => state },
  )
  return {
    authState: state,
    getSupabase: vi.fn(),
    trackEvent: vi.fn(),
    useAuthStore: store,
  }
})

vi.mock('@/lib/supabase', () => ({ getSupabase }))
vi.mock('@/lib/analytics', () => ({ trackEvent }))
vi.mock('@/stores/authStore', () => ({ useAuthStore }))

import OAuthBridgePage from '../OAuthBridgePage'

describe('OAuthBridgePage', () => {
  beforeEach(() => {
    authState.hasHydrated = true
    authState.tokens = {
      access_token: 'app-access-token',
      refresh_token: 'app-refresh-token',
    }
    authState.refreshToken.mockReset()
    getSupabase.mockReset()
    getSupabase.mockRejectedValue(new Error('No browser SDK session'))
    trackEvent.mockReset()
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: false,
        json: async () => ({ error_description: 'Authorization denied' }),
      }),
    )
  })

  it('uses the app auth-store token when the Supabase browser session is absent', async () => {
    render(
      <MemoryRouter initialEntries={['/oauth/bridge?state=txn-1']}>
        <OAuthBridgePage />
      </MemoryRouter>,
    )

    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1))
    const [, options] = (fetch as ReturnType<typeof vi.fn>).mock.calls[0]

    expect(JSON.parse(options.body)).toEqual({
      state: 'txn-1',
      access_token: 'app-access-token',
    })
  })
})
