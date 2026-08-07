/**
 * Run work at the first idle moment so it never competes with first paint.
 *
 * Both lazy SDK loaders (analytics, error reporting) need exactly this and had
 * each written their own copy of the `requestIdleCallback`-with-`setTimeout`-
 * fallback dance. `requestIdleCallback` is still unimplemented in Safari, so the
 * fallback is not optional — and a second copy is a second chance to forget it.
 */

export interface OnIdleOptions {
  /** Deadline handed to `requestIdleCallback`; it fires by then regardless. */
  timeout?: number
  /** Delay used when `requestIdleCallback` is unavailable (Safari). */
  fallbackDelay?: number
}

export function onIdle(fn: () => void, options: OnIdleOptions = {}): void {
  const { timeout = 5000, fallbackDelay = 2000 } = options
  if (typeof requestIdleCallback === 'function') {
    requestIdleCallback(fn, { timeout })
  } else {
    setTimeout(fn, fallbackDelay)
  }
}
