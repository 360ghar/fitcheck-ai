/**
 * Thin PostHog helpers for product events.
 *
 * Session recording is configured in main.tsx (PostHogProvider).
 * This module is for explicit product events that autocapture cannot name.
 */

import posthog from 'posthog-js'

type Props = Record<string, string | number | boolean | null | undefined>

function sanitize(props?: Props): Record<string, string | number | boolean> | undefined {
  if (!props) return undefined
  const out: Record<string, string | number | boolean> = {}
  for (const [key, value] of Object.entries(props)) {
    if (value === undefined || value === null) continue
    out[key] = value
  }
  return Object.keys(out).length ? out : undefined
}

/** Fire a named product event. No-ops if PostHog is not ready. */
export function trackEvent(event: string, properties?: Props): void {
  try {
    if (typeof posthog?.capture !== 'function') return
    posthog.capture(event, sanitize(properties))
  } catch {
    // Analytics must never break product flows.
  }
}

/** Attach durable person properties (last session metadata, etc.). */
export function setPersonProperties(properties: Props): void {
  try {
    if (typeof posthog?.people?.set !== 'function') return
    const clean = sanitize(properties)
    if (clean) posthog.people.set(clean)
  } catch {
    // ignore
  }
}

/** Ensure session recording is running for the current browser session. */
export function ensureSessionRecording(): void {
  try {
    if (typeof posthog?.startSessionRecording === 'function') {
      posthog.startSessionRecording()
    }
  } catch {
    // ignore
  }
}
