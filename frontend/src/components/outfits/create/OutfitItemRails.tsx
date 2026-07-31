/**
 * OutfitItemRails — the closet, as horizontal rails grouped by category.
 *
 * Lifted from the deleted dialog and fixed on four counts:
 *
 * 1. Selected state was `border-indigo-500 ring-2 ring-indigo-200` — legacy
 *    indigo (DESIGN.md 01 replaced it with brand red and one accent), a ring,
 *    and a shadow that DESIGN.md 07 does not grant to a tile. It is now
 *    `border-ink` plus an ink check disc. The border is `border-2` in BOTH
 *    states (transparent when unselected), so selecting a tile changes its
 *    colour and nothing else — no 2px reflow, no jitter down the rail.
 * 2. Every tile is `w-28` with a FIXED `h-28` image box and a single-line
 *    truncated name, so the tiles are identical in height and every rail's
 *    bottom edge lands on the same line. Ragged parallel rows are a tell.
 * 3. Each scroller gets `-mx-4 px-4 pr-8`, so the last tile is never shaved by
 *    the container edge — clear the cut.
 * 4. Images are `object-contain`, not `object-cover`. These are matted cutouts
 *    now; `cover` centre-cropped the silhouette of every portrait garment.
 *
 * Rails are ordered by how you wear the clothes, not by `localeCompare`.
 */

import * as React from 'react'
import { Check, Search } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'
import { compareCategories, type AvailableItem } from './constants'

export interface OutfitItemRailsProps {
  items: AvailableItem[]
  selectedIds: Set<string>
  onToggle: (itemId: string) => void
  isLoading: boolean
  error: string | null
  onRetry: () => void
  disabled?: boolean
}

export function OutfitItemRails({
  items,
  selectedIds,
  onToggle,
  isLoading,
  error,
  onRetry,
  disabled,
}: OutfitItemRailsProps) {
  const [search, setSearch] = React.useState('')
  const [category, setCategory] = React.useState('all')

  const categories = React.useMemo(
    () =>
      Array.from(
        new Set(items.map((item) => item.category).filter(Boolean)),
      ).sort(compareCategories),
    [items],
  )

  const grouped = React.useMemo(() => {
    const query = search.trim().toLowerCase()
    const groups = new Map<string, AvailableItem[]>()
    for (const item of items) {
      if (category !== 'all' && item.category !== category) continue
      if (query && !item.name.toLowerCase().includes(query)) continue
      const key = item.category || 'other'

      const bucket = groups.get(key)
      if (bucket) bucket.push(item)
      else groups.set(key, [item])
    }
    return Array.from(groups.entries()).sort((a, b) =>
      compareCategories(a[0], b[0]),
    )
  }, [items, category, search])

  return (
    <div>
      <div className="mt-lg flex flex-col gap-sm sm:flex-row">
        <div className="relative flex-1">
          <Label htmlFor="outfit-item-search" className="sr-only">
            Search your closet
          </Label>
          <Search
            className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-ash"
            aria-hidden="true"
          />
          <Input
            id="outfit-item-search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search your closet"
            className="pl-11"
            autoComplete="off"
          />
        </div>
        <div className="sm:w-48">
          <Label htmlFor="outfit-item-category" className="sr-only">
            Filter by category
          </Label>
          <Select value={category} onValueChange={setCategory}>
            <SelectTrigger id="outfit-item-category" className="capitalize">
              <SelectValue placeholder="All categories" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All categories</SelectItem>
              {categories.map((option) => (
                <SelectItem key={option} value={option} className="capitalize">
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {isLoading ? (
        // A skeleton shaped like the rail it replaces, so nothing jumps when the
        // real tiles arrive.
        <div className="mt-lg space-y-lg" aria-busy="true">
          {[0, 1].map((rail) => (
            <div key={rail}>
              <Skeleton className="h-3 w-24" />
              <div className="mt-sm flex gap-sm overflow-hidden">
                {[0, 1, 2, 3, 4].map((tile) => (
                  <div key={tile} className="w-28 shrink-0">
                    <Skeleton className="h-28 w-28 rounded-md" />
                    <Skeleton className="mt-xxs h-3 w-20" />
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      ) : error ? (
        <div className="mt-xl">
          <p className="text-sm text-destructive">{error}</p>
          <Button variant="tertiary" onClick={onRetry} className="mt-sm px-0">
            Try again
          </Button>
        </div>
      ) : grouped.length === 0 ? (
        <p className="mt-xl text-sm text-muted-foreground">
          {items.length === 0
            ? 'Your closet is empty. Add clothes first and they will show up here.'
            : 'Nothing matches that search.'}
        </p>
      ) : (
        <div className="mt-lg space-y-lg">
          {grouped.map(([categoryName, categoryItems]) => (
            <div key={categoryName}>
              <p className="text-xs capitalize text-muted-foreground">
                {categoryName}{' '}
                <span className="tabular-nums text-ash">
                  {categoryItems.length}
                </span>
              </p>

              {/* pr-8 is the "clear the cut" allowance: the last tile scrolls
                  fully clear of the container's right edge instead of being
                  shaved by it. */}
              <div className="-mx-4 mt-sm flex snap-x gap-sm overflow-x-auto px-4 pb-xxs pr-8">
                {categoryItems.map((item) => {
                  const isSelected = selectedIds.has(item.id)
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => onToggle(item.id)}
                      disabled={disabled}
                      aria-pressed={isSelected}
                      className={cn(
                        'relative w-28 shrink-0 snap-start overflow-hidden rounded-md text-left',
                        // border-2 in both states: the box never changes size,
                        // only its colour, so a rail cannot twitch on select.
                        'border-2 transition-colors',
                        isSelected
                          ? 'border-ink'
                          : 'border-transparent hover:border-border',
                        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                        'disabled:opacity-60',
                      )}
                    >
                      {/* Fixed height: this is what aligns every rail. */}
                      <div className="h-28 w-full overflow-hidden rounded-sm bg-card">
                        {item.image_url ? (
                          <img
                            src={item.image_url}
                            alt=""
                            className="h-full w-full object-contain"
                            loading="lazy"
                            decoding="async"
                          />
                        ) : (
                          <div className="flex h-full w-full items-center justify-center px-xs text-center">
                            <span className="text-[10px] leading-tight text-muted-foreground">
                              No photo
                            </span>
                          </div>
                        )}
                      </div>

                      <div className="px-xxs py-xxs">
                        <span className="block truncate text-xs text-foreground">
                          {item.name}
                        </span>
                      </div>

                      {isSelected && (
                        // Same disc as the tray's remove control, opposite verb.
                        // flex centring on a square puts the check dead-centre.
                        <span
                          className="absolute right-1.5 top-1.5 flex h-5 w-5 items-center justify-center rounded-full bg-ink text-on-dark"
                          aria-hidden="true"
                        >
                          <Check className="h-3 w-3" strokeWidth={3} />
                        </span>
                      )}
                    </button>
                  )
                })}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default OutfitItemRails
