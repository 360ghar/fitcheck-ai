/**
 * ItemDetailBody — the scrolling content of the closet detail surface.
 *
 * Replaces the three-tab `max-w-3xl` dialog. The tabs did not survive the move
 * into a 270–440px pane for three reasons: a three-up tab list at that width is
 * three ragged sub-44px targets, the dialog's two-column image/form split
 * collapses anyway, and — the real problem — tabs HID the garment when showing
 * the garment is the entire job of this surface.
 *
 * So: one scrolling column. Hero, then identity, then a ruled spec sheet, then
 * extra photos only if there are any, then the wear ledger. No horizontal
 * padding (the layout supplies it) and no entrance animation.
 */

import * as React from 'react'
import { Plus, Shirt, X } from 'lucide-react'
import { ZoomableImage } from '@/components/ui/zoomable-image'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { FilterChip } from '@/components/ui/filter-chip'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  DEFAULT_USE_CASES,
  formatUseCaseLabel,
  normalizeUseCase,
  normalizeUseCases,
} from '@/lib/use-cases'
import type { Category, Condition, Item } from '@/types'
import type { ItemEditor } from './useItemEditor'

const CATEGORIES: { value: Category; label: string }[] = [
  { value: 'tops', label: 'Tops' },
  { value: 'bottoms', label: 'Bottoms' },
  { value: 'shoes', label: 'Shoes' },
  { value: 'accessories', label: 'Accessories' },
  { value: 'outerwear', label: 'Outerwear' },
  { value: 'swimwear', label: 'Swimwear' },
  { value: 'activewear', label: 'Activewear' },
  { value: 'other', label: 'Other' },
]

const CONDITIONS: { value: Condition; label: string }[] = [
  { value: 'clean', label: 'Clean' },
  { value: 'dirty', label: 'Dirty' },
  { value: 'laundry', label: 'In laundry' },
  { value: 'repair', label: 'Needs repair' },
  { value: 'donate', label: 'To donate' },
]

// Garment colour data, not a theme surface: these hexes describe the physical
// item and must read the same in light and dark, exactly like the photograph
// above them. Unknown colour names render as text with no dot rather than as an
// invented swatch.
// theme-static: physical garment colours, identical in both themes by definition
const COLOR_SWATCHES: Record<string, string> = {
  black: '#111111',
  white: '#ffffff',
  'off-white': '#f2efe6',
  ivory: '#fffff0',
  cream: '#f5efdc',
  beige: '#e8dcc4',
  tan: '#d2b48c',
  camel: '#c19a6b',
  khaki: '#b3a06a',
  brown: '#6f4e37',
  chocolate: '#4a2c20',
  grey: '#8b8b86',
  gray: '#8b8b86',
  charcoal: '#3a3a3a',
  silver: '#c0c0c0',
  navy: '#1f2a44',
  blue: '#2f5fbf',
  'light blue': '#a7c7e7',
  denim: '#3b5a80',
  indigo: '#33436b',
  teal: '#1f6f6b',
  turquoise: '#40c8c0',
  green: '#2e7d4f',
  olive: '#6b7a3a',
  mint: '#a8e6cf',
  yellow: '#e8c341',
  mustard: '#c9a227',
  gold: '#b8912b',
  orange: '#e2761b',
  rust: '#a24b2a',
  peach: '#f4c2a1',
  coral: '#ec7263',
  red: '#c02026',
  maroon: '#5e1b1b',
  burgundy: '#6d1a2c',
  pink: '#e8a0b8',
  blush: '#efc3c9',
  magenta: '#b6317f',
  purple: '#6b2d7a',
  lavender: '#c3b0dd',
}

function swatchFor(color: string): string | null {
  return COLOR_SWATCHES[color.trim().toLowerCase()] ?? null
}

function formatMoney(value: number): string {
  const rounded = Math.round(value * 100) / 100
  const decimals = Number.isInteger(rounded) ? 0 : 2
  return `$${rounded.toLocaleString(undefined, {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  })}`
}

function formatDay(value?: string | null): string | null {
  if (!value) return null
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return null
  return date.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' })
}

/**
 * The closet pane's authored moment: the arithmetic, shown.
 *
 * Four icon-in-a-tile stat cards are replaced by one figure that argues for
 * itself and tells you which number to move. Every branch is a real, finite
 * statement — there is no path to NaN, Infinity or "$NaN".
 */
function resolveLedger(item: Item): { figure: string; label: string; note: string } {
  const rawPrice = item.price ?? item.purchase_price
  const price = typeof rawPrice === 'number' && Number.isFinite(rawPrice) && rawPrice > 0
    ? rawPrice
    : null
  const wears = Number.isFinite(item.usage_times_worn) ? Math.max(0, item.usage_times_worn) : 0

  if (price !== null && wears > 0) {
    return {
      figure: formatMoney(price / wears),
      label: 'cost per wear',
      note: `${formatMoney(price)} ÷ ${wears} ${wears === 1 ? 'wear' : 'wears'}`,
    }
  }
  if (price !== null) {
    return { figure: formatMoney(price), label: 'paid', note: 'Not worn yet' }
  }
  return {
    figure: String(wears),
    label: wears === 1 ? 'time worn' : 'times worn',
    note: 'Add a price to see cost per wear',
  }
}

function SpecRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-lg border-b border-border py-md">
      <dt className="shrink-0 text-xs text-muted-foreground">{label}</dt>
      <dd className="min-w-0 text-right text-sm text-foreground">{children}</dd>
    </div>
  )
}

export interface ItemDetailBodyProps {
  item: Item
  editor: ItemEditor
  /** One quiet line of context, e.g. when the selection is filtered out of the list. */
  notice?: string | null
}

export function ItemDetailBody({ item, editor, notice }: ItemDetailBodyProps) {
  const { isEditing, form, setField, customUseCase, setCustomUseCase } = editor

  const heroImage = item.images?.find((img) => img.is_primary) || item.images?.[0]
  const heroSrc = heroImage?.image_url || heroImage?.thumbnail_url || null
  const extraImages = (item.images || []).filter((img) => img.id !== heroImage?.id)

  const activeOccasionTags = (form.occasion_tags || item.occasion_tags || []) as string[]

  const toggleOccasionTag = (value: string) => {
    const normalized = normalizeUseCase(value)
    if (!normalized) return
    const next = activeOccasionTags.includes(normalized)
      ? activeOccasionTags.filter((tag) => tag !== normalized)
      : [...activeOccasionTags, normalized]
    setField('occasion_tags', normalizeUseCases(next))
  }

  const addCustomOccasionTag = () => {
    const normalized = normalizeUseCase(customUseCase)
    if (!normalized) return
    setField('occasion_tags', normalizeUseCases([...activeOccasionTags, normalized]))
    setCustomUseCase('')
  }

  const customOccasionTags = activeOccasionTags.filter(
    (tag) => !DEFAULT_USE_CASES.includes(tag as (typeof DEFAULT_USE_CASES)[number])
  )

  const conditionLabel = CONDITIONS.find((c) => c.value === item.condition)?.label
  const addedOn = formatDay(item.created_at)
  const lastWorn = formatDay(item.usage_last_worn)
  const ledger = resolveLedger(item)

  return (
    <div className="pb-lg">
      {notice && <p className="pb-md text-sm text-muted-foreground">{notice}</p>}

      {/* Hero. object-contain over a card surface so a cutout garment is shown
          whole — this surface exists to show the item, so it is never cropped. */}
      <div className="overflow-hidden rounded-md bg-card">
        {heroSrc ? (
          <ZoomableImage
            src={heroSrc}
            alt={item.name}
            className="mx-auto block max-h-[58svh] w-full object-contain"
          />
        ) : (
          <div className="flex aspect-square items-center justify-center">
            <Shirt className="h-10 w-10 text-ash" aria-hidden="true" />
          </div>
        )}
      </div>

      {isEditing ? (
        <div className="mt-lg space-y-lg">
          <div>
            <Label htmlFor="item-edit-name">Name</Label>
            <Input
              id="item-edit-name"
              value={form.name ?? ''}
              onChange={(e) => setField('name', e.target.value)}
            />
          </div>

          <div>
            <Label htmlFor="item-edit-category">Category</Label>
            <Select
              value={form.category}
              onValueChange={(value) => setField('category', value as Category)}
            >
              <SelectTrigger id="item-edit-category">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat.value} value={cat.value}>
                    {cat.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="item-edit-condition">Condition</Label>
            <Select
              value={form.condition}
              onValueChange={(value) => setField('condition', value as Condition)}
            >
              <SelectTrigger id="item-edit-condition">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CONDITIONS.map((cond) => (
                  <SelectItem key={cond.value} value={cond.value}>
                    {cond.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="item-edit-brand">Brand</Label>
            <Input
              id="item-edit-brand"
              value={form.brand || ''}
              placeholder="Optional"
              onChange={(e) => setField('brand', e.target.value)}
            />
          </div>

          <div>
            <Label htmlFor="item-edit-size">Size</Label>
            <Input
              id="item-edit-size"
              value={form.size || ''}
              placeholder="Optional"
              onChange={(e) => setField('size', e.target.value)}
            />
          </div>

          <div>
            <Label htmlFor="item-edit-notes">Notes</Label>
            <Textarea
              id="item-edit-notes"
              rows={3}
              value={form.notes || ''}
              onChange={(e) => setField('notes', e.target.value)}
            />
          </div>

          <div>
            <Label className="mb-sm block">Use cases</Label>
            <div className="flex flex-wrap gap-sm">
              {DEFAULT_USE_CASES.map((useCase) => (
                <FilterChip
                  key={useCase}
                  active={activeOccasionTags.includes(useCase)}
                  onClick={() => toggleOccasionTag(useCase)}
                >
                  {formatUseCaseLabel(useCase)}
                </FilterChip>
              ))}
            </div>
            <div className="mt-sm flex gap-sm">
              <Input
                value={customUseCase}
                placeholder="Add your own"
                onChange={(e) => setCustomUseCase(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault()
                    addCustomOccasionTag()
                  }
                }}
              />
              <Button
                type="button"
                variant="tertiary"
                size="icon"
                aria-label="Add use case"
                onClick={addCustomOccasionTag}
                className="shrink-0"
              >
                <Plus className="h-4 w-4" aria-hidden="true" />
              </Button>
            </div>
            {customOccasionTags.length > 0 && (
              <div className="mt-sm flex flex-wrap gap-sm">
                {customOccasionTags.map((tag) => (
                  <FilterChip
                    key={tag}
                    active
                    onClick={() => toggleOccasionTag(tag)}
                    aria-label={`Remove ${formatUseCaseLabel(tag)}`}
                    className="gap-xs"
                  >
                    {formatUseCaseLabel(tag)}
                    <X className="h-3 w-3" aria-hidden="true" />
                  </FilterChip>
                ))}
              </div>
            )}
          </div>
        </div>
      ) : (
        <>
          <div className="mt-lg">
            <p className="text-xs text-muted-foreground">
              {addedOn ? `Added ${addedOn}` : 'Added recently'}
            </p>
            {/* Condition only shows when it is not the default — one ink word and a
                dot, in place of five hardcoded coloured pills. */}
            {item.condition && item.condition !== 'clean' && conditionLabel && (
              <p className="mt-sm flex items-center gap-xs text-sm font-semibold text-foreground">
                <span className="h-1.5 w-1.5 rounded-full bg-foreground" aria-hidden="true" />
                {conditionLabel}
              </p>
            )}
          </div>

          <dl className="mt-lg border-t border-border">
            <SpecRow label="Category">
              <span className="capitalize">
                {item.category}
                {item.sub_category ? ` · ${item.sub_category}` : ''}
              </span>
            </SpecRow>
            {item.brand && <SpecRow label="Brand">{item.brand}</SpecRow>}
            {item.size && <SpecRow label="Size">{item.size}</SpecRow>}
            {item.colors.length > 0 && (
              <SpecRow label="Colours">
                <span className="flex flex-wrap items-center justify-end gap-x-md gap-y-xxs">
                  {item.colors.map((color) => {
                    const swatch = swatchFor(color)
                    return (
                      <span key={color} className="inline-flex items-center gap-xs capitalize">
                        {swatch && (
                          // Square, not round: an 8px circle with a ring beside a
                          // word reads as a radio button and invites a click it
                          // cannot answer. A crisp square reads as a colour sample.
                          <span
                            className="h-2.5 w-2.5 shrink-0 ring-1 ring-inset ring-border"
                            style={{ backgroundColor: swatch }}
                            aria-hidden="true"
                          />
                        )}
                        {color}
                      </span>
                    )
                  })}
                </span>
              </SpecRow>
            )}
            {item.tags.length > 0 && <SpecRow label="Tags">{item.tags.join(', ')}</SpecRow>}
            {item.occasion_tags?.length > 0 && (
              <SpecRow label="Use cases">
                {item.occasion_tags.map(formatUseCaseLabel).join(', ')}
              </SpecRow>
            )}
          </dl>

          {item.notes && (
            <div className="mt-lg">
              <p className="text-xs text-muted-foreground">Notes</p>
              <p className="mt-xxs whitespace-pre-line text-sm text-foreground">{item.notes}</p>
            </div>
          )}

          {/* Rendered only when there is genuinely more than one photo. A tab that
              said "No additional images" nine times out of ten was dead chrome. */}
          {extraImages.length > 0 && (
            <div className="mt-xl">
              <p className="text-xs text-muted-foreground">More photos</p>
              <div className="mt-sm grid grid-cols-3 gap-sm">
                {extraImages.map((image) => (
                  <div key={image.id} className="overflow-hidden rounded-md bg-card">
                    <ZoomableImage
                      src={image.thumbnail_url || image.image_url}
                      alt={item.name}
                      className="aspect-square w-full object-contain"
                    />
                  </div>
                ))}
              </div>
            </div>
          )}

          <div className="mt-xl border-t border-border pt-lg">
            {/* md:max-lg: the pane is only 211–289px wide in that one band (see
                MasterDetailLayout), where a 40px figure and the date cannot share
                a row. Stacking keeps the figure right-ranged instead of crushing it. */}
            <div className="flex items-end justify-between gap-lg md:max-lg:flex-col md:max-lg:items-stretch md:max-lg:gap-md">
              <div className="min-w-0">
                <p className="text-xs text-muted-foreground">Last worn</p>
                <p className="mt-xxs text-sm text-foreground">{lastWorn || 'Not yet'}</p>
              </div>
              <div className="shrink-0 text-right">
                <span className="block font-display text-[40px] font-bold leading-none tracking-[-0.01em] tabular-nums text-foreground">
                  {ledger.figure}
                </span>
                <span className="mt-xs block text-xs text-muted-foreground">{ledger.label}</span>
              </div>
            </div>
            <p className="mt-md text-xs tabular-nums text-muted-foreground">{ledger.note}</p>
          </div>
        </>
      )}
    </div>
  )
}

export default ItemDetailBody
