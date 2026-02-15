import { Check, Clock3, X } from 'lucide-react'

import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { SocialImportPhoto } from '@/types'

interface SocialImportQueueReviewProps {
  awaitingPhoto?: SocialImportPhoto | null
  bufferedPhoto?: SocialImportPhoto | null
  processingPhoto?: SocialImportPhoto | null
  onApprove: () => Promise<void>
  onReject: () => Promise<void>
  onItemUpdate: (photoId: string, itemId: string, updates: Record<string, unknown>) => Promise<void>
  isBusy?: boolean
}

export function SocialImportQueueReview({
  awaitingPhoto,
  bufferedPhoto,
  processingPhoto,
  onApprove,
  onReject,
  onItemUpdate,
  isBusy = false,
}: SocialImportQueueReviewProps) {
  if (!awaitingPhoto) {
    return (
      <div className="rounded-lg border border-border p-6 text-center text-sm text-muted-foreground">
        No photo is currently awaiting your review.
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 lg:grid-cols-2">
        <div className="space-y-3 rounded-lg border border-border p-4">
          <div className="flex items-center justify-between gap-2">
            <p className="text-sm font-semibold text-foreground">Awaiting Confirmation</p>
            <Badge className="bg-indigo-500 text-white">Photo #{awaitingPhoto.ordinal}</Badge>
          </div>

          <img
            src={awaitingPhoto.source_thumb_url || awaitingPhoto.source_photo_url}
            alt={`Photo ${awaitingPhoto.ordinal}`}
            className="h-56 w-full rounded-md object-cover"
          />

          <div className="space-y-3">
            {awaitingPhoto.items.map((item) => (
              <div key={item.id} className="rounded-md border border-border p-3">
                <div className="grid gap-2 sm:grid-cols-2">
                  <Input
                    defaultValue={item.name || ''}
                    placeholder="Item name"
                    onBlur={(e) => onItemUpdate(awaitingPhoto.id, item.id, { name: e.target.value.trim() || null })}
                  />
                  <Input
                    defaultValue={item.category}
                    placeholder="Category"
                    onBlur={(e) => onItemUpdate(awaitingPhoto.id, item.id, { category: e.target.value.trim() || item.category })}
                  />
                </div>

                <div className="mt-2 grid gap-2 sm:grid-cols-2">
                  <Input
                    defaultValue={(item.colors || []).join(', ')}
                    placeholder="Colors (comma-separated)"
                    onBlur={(e) =>
                      onItemUpdate(awaitingPhoto.id, item.id, {
                        colors: e.target.value
                          .split(',')
                          .map((c) => c.trim())
                          .filter(Boolean),
                      })
                    }
                  />
                  <Input
                    defaultValue={item.material || ''}
                    placeholder="Material"
                    onBlur={(e) => onItemUpdate(awaitingPhoto.id, item.id, { material: e.target.value.trim() || null })}
                  />
                </div>

                {item.generated_image_url ? (
                  <img
                    src={item.generated_image_url}
                    alt={item.name || item.category}
                    className="mt-2 h-40 w-full rounded-md object-contain bg-muted"
                  />
                ) : (
                  <div className="mt-2 rounded-md border border-dashed border-border p-3 text-xs text-muted-foreground">
                    Generation unavailable: {item.generation_error || 'Unknown error'}
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="flex flex-wrap justify-end gap-2 pt-2">
            <Button variant="outline" disabled={isBusy} onClick={() => onReject()}>
              <X className="mr-2 h-4 w-4" />
              Reject
            </Button>
            <Button disabled={isBusy} onClick={() => onApprove()}>
              <Check className="mr-2 h-4 w-4" />
              Approve & Save
            </Button>
          </div>
        </div>

        <div className="space-y-3 rounded-lg border border-border p-4">
          <div className="flex items-center justify-between gap-2">
            <p className="text-sm font-semibold text-foreground">Next In Background</p>
            {bufferedPhoto ? (
              <Badge variant="secondary">Ready</Badge>
            ) : processingPhoto ? (
              <Badge variant="outline" className="gap-1">
                <Clock3 className="h-3.5 w-3.5" />
                Processing
              </Badge>
            ) : (
              <Badge variant="outline">Waiting</Badge>
            )}
          </div>

          {bufferedPhoto ? (
            <div className="space-y-2">
              <img
                src={bufferedPhoto.source_thumb_url || bufferedPhoto.source_photo_url}
                alt={`Buffered photo ${bufferedPhoto.ordinal}`}
                className="h-56 w-full rounded-md object-cover"
              />
              <p className="text-xs text-muted-foreground">
                Photo #{bufferedPhoto.ordinal} is fully ready and will appear immediately after approval/rejection.
              </p>
            </div>
          ) : processingPhoto ? (
            <div className="space-y-2">
              <img
                src={processingPhoto.source_thumb_url || processingPhoto.source_photo_url}
                alt={`Processing photo ${processingPhoto.ordinal}`}
                className="h-56 w-full rounded-md object-cover opacity-80"
              />
              <p className="text-xs text-muted-foreground">Photo #{processingPhoto.ordinal} is currently being processed.</p>
            </div>
          ) : (
            <div className="rounded-md border border-dashed border-border p-4 text-xs text-muted-foreground">
              No secondary photo yet. The queue will fill automatically as discovery and processing continue.
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default SocialImportQueueReview
