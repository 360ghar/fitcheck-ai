/**
 * `main.tsx` wraps the app in StrictMode, which runs effects twice in dev.
 * A second `handleOAuthCallback()` posts /auth/oauth/sync again *after*
 * `pending_referral_code` has been consumed from localStorage, so the referral
 * is silently dropped. The callback must fire exactly once per mount.
 */
import { StrictMode } from 'react'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, waitFor } from '@testing-library/react'

const navigate = vi.fn()
const handleOAuthCallback = vi.fn()

vi.mock('react-router-dom', () => ({
  useNavigate: () => navigate,
}))

vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (s: unknown) => unknown) =>
    selector({ handleOAuthCallback }),
}))

import AuthCallbackPage from '@/pages/auth/AuthCallbackPage'

describe('AuthCallbackPage', () => {
  beforeEach(() => {
    navigate.mockReset()
    handleOAuthCallback.mockReset()
    handleOAuthCallback.mockResolvedValue(undefined)
  })

  it('calls handleOAuthCallback once under StrictMode', async () => {
    render(
      <StrictMode>
        <AuthCallbackPage />
      </StrictMode>
    )

    await waitFor(() => expect(navigate).toHaveBeenCalled())
    expect(handleOAuthCallback).toHaveBeenCalledTimes(1)
    expect(navigate).toHaveBeenCalledWith('/dashboard', { replace: true })
  })
})
