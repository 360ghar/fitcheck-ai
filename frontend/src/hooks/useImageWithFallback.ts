/**
 * Serve a thumbnail but survive it not existing.
 *
 * Read paths derive `thumbnail_url` from the parent key with NO existence check
 * (`materialize_image_urls` in backend/app/api/v1/images.py): when
 * `THUMBNAIL_SERVING` is on, every canonical key gets a `{key}_thumb.webp` URL
 * whether or not that object was ever written. It legitimately may not have
 * been —
 *
 *   - `StorageService._upload_thumbnail` is best-effort by contract and returns
 *     False without writing anything when the bytes cannot be decoded or the
 *     encode/PUT fails;
 *   - the entire pre-feature corpus has no thumb until the backfill script has
 *     run, and mid-rollout there is a window where some do and some do not.
 *
 * Clients prefer `thumbnail_url || image_url`, which only falls back on an EMPTY
 * field — never on a 404 — so a missing thumb rendered a permanently broken tile
 * even though the full-size image was present and healthy.
 *
 * This hook makes the 404 recoverable: hand it the preferred source and the
 * full-size fallback, and the first failure silently swaps to the fallback.
 * Only if THAT fails is the image genuinely broken.
 */

import { useCallback, useEffect, useRef, useState } from 'react'
import type { SyntheticEvent } from 'react'

/**
 * The same fallback for images rendered inside a `.map()`, where a hook per item
 * is not possible. Swaps the element's `src` once, on the DOM node.
 *
 * The `data-fallback-for` marker is what stops a loop: without it a fallback
 * that also 404s would re-enter this handler and re-assign the same src forever.
 * The marker is keyed by the fallback URL, not a boolean: after a re-minted
 * (still missing) thumb URL lands on the same DOM node with a NEW fallback URL,
 * the swap must re-arm — a boolean would skip it and leave the tile permanently
 * broken. The loop guard (`el.src === fallbackUrl`) still prevents re-assigning
 * the same fallback.
 */
export function thumbnailErrorFallback(fallbackUrl?: string | null) {
  return (event: SyntheticEvent<HTMLImageElement>) => {
    const el = event.currentTarget
    if (!fallbackUrl || el.dataset.fallbackFor === fallbackUrl) return
    if (el.src === fallbackUrl || el.currentSrc === fallbackUrl) return
    el.dataset.fallbackFor = fallbackUrl
    el.src = fallbackUrl
  }
}

export interface ImageWithFallback {
  /** The URL to render right now. `null` when there is nothing to show. */
  src: string | null
  /** True once both the preferred source and the fallback have failed. */
  hasError: boolean
  /**
   * Pass to the element's `onError` (or call from a polling effect). Accepts
   * the URL that failed — the element's `currentSrc || src` at signal time —
   * so duplicate failure signals for the same URL can be deduped.
   */
  onError: (failedUrl?: string | null) => void
  /** True while the fallback is being displayed (the thumb was missing). */
  usingFallback: boolean
}

export interface UseImageWithFallbackOptions {
  /**
   * Called at most once per source pair, when an error arrives and BOTH sources
   * are already spent — the signal that the presigned URLs expired rather than
   * that a thumb is merely missing. A missing thumb is fixed by the fallback, so
   * re-minting on that would be wasted work.
   *
   * Lives here rather than in each card because the composition is subtle: the
   * "already failing" state must be read BEFORE the swap is applied, and the
   * once-only latch has to re-arm when the URLs change. Both card call sites had
   * hand-rolled the same 18 lines around this hook, deps list included.
   */
  onExhausted?: () => void
  /**
   * Extra value that, when it changes, re-arms `onExhausted`. Pass the entity id
   * so a recycled card row is allowed to report again.
   */
  resetKey?: unknown
}

/**
 * @param preferred  Thumbnail URL (or whatever should be tried first).
 * @param fallback   Full-size URL, tried once if `preferred` fails.
 * @param options    See `UseImageWithFallbackOptions`.
 */
export function useImageWithFallback(
  preferred?: string | null,
  fallback?: string | null,
  options: UseImageWithFallbackOptions = {},
): ImageWithFallback {
  const { onExhausted, resetKey } = options
  const [usingFallback, setUsingFallback] = useState(false)
  const [hasError, setHasError] = useState(false)

  // A distinct fallback only. When the backend mirrors thumbnail_url onto
  // image_url (thumbnail serving off, or no thumb key), retrying the identical
  // URL would just fail again and burn a request.
  const distinctFallback = fallback && fallback !== preferred ? fallback : null

  // Reset when either source changes so a stale failure never suppresses a
  // freshly-minted URL.
  useEffect(() => {
    setUsingFallback(false)
    setHasError(false)
  }, [preferred, distinctFallback])

  // Once-only latch for onExhausted, re-armed on new URLs (or a new entity).
  const reportedRef = useRef(false)
  useEffect(() => {
    reportedRef.current = false
  }, [preferred, distinctFallback, resetKey])

  // Dedupe key for failure signals. The element can report ONE failure twice:
  // the <img> `onError` AND a polling effect (ItemImage's
  // `complete && naturalWidth === 0` check, which exists to catch failures
  // whose load/error events were missed). Both signals for the same URL must
  // count as one failure — otherwise the second signal can land after the
  // first one swapped in the healthy fallback and mark the tile broken. Reset
  // alongside the state resets so a stale key never suppresses a freshly
  // minted URL.
  const lastFailedRef = useRef<string | null>(null)
  useEffect(() => {
    lastFailedRef.current = null
  }, [preferred, distinctFallback])

  // Hold the callback in a ref so an inline `onExhausted` arrow in the parent
  // does not rebuild `onError` on every render and defeat memoized children.
  const onExhaustedRef = useRef(onExhausted)
  useEffect(() => {
    onExhaustedRef.current = onExhausted
  }, [onExhausted])

  const onError = useCallback((failedUrl?: string | null) => {
    // Defensive: a SyntheticEvent (or anything non-string) passed by mistake
    // carries no URL — skip dedupe rather than crash.
    const url = typeof failedUrl === 'string' && failedUrl ? failedUrl : null
    // A second failure signal for the same URL is a duplicate report of one
    // failure (see lastFailedRef above). Ignore it before any state is read:
    // the swap triggered by the first signal must not be discarded.
    if (url && url === lastFailedRef.current) return
    if (url) lastFailedRef.current = url
    // Read the already-failing state BEFORE mutating it: the parent is told only
    // once both sources are spent.
    if (hasError && !reportedRef.current) {
      reportedRef.current = true
      onExhaustedRef.current?.()
    }
    // Guard the swap on `usingFallback` state, not on a ref. Two onError events
    // in the same tick both observe the pre-render value and both swap (setState
    // is idempotent), whereas a ref latch made the SECOND one skip straight to
    // `hasError` — marking the tile broken without the fallback ever being tried,
    // which is the exact storm the guard was meant to prevent.
    if (distinctFallback && !usingFallback) {
      setUsingFallback(true)
      return
    }
    setHasError(true)
  }, [distinctFallback, usingFallback, hasError])

  const active = usingFallback ? distinctFallback : preferred || distinctFallback

  return {
    src: hasError ? null : active || null,
    hasError,
    onError,
    usingFallback,
  }
}
