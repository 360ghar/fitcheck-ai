/**
 * PostHog user identification component
 * Automatically identifies/resets users based on authentication state
 * and keeps session recording active across auth transitions.
 */

import { useEffect, useState } from 'react'
import type { PostHog } from 'posthog-js'
import { useAuthStore } from '@/stores/authStore'
import { ensureSessionRecording, getPostHog, initAnalytics } from '@/lib/analytics'

export function PostHogIdentify() {
  // Was `usePostHog()` from `posthog-js/react`. That context provider wrapped
  // the whole app in main.tsx and forced the ~370 kB SDK into the entry chunk.
  // PostHog now loads on idle, so this subscribes to that same deferred load
  // instead. Null until it resolves; the effect below already guards on it.
  const [posthog, setPosthog] = useState<PostHog | null>(() => getPostHog())

  useEffect(() => {
    let cancelled = false
    void initAnalytics().then((client) => {
      if (!cancelled) setPosthog(client)
    })
    return () => {
      cancelled = true
    }
  }, [])

  const user = useAuthStore((state) => state.user)
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)
  const hasHydrated = useAuthStore((state) => state.hasHydrated)

  useEffect(() => {
    // Wait for auth store to hydrate before making decisions
    if (!hasHydrated || !posthog) return

    // Always record the browser session (anonymous + authenticated).
    ensureSessionRecording()

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
      // Reset PostHog when user logs out (starts a new anonymous session)
      posthog.reset()
      ensureSessionRecording()
    }
  }, [posthog, user, isAuthenticated, hasHydrated])

  // This component doesn't render anything
  return null
}
