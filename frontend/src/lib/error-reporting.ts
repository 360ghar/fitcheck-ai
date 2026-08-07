/**
 * Lazy Sentry wrapper.
 *
 * `@sentry/react` was imported statically by main.tsx and both error
 * boundaries, so the SDK shipped in the entry chunk on the critical path of
 * every pageview — even with `VITE_SENTRY_DSN` unset, because the old `if
 * (sentryDsn)` guard only gated `init()`, never the import.
 *
 * Everything here dynamic-imports the SDK, so it lands in its own async chunk:
 * fetched when an error is actually reported, or shortly after first paint if
 * a DSN is configured. Errors are rare and already fatal to the current view,
 * so paying an import at report time costs nothing that matters.
 *
 * Every function is fire-and-forget and swallows its own failures — error
 * reporting must never be able to cause a second error.
 */

import { logger } from './logger'
import { onIdle } from './on-idle'

type SentryModule = typeof import('@sentry/react')

const dsn = import.meta.env.VITE_SENTRY_DSN as string | undefined

let sentryPromise: Promise<SentryModule | null> | null = null

/** Load the SDK once. Resolves to null when no DSN is configured. */
function loadSentry(): Promise<SentryModule | null> {
  if (!dsn) return Promise.resolve(null)
  if (!sentryPromise) {
    sentryPromise = import('@sentry/react')
      .then((Sentry) => {
        Sentry.init({
          dsn,
          tracesSampleRate: 0.1,
          environment: import.meta.env.MODE,
        })
        return Sentry
      })
      .catch(() => null)
  }
  return sentryPromise
}

/**
 * Warm the SDK after first paint so the first real error does not also pay the
 * network round-trip. No-ops without a DSN.
 */
export function initErrorReporting(): void {
  if (!dsn) return
  onIdle(() => void loadSentry(), { timeout: 5000, fallbackDelay: 2000 })
}

/** Report an exception. Always logs locally; forwards to Sentry when configured. */
export function captureException(
  error: unknown,
  context?: { extra?: Record<string, unknown> }
): void {
  try {
    logger.error('[captureException]', error)
    void loadSentry().then((Sentry) => {
      if (!Sentry) return
      Sentry.captureException(
        error instanceof Error ? error : new Error(String(error ?? 'Unknown error')),
        context
      )
    })
  } catch {
    // Reporting must never throw.
  }
}
