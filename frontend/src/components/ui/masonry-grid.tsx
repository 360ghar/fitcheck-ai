import * as React from 'react'
import { cn } from '@/lib/utils'

export interface MasonryGridProps {
  /** Number of masonry columns. Drives how many vertical tracks are rendered. */
  columnCount: number
  /**
   * Change this to FORCE a full relayout (every card re-binned). Use the
   * signature of whatever reorders the result set — filters / sort / search —
   * so a filter change re-spreads from scratch, while a pure append (load-more)
   * keeps `resetKey` stable and leaves every existing card in place.
   */
  resetKey: string | number
  /** Tailwind gap utility applied to BOTH the inter-column and intra-column gaps. */
  gapClassName?: string
  className?: string
  children: React.ReactNode
}

/**
 * MasonryGrid — JS masonry where appended cards land at the bottom and EXISTING
 * cards never move.
 *
 * The old `PinGrid` used CSS multi-column layout with the default
 * `column-fill: balance`, so every append rebalanced the whole grid: existing
 * cards jumped columns and new cards filled the right-hand side. This component
 * bins each child into a fixed column (a flex column) and never repositions a
 * card once it is placed — only newly-arrived keys are assigned, to the
 * currently-shortest column.
 *
 * Placement rules:
 *   - Cold start (no heights measured yet): round-robin so page 1 spreads evenly.
 *   - Append (heights known): each new key → shortest column; a per-card height
 *     estimate is added to the working heights so a whole new page spreads
 *     across columns instead of piling on one. The ResizeObserver replaces the
 *     estimate with real heights before the next page lands.
 *   - `resetKey` change or `columnCount` change: the binning is invalidated, so
 *     every key is re-placed (round-robin). This is the only time existing cards
 *     move, and both causes are legitimate (a filter/sort change or a resize).
 *
 * The list scrolls in the document (the window), so this grid owns its natural
 * height — no inner scroll container.
 */
export function MasonryGrid({
  columnCount,
  resetKey,
  gapClassName = 'gap-xs',
  className,
  children,
}: MasonryGridProps) {
  // `React.Children.toArray` rekeys and flattens fragments; each returned node
  // carries a stable key. We pair each node with its key up front so the rest of
  // the component can read keys without casting the ReactNode union.
  const resolved = React.useMemo<{ key: string; node: React.ReactNode }[]>(() => {
    return React.Children.toArray(children).map((node, i) => ({
      key: String((node as React.ReactElement).key ?? `__idx_${i}`),
      node,
    }))
  }, [children])

  // key → column index. Preserved across appends; only `resetKey`/`columnCount`
  // changes or a key's disappearance mutate it.
  const [placements, setPlacements] = React.useState<Record<string, number>>({})
  const columnHeightsRef = React.useRef<number[]>([])
  const columnRefs = React.useRef<Array<HTMLDivElement | null>>([])

  const lastResetKeyRef = React.useRef<string | number>(resetKey)
  const lastColumnCountRef = React.useRef<number>(columnCount)

  // Signature of the current child set, so the placement effect runs exactly
  // when keys are added or removed (not on every parent re-render).
  const signature = React.useMemo(() => resolved.map((c) => c.key).join('\u0000'), [resolved])

  // Bin children. Runs on mount, on append/remove, on resetKey, on columnCount.
  React.useEffect(() => {
    const keys = resolved.map((c) => c.key)
    const keySet = new Set(keys)
    const reset =
      resetKey !== lastResetKeyRef.current || columnCount !== lastColumnCountRef.current
    lastResetKeyRef.current = resetKey
    lastColumnCountRef.current = columnCount

    setPlacements((prev) => {
      let next = prev
      let changed = reset
      if (reset) next = {}

      // Drop keys that are no longer present (e.g. an item was deleted).
      for (const k of Object.keys(next)) {
        if (!keySet.has(k)) {
          if (next === prev) next = { ...prev }
          delete next[k]
          changed = true
        }
      }

      // Working heights: real measurements where we have them, zeros elsewhere.
      const measured = columnHeightsRef.current
      const working: number[] = []
      for (let c = 0; c < columnCount; c++) working.push(measured[c] ?? 0)

      const nonzero = working.filter((h) => h > 0)
      const estimate = nonzero.length
        ? nonzero.reduce((a, b) => a + b, 0) / nonzero.length
        : 280
      const allZero = nonzero.length === 0

      // Round-robin counter continues from however many are already placed, so
      // a cold-start batch spreads evenly across all columns.
      let coldCounter = Object.keys(next).length

      for (const k of keys) {
        if (next[k] !== undefined) continue
        if (next === prev) next = { ...prev }
        let col: number
        if (allZero) {
          col = coldCounter % columnCount
          coldCounter += 1
        } else {
          // Shortest column; ties resolve to the lowest index (deterministic).
          let min = Infinity
          col = 0
          for (let c = 0; c < columnCount; c++) {
            if (working[c] < min) {
              min = working[c]
              col = c
            }
          }
          // Bump so the rest of this batch doesn't pile onto the same column.
          working[col] += estimate
        }
        next[k] = col
        changed = true
      }

      return changed ? next : prev
    })
  }, [signature, columnCount, resetKey, resolved])

  // Measure column heights so the NEXT batch can bin by shortest column.
  // Columns are stable DOM nodes (keyed by index), so re-subscribing only when
  // the column count changes is enough; their size changes fire the observer.
  React.useEffect(() => {
    if (typeof ResizeObserver === 'undefined') return
    const measure = () => {
      columnHeightsRef.current = columnRefs.current.map(
        (el) => el?.getBoundingClientRect().height ?? 0
      )
    }
    measure()
    const ro = new ResizeObserver(measure)
    for (const el of columnRefs.current) if (el) ro.observe(el)
    return () => ro.disconnect()
  }, [columnCount, signature])

  // Group resolved children into their columns, preserving source order within
  // each column.
  const columns = React.useMemo(() => {
    const cols: React.ReactNode[][] = Array.from({ length: columnCount }, () => [])
    for (const { key, node } of resolved) {
      const col = placements[key] ?? 0
      // Guard against a stale placement pointing past the current column count
      // (e.g. right after a resize to fewer columns, before re-binning lands).
      cols[col >= columnCount ? 0 : col].push(node)
    }
    return cols
  }, [resolved, placements, columnCount])

  return (
    <div className={cn('flex', gapClassName, className)}>
      {columns.map((col, c) => (
        <div
          key={c}
          ref={(el) => {
            columnRefs.current[c] = el
          }}
          className={cn('flex min-w-0 flex-1 flex-col', gapClassName)}
        >
          {col}
        </div>
      ))}
    </div>
  )
}
