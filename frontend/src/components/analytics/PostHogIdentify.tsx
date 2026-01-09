/**
 * PostHog user identification component
 * Automatically identifies/resets users based on authentication state
 */

import { useEffect } from 'react'
import { usePostHog } from 'posthog-js/react'
import { useAuthStore } from '@/stores/authStore'

export function PostHogIdentify() {
  const posthog = usePostHog()
  const user = useAuthStore((state) => state.user)
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)
  const hasHydrated = useAuthStore((state) => state.hasHydrated)

  useEffect(() => {
    // Wait for auth store to hydrate before making decisions
    if (!hasHydrated || !posthog) return

    if (isAuthenticated && user) {
      // Identify the user with PostHog
      posthog.identify(user.id, {
        email: user.email,
        name: user.full_name,
        avatar_url: user.avatar_url,
        is_active: user.is_active,
        email_verified: user.email_verified,
        created_at: user.created_at,
        last_login_at: user.last_login_at,
      })

      // Set person properties that persist across sessions
      posthog.people.set({
        email: user.email,
        name: user.full_name,
        $avatar: user.avatar_url,
      })
    } else {
      // Reset PostHog when user logs out
      posthog.reset()
    }
  }, [posthog, user, isAuthenticated, hasHydrated])

  // This component doesn't render anything
  return null
}
