import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterAll, afterEach, beforeAll, expect, vi } from 'vitest'
import * as axeMatchers from 'vitest-axe/matchers'

import '@/shared/i18n'
import { clearTokens } from '@/shared/api/tokens'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { server } from '@/test/msw/server'
import { sharedTestQueryClient } from '@/test/utils'

/**
 * Vitest setup (jsdom): deterministic timezone, browser-API polyfills,
 * MSW lifecycle, per-test state isolation, and the vitest-axe matcher
 * (`expect(container).toHaveNoViolations()` — WCAG 2.1 AA, spec §10).
 */

// axe-core checks require CSS cascade info; jsdom supports getComputedStyle.
expect.extend(axeMatchers)

// Deterministic date formatters: run tests in UTC.
process.env.TZ = 'UTC'

// matchMedia — used by next-themes and sonner. Stubbed via stubGlobal so
// `restoreMocks: true` (which resets vi.fn implementations before each test)
// cannot detach it.
vi.stubGlobal(
  'matchMedia',
  (query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }),
)

// ResizeObserver — used by recharts' ResponsiveContainer (MetricCard sparkline).
class ResizeObserverMock {
  observe(): void {}
  unobserve(): void {}
  disconnect(): void {}
}
vi.stubGlobal('ResizeObserver', ResizeObserverMock)

// jsdom does not implement pointer capture / scrollIntoView; Radix UI
// (Select, DropdownMenu, Command) calls these in its pointer and open
// handlers, which crashes those interactions (and their tests) without
// shims.
if (typeof Element !== 'undefined') {
  if (!Element.prototype.hasPointerCapture) {
    Element.prototype.hasPointerCapture = () => false
  }
  if (!Element.prototype.releasePointerCapture) {
    Element.prototype.releasePointerCapture = () => undefined
  }
  if (!Element.prototype.setPointerCapture) {
    Element.prototype.setPointerCapture = () => undefined
  }
  if (!Element.prototype.scrollIntoView) {
    Element.prototype.scrollIntoView = () => undefined
  }
}

beforeAll(() => {
  server.listen({ onUnhandledRequest: 'error' })
})

afterEach(() => {
  cleanup()
  server.resetHandlers()
  sharedTestQueryClient.clear()
  localStorage.clear()
  clearTokens()
  useSessionStore.setState({
    status: 'loading',
    user: null,
    role: null,
    permissions: [],
    permissionDenied: false,
    error: null,
    idleSince: Date.now(),
    lastLogoutReason: null,
  })
})

afterAll(() => {
  server.close()
  vi.unstubAllGlobals()
})
