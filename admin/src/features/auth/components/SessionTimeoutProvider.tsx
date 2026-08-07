import { useEffect, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'
import { toast } from 'sonner'

import { IDLE_CHECK_INTERVAL_MS, IDLE_TIMEOUT_MS, IDLE_WARNING_MS } from '@/shared/lib/constants'
import { useSessionStore } from '@/shared/stores/sessionStore'

/**
 * Admin idle-session UX (spec §4): toast warning at 25min, the store hard-
 * logs out at 30min (see sessionStore's idle watcher), and this provider
 * navigates to /login?reason=idle when that happens. Mounted in RootLayout
 * so it only runs inside the authenticated shell.
 */
export function SessionTimeoutProvider() {
  const { t } = useTranslation('auth')
  const navigate = useNavigate()
  const warnedRef = useRef(false)
  const status = useSessionStore((state) => state.status)

  useEffect(() => {
    if (status !== 'authed') {
      warnedRef.current = false
      return
    }
    const interval = setInterval(() => {
      const store = useSessionStore.getState()
      const idleMs = Date.now() - store.idleSince
      if (idleMs >= IDLE_TIMEOUT_MS) {
        store.logout('idle')
      } else if (idleMs >= IDLE_WARNING_MS && !warnedRef.current) {
        warnedRef.current = true
        toast.warning(t('session.warningTitle'), {
          description: t('session.warningMessage'),
        })
      }
    }, IDLE_CHECK_INTERVAL_MS)
    return () => clearInterval(interval)
  }, [status, t])

  // Navigate when the store's idle watcher logs the session out.
  useEffect(() => {
    const unsubscribe = useSessionStore.subscribe((state, previous) => {
      if (
        previous.status === 'authed' &&
        state.status === 'anon' &&
        state.lastLogoutReason === 'idle'
      ) {
        void navigate('/login?reason=idle', { replace: true })
      }
    })
    return unsubscribe
  }, [navigate])

  return null
}
