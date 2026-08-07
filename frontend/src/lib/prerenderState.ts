/**
 * Hydrate the query state the /blog prerender baked into the HTML.
 *
 * entry-prerender.tsx serializes the blog query cache into a
 * `<script id="__FITCHECK_QUERY_STATE__" type="application/json">` tag so the
 * first client render can show the baked grid instead of a loading skeleton.
 * The baked queries are stamped stale (dataUpdatedAt = 0) by the prerender, so
 * they refetch in the background right after mount — baked content is a paint
 * shortcut, not a freshness ceiling.
 *
 * Returns false and never throws for absent or corrupt state (every route
 * other than /blog), so callers can keep the "never block mount on bad state"
 * guarantee without a try/catch of their own.
 */

import { QueryClient, hydrate } from '@tanstack/react-query'

export function hydratePrerenderedState(
  queryClient: QueryClient,
  rawJson: string | null | undefined
): boolean {
  if (!rawJson) return false
  try {
    hydrate(queryClient, JSON.parse(rawJson))
    return true
  } catch {
    // Never block mount on bad state.
    return false
  }
}
