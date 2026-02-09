import { Loader2 } from 'lucide-react'

import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import type { SocialImportJobData } from '@/types'

interface SocialImportProgressProps {
  job: SocialImportJobData
  isConnected: boolean
}

function getCompletionProgress(job: SocialImportJobData): number {
  if (job.total_photos <= 0) return 0
  return Math.min(100, Math.round((job.processed_photos / job.total_photos) * 100))
}

export function SocialImportProgress({ job, isConnected }: SocialImportProgressProps) {
  const progress = getCompletionProgress(job)

  return (
    <div className="space-y-3 rounded-lg border border-border bg-card p-4">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <p className="text-sm font-semibold text-foreground">Social Import Progress</p>
          {isConnected ? (
            <Badge variant="secondary" className="bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300">
              Live
            </Badge>
          ) : (
            <Badge variant="outline">Offline</Badge>
          )}
        </div>
        <Badge variant="outline">{job.status}</Badge>
      </div>

      <Progress value={progress} className="h-2" />

      <div className="grid grid-cols-2 gap-2 text-xs text-muted-foreground sm:grid-cols-4">
        <div>
          <p className="font-semibold text-foreground">{job.discovered_photos}</p>
          <p>Discovered</p>
        </div>
        <div>
          <p className="font-semibold text-foreground">{job.processed_photos}</p>
          <p>Processed</p>
        </div>
        <div>
          <p className="font-semibold text-foreground">{job.approved_photos}</p>
          <p>Approved</p>
        </div>
        <div>
          <p className="font-semibold text-foreground">{job.queued_count}</p>
          <p>Queued</p>
        </div>
      </div>

      {(job.processing_photo || job.status === 'processing') && (
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <Loader2 className="h-3.5 w-3.5 animate-spin" />
          <span>
            {job.processing_photo
              ? `Processing photo #${job.processing_photo.ordinal}`
              : 'Processing next photo'}
          </span>
        </div>
      )}

      {job.error_message && (
        <div className="rounded-md border border-amber-300 bg-amber-50 px-3 py-2 text-xs text-amber-800 dark:border-amber-700/60 dark:bg-amber-950/30 dark:text-amber-200">
          {job.error_message}
        </div>
      )}
    </div>
  )
}

export default SocialImportProgress
