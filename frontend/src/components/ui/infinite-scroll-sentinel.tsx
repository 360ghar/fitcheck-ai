/**
 * InfiniteScrollSentinel — the invisible trip-wire that drives auto-paging.
 *
 * Replaces the manual "Load more" button. It is a zero-height element pinned to
 * the bottom of the list; when it scrolls within the preload margin the bound
 * `useInfiniteScroll` observer fires `onLoadMore`. When `isLoading` it shows a
 * slim centered spinner so the user can see the next page is on its way, and it
 * renders nothing once `hasMore` is false.
 */
import { Loader2 } from 'lucide-react'
import { useInfiniteScroll } from '@/hooks/useInfiniteScroll'
import { cn } from '@/lib/utils'

export interface InfiniteScrollSentinelProps {
  onLoadMore: () => void
  hasMore: boolean
  isLoading: boolean
  /** Skip auto-paging (e.g. an empty first page). Defaults to false. */
  disabled?: boolean
  className?: string
}

export function InfiniteScrollSentinel({
  onLoadMore,
  hasMore,
  isLoading,
  disabled = false,
  className,
}: InfiniteScrollSentinelProps) {
  const setNode = useInfiniteScroll({ onLoadMore, hasMore, isLoading, disabled })

  if (!hasMore) return null

  return (
    <div
      ref={setNode}
      className={cn('mt-lg flex items-center justify-center py-md', className)}
      // aria-live announces "loading more" to screen readers without trapping
      // focus the way a modal would.
      aria-live="polite"
      aria-busy={isLoading || undefined}
      role="status"
    >
      {isLoading && <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />}
    </div>
  )
}
