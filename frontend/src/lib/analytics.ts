/**
 * Thin PostHog helpers for product events.
 *
 * Session recording is configured here (see `loadPostHog`), not in main.tsx.
 * This module is for explicit product events that autocapture cannot name.
 *
 * PostHog is loaded LAZILY. The SDK's module build is ~370 kB raw — roughly
 * half of what used to be a 664 kB entry chunk — and it was imported at module
 * scope here and as `<PostHogProvider>` in main.tsx, so it blocked first paint
 * on every marketing pageview and put two third-party hosts on the critical
 * path. It is now imported after first paint.
 *
 * The trade-off is deliberate: roughly the first second of a session is not in
 * the replay. Every helper below already no-ops until the SDK is ready, which
 * is exactly the behaviour the lazy load needs.
 */

import type { PostHog } from 'posthog-js'

import { onIdle } from './on-idle'

type Props = Record<string, string | number | boolean | null | undefined>

/** Set once the SDK has loaded and init'd. Null until then — callers no-op. */
let posthog: PostHog | null = null
let readyPromise: Promise<PostHog | null> | null = null

/**
 * Buffer for events fired before PostHog has loaded. `trackEvent` pushes here
 * when the SDK is not ready, then kicks off `initAnalytics()`; once the SDK
 * lands, the queue is flushed exactly once. Without this, events fired during
 * the lazy-load window (e.g. `register_view` on a direct visit to
 * `/auth/register?promo=TRYPRO`) were dropped permanently.
 */
const eventQueue: Array<{ event: string; properties?: Props }> = []
let queueFlushed = false

const apiKey = import.meta.env.VITE_PUBLIC_POSTHOG_KEY as string | undefined
const apiHost = import.meta.env.VITE_PUBLIC_POSTHOG_HOST as string | undefined

/**
 * Import and initialize PostHog. Resolves to null when the import fails —
 * analytics must never break product flows. Not memoized and not exported: the
 * single call site below is already inside the memoized `readyPromise`, so this
 * runs exactly once.
 */
function initClient(key: string): Promise<PostHog | null> {
  return import('posthog-js')
      .then(({ default: client }) => {
        client.init(key, {
          api_host: apiHost,
          person_profiles: 'always',
          capture_pageview: true,
          capture_pageleave: true,
          autocapture: true,
          // Persist identity + session across reloads so product sessions stay
          // linked.
          persistence: 'localStorage+cookie',
          session_recording: {
            maskAllInputs: false,
            maskInputFn: (text: string, element?: HTMLElement) => {
              // Mask password and sensitive fields
              if (element?.getAttribute('type') === 'password') {
                return '*'.repeat(text.length)
              }
              return text
            },
          },
          disable_session_recording: false,
        })
        posthog = client
        flushEventQueue()
        return client
      })
      .catch(() => null)
}

/**
 * Schedule the load for the first idle moment, so it never competes with first
 * paint, and resolve with the client once it lands (null when PostHog is not
 * configured). Idempotent: main.tsx calls it at startup and PostHogIdentify
 * awaits it, but the SDK is only ever fetched and init'd once.
 */
export function initAnalytics(): Promise<PostHog | null> {
  if (readyPromise) return readyPromise
  if (!apiKey) {
    readyPromise = Promise.resolve(null)
    return readyPromise
  }
  readyPromise = new Promise((resolve) => {
    onIdle(() => void initClient(apiKey).then(resolve), { timeout: 3000, fallbackDelay: 1500 })
  })
  return readyPromise
}

/** The live client, or null if it has not loaded yet. */
export function getPostHog(): PostHog | null {
  return posthog
}

function sanitize(props?: Props): Record<string, string | number | boolean> | undefined {
  if (!props) return undefined
  const out: Record<string, string | number | boolean> = {}
  for (const [key, value] of Object.entries(props)) {
    if (value === undefined || value === null) continue
    out[key] = value
  }
  return Object.keys(out).length ? out : undefined
}

/**
 * Fire a named product event. If PostHog is ready, it is captured directly.
 * Otherwise the event is buffered and `initAnalytics()` is (re)triggered so the
 * SDK starts loading; the buffered event is flushed once the SDK lands. Never
 * throws — analytics must never break product flows.
 */
export function trackEvent(event: string, properties?: Props): void {
  try {
    if (typeof posthog?.capture === 'function') {
      posthog.capture(event, sanitize(properties))
      return
    }
    eventQueue.push({ event, properties })
    void initAnalytics()
  } catch {
    // Analytics must never break product flows.
  }
}

/**
 * Replay buffered events into PostHog once it is ready. Guarded so a queued
 * event that arrives after the SDK has already loaded (and the direct-capture
 * path) can never double-flush.
 */
function flushEventQueue(): void {
  if (queueFlushed) return
  queueFlushed = true
  if (typeof posthog?.capture !== 'function') return
  while (eventQueue.length) {
    const entry = eventQueue.shift()
    if (!entry) continue
    try {
      posthog.capture(entry.event, sanitize(entry.properties))
    } catch {
      // A single bad event must not abort the rest of the queue.
    }
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
