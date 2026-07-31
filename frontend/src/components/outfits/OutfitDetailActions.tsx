/**
 * OutfitDetailActions — the pinned action row of the outfit detail surface.
 *
 * Shape is deliberate: exactly ONE filled primary, then tertiary text actions,
 * then a single overflow menu. The old row was a filled primary next to two
 * outlined icon buttons — the filled-plus-outlined couplet this design language
 * rules out.
 */

import { Loader2, MoreVertical, Sparkles, Check, Copy, Share2, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

export interface OutfitDetailActionsProps {
  isGenerating: boolean
  isManaging: boolean
  generationStatus: string
  onGenerate: () => void
  onShare: () => void
  onMarkWorn: () => void
  onDuplicate: () => void
  onDelete: () => void
}

export function OutfitDetailActions({
  isGenerating,
  isManaging,
  generationStatus,
  onGenerate,
  onShare,
  onMarkWorn,
  onDuplicate,
  onDelete,
}: OutfitDetailActionsProps) {
  const busy = isGenerating || isManaging

  return (
    <div className="flex items-center gap-sm">
      <Button onClick={onGenerate} disabled={busy} className="min-w-0 flex-1">
        {isGenerating ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
            <span className="truncate">Generating…</span>
          </>
        ) : (
          <>
            <Sparkles className="h-4 w-4" aria-hidden="true" />
            <span className="truncate">
              {generationStatus === 'failed' ? 'Retry look' : 'Generate look'}
            </span>
          </>
        )}
      </Button>

      <Button variant="tertiary" onClick={onShare} disabled={isManaging} className="shrink-0">
        <Share2 className="h-4 w-4" aria-hidden="true" />
        Share
      </Button>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="tertiary" size="icon" aria-label="More outfit actions" className="shrink-0">
            <MoreVertical className="h-4 w-4" aria-hidden="true" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-48">
          <DropdownMenuItem disabled={busy} onClick={onMarkWorn}>
            <Check className="h-4 w-4 mr-2" aria-hidden="true" />
            Mark as worn
          </DropdownMenuItem>
          <DropdownMenuItem disabled={busy} onClick={onDuplicate}>
            <Copy className="h-4 w-4 mr-2" aria-hidden="true" />
            Duplicate
          </DropdownMenuItem>
          <DropdownMenuItem className="text-destructive" disabled={busy} onClick={onDelete}>
            <Trash2 className="h-4 w-4 mr-2" aria-hidden="true" />
            Delete
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  )
}

export default OutfitDetailActions
