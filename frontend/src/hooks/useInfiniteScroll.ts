/**
 * useInfiniteScroll — viewport-rooted preloading for "Load more" lists.
 *
 * Why this exists: the Closet/Outfits/Blog lists live in normal document flow
 * (the window scrolls, not a nested container — see MasterDetailLayout), so the
 * sentinel is observed against the VIEWPORT (`root: null`).
 *
 * `rootMargin: 400px` starts the next fetch before the sentinel is actually
 * visible, so a slow page never shows a blank strip at the bottom. The store
 * action passed in already no-ops while a fetch is in flight, so an extra
 * intersect during the request is harmless.
 */
import { useCallback, useEffect, useRef } from 'react'

export interface UseInfiniteScrollOptions {
  /** Append the next page. Called when the sentinel enters the preload zone. */
  onLoadMore: () => void
  /** False once the server reports no more pages. Disconnects the observer. */
  hasMore: boolean
  /** True while a page is loading. Suppresses duplicate fires. */
  isLoading: boolean
  /**
   * Extra gate (e.g. an empty list that should not auto-paginate into nothing).
   * Default `false` keeps the hook active.
   */
  disabled?: boolean
  /** Preload distance in px. Defaults to 400. */
  rootMargin?: number
}

export function useInfiniteScroll({
  onLoadMore,
  hasMore,
  isLoading,
  disabled = false,
  rootMargin = 400,
}: UseInfiniteScrollOptions): (node: Element | null) => void {
  // Latest props live in refs so the IntersectionObserver callback never goes
  // stale and the observer is not re-created on every render.
  const onLoadMoreRef = useRef(onLoadMore)
  const hasMoreRef = useRef(hasMore)
  const isLoadingRef = useRef(isLoading)
  const disabledRef = useRef(disabled)
  const firedForThisIntersectRef = useRef(false)

  useEffect(() => {
    onLoadMoreRef.current = onLoadMore
    hasMoreRef.current = hasMore
    isLoadingRef.current = isLoading
    disabledRef.current = disabled
  })

  const observerRef = useRef<IntersectionObserver | null>(null)
  const nodeRef = useRef<Element | null>(null)

  const fire = useCallback(() => {
    if (hasMoreRef.current && !isLoadingRef.current && !disabledRef.current) {
      firedForThisIntersectRef.current = true
      onLoadMoreRef.current()
    }
  }, [])

  // (Re)create the observer whenever the preload distance changes.
  useEffect(() => {
    if (typeof IntersectionObserver === 'undefined') return
    const observer = new IntersectionObserver(
      (entries) => {
        const entry = entries[0]
        if (!entry || !entry.isIntersecting) {
          // Reset the one-shot latch when the sentinel leaves the zone, so the
          // next entry can fire again (scroll down → load → scroll up → down).
          firedForThisIntersectRef.current = false
          return
        }
        // If a fetch landed since the last intersect, isLoading just flipped to
        // false and the latch is still set — wait for a fresh intersect.
        if (firedForThisIntersectRef.current) return
        fire()
      },
      { root: null, rootMargin: `${rootMargin}px`, threshold: 0 }
    )
    observerRef.current = observer
    // Re-observe the current node after a config change.
    if (nodeRef.current) observer.observe(nodeRef.current)
    return () => {
      observer.disconnect()
      observerRef.current = null
    }
  }, [rootMargin, fire])

  // Attach callback ref.
  const setNode = useCallback(
    (node: Element | null) => {
      nodeRef.current = node
      const observer = observerRef.current
      if (!observer) return
      if (node) observer.observe(node)
    },
    []
  )

  // Disconnect cleanly once the list is exhausted — keeps the observer from
  // firing `onLoadMore` (a no-op fetch) forever against a stale sentinel.
  useEffect(() => {
    const observer = observerRef.current
    const node = nodeRef.current
    if (!observer) return
    if (!hasMore && node) observer.unobserve(node)
  }, [hasMore])

  return setNode
}
