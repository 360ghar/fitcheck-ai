/**
 * Shared long-wait surface for AI generation.
 * Always keeps source previews visible — never a blank spinner void.
 */

import { Loader2 } from 'lucide-react'
import { Progress } from '@/components/ui/progress'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

export interface GeneratingSurfaceProps {
  /** Primary stage line, e.g. "Generating studio look…" */
  stage: string
  /** Secondary honest time / help copy */
  detail?: string
  /** Optional determinate progress 0–100; omit for indeterminate */
  progress?: number | null
  /** Preview images shown while waiting */
  previewUrls?: string[]
  /** Optional caption under previews */
  previewLabel?: string
  /** Show spinner ring */
  isActive?: boolean
  onCancel?: () => void
  onBackground?: () => void
  className?: string
  children?: React.ReactNode
}

export function GeneratingSurface({
  stage,
  detail,
  progress,
  previewUrls,
  previewLabel,
  isActive = true,
  onCancel,
  onBackground,
  className,
  children,
}: GeneratingSurfaceProps) {
  const hasProgress = typeof progress === 'number' && progress >= 0
  const previews = (previewUrls || []).filter(Boolean).slice(0, 4)

  return (
    <div
      className={cn(
        'rounded-xl border border-border bg-card p-4 md:p-6 space-y-5',
        className
      )}
    >
      {previews.length > 0 && (
        <div className="space-y-2">
          {previewLabel && (
            <p className="text-xs font-medium text-muted-foreground">{previewLabel}</p>
          )}
          <div
            className={cn(
              'grid gap-2',
              previews.length === 1 && 'grid-cols-1 max-w-xs mx-auto',
              previews.length === 2 && 'grid-cols-2 max-w-md mx-auto',
              previews.length >= 3 && 'grid-cols-2 sm:grid-cols-4'
            )}
          >
            {previews.map((url, i) => (
              <div
                key={`${url.slice(0, 24)}-${i}`}
                className="aspect-square rounded-lg overflow-hidden bg-muted border border-border"
              >
                <img
                  src={url}
                  alt=""
                  className="w-full h-full object-cover"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="flex flex-col items-center text-center space-y-3">
        {isActive && (
          <Loader2 className="h-8 w-8 text-primary animate-spin" aria-hidden />
        )}
        <div className="space-y-1">
          <p className="text-base font-medium text-foreground">{stage}</p>
          {detail && (
            <p className="text-sm text-muted-foreground max-w-sm">{detail}</p>
          )}
        </div>

        {hasProgress ? (
          <div className="w-full max-w-xs space-y-1.5">
            <Progress value={progress} className="h-1.5" />
            <p className="text-xs text-muted-foreground">{Math.round(progress!)}%</p>
          </div>
        ) : isActive ? (
          <div className="w-full max-w-xs">
            <div className="h-1.5 rounded-full bg-muted overflow-hidden">
              <div className="h-full w-1/3 rounded-full bg-primary/70 animate-pulse" />
            </div>
          </div>
        ) : null}
      </div>

      {children}

      {(onCancel || onBackground) && (
        <div className="flex flex-wrap items-center justify-center gap-2 pt-1">
          {onBackground && (
            <Button type="button" variant="outline" size="sm" onClick={onBackground}>
              Continue in background
            </Button>
          )}
          {onCancel && (
            <Button type="button" variant="ghost" size="sm" onClick={onCancel}>
              Cancel
            </Button>
          )}
        </div>
      )}
    </div>
  )
}

export default GeneratingSurface
