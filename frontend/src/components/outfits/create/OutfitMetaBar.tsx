/**
 * OutfitMetaBar — the draft's metadata, in ONE row.
 *
 * The deleted dialog gave this a whole left-hand column: five stacked
 * label-over-field pairs plus a `Textarea`, roughly 340px of vertical space for
 * fields that are mostly optional. Here it is a single 12-column row on one
 * shared baseline, and every control is `h-11` (DESIGN.md 03) so the row cannot
 * go ragged no matter which field is longest.
 *
 * Labels are `sr-only`: at this density a visible label above each field is what
 * turned the row into a column. The placeholder carries the name, the value
 * carries the rest, and screen readers still get a real <label>.
 *
 * Description demotes to a `Collapsible` "Add a note" under the row. It is the
 * one field nobody fills, and in the dialog it was the single largest control on
 * screen.
 */

import * as React from 'react'
import { ChevronDown } from 'lucide-react'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { cn } from '@/lib/utils'
import type { Season, Style } from '@/types'
import { DEFAULT_SEASON, DEFAULT_STYLE, SEASONS, STYLES } from './constants'

export interface OutfitMetaBarProps {
  name: string
  onNameChange: (value: string) => void
  style?: Style
  onStyleChange: (value: Style) => void
  season?: Season
  onSeasonChange: (value: Season) => void
  occasion: string
  onOccasionChange: (value: string) => void
  tags: string[]
  onTagsChange: (value: string[]) => void
  description: string
  onDescriptionChange: (value: string) => void
  disabled?: boolean
}

export function OutfitMetaBar({
  name,
  onNameChange,
  style,
  onStyleChange,
  season,
  onSeasonChange,
  occasion,
  onOccasionChange,
  tags,
  onTagsChange,
  description,
  onDescriptionChange,
  disabled,
}: OutfitMetaBarProps) {
  const [isNoteOpen, setIsNoteOpen] = React.useState(description.trim().length > 0)
  const tagsValue = React.useMemo(() => tags.join(', '), [tags])

  return (
    <div className="mb-lg">
      {/* items-end holds the shared baseline: if any control ever grew a helper
          line, the others would still sit on the same bottom edge. */}
      <div className="grid grid-cols-1 gap-md md:grid-cols-12 md:items-end">
        <div className="md:col-span-4">
          <Label htmlFor="outfit-name" className="sr-only">
            Outfit name
          </Label>
          <Input
            id="outfit-name"
            value={name}
            onChange={(e) => onNameChange(e.target.value)}
            placeholder="Name this look"
            disabled={disabled}
            autoComplete="off"
          />
        </div>

        <div className="md:col-span-2">
          <Label htmlFor="outfit-style" className="sr-only">
            Style
          </Label>
          <Select
            value={style || DEFAULT_STYLE}
            onValueChange={(value) => onStyleChange(value as Style)}
            disabled={disabled}
          >
            <SelectTrigger id="outfit-style" className="capitalize">
              <SelectValue placeholder="Style" />
            </SelectTrigger>
            <SelectContent>
              {STYLES.map((option) => (
                <SelectItem key={option} value={option} className="capitalize">
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="md:col-span-2">
          <Label htmlFor="outfit-season" className="sr-only">
            Season
          </Label>
          <Select
            value={season || DEFAULT_SEASON}
            onValueChange={(value) => onSeasonChange(value as Season)}
            disabled={disabled}
          >
            <SelectTrigger id="outfit-season" className="capitalize">
              <SelectValue placeholder="Season" />
            </SelectTrigger>
            <SelectContent>
              {SEASONS.map((option) => (
                <SelectItem key={option} value={option} className="capitalize">
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="md:col-span-2">
          <Label htmlFor="outfit-occasion" className="sr-only">
            Occasion
          </Label>
          <Input
            id="outfit-occasion"
            value={occasion}
            onChange={(e) => onOccasionChange(e.target.value)}
            placeholder="Occasion"
            disabled={disabled}
            autoComplete="off"
          />
        </div>

        <div className="md:col-span-2">
          <Label htmlFor="outfit-tags" className="sr-only">
            Tags, comma separated
          </Label>
          <Input
            id="outfit-tags"
            value={tagsValue}
            onChange={(e) =>
              onTagsChange(
                e.target.value
                  .split(',')
                  .map((tag) => tag.trim())
                  .filter(Boolean)
              )
            }
            placeholder="Tags"
            disabled={disabled}
            autoComplete="off"
          />
          {/* No badge row under this field. The old dialog echoed every tag back
              as a tinted pill; the input already shows exactly what was typed. */}
        </div>
      </div>

      <Collapsible open={isNoteOpen} onOpenChange={setIsNoteOpen}>
        <CollapsibleTrigger
          className={cn(
            'mt-sm inline-flex min-h-touch items-center gap-xxs text-sm text-muted-foreground',
            'transition-colors hover:text-foreground',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2'
          )}
          disabled={disabled}
        >
          <ChevronDown
            className={cn('h-4 w-4 transition-transform', isNoteOpen && 'rotate-180')}
            aria-hidden="true"
          />
          {isNoteOpen ? 'Hide note' : 'Add a note'}
        </CollapsibleTrigger>
        <CollapsibleContent>
          <Label htmlFor="outfit-description" className="sr-only">
            Note
          </Label>
          <Textarea
            id="outfit-description"
            value={description}
            onChange={(e) => onDescriptionChange(e.target.value)}
            placeholder="Anything worth remembering about this look"
            rows={2}
            disabled={disabled}
            className="mt-sm"
          />
        </CollapsibleContent>
      </Collapsible>
    </div>
  )
}

export default OutfitMetaBar
