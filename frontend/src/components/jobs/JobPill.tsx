/**
 * Fixed progress pill for background AI jobs.
 * Hosted in AppLayout so wardrobe, dashboard, and other flows share one surface.
 */

import { useNavigate } from 'react-router-dom'
import { Loader2, Sparkles } from 'lucide-react'
import { useJobUiStore } from '@/stores/jobUiStore'
import { cn } from '@/lib/utils'

function formatEta(seconds: number | null | undefined): string | null {
  if (seconds == null || seconds <= 0) return null
  if (seconds < 60) return `~${seconds}s`
  return `~${Math.ceil(seconds / 60)}m`
}

export function JobPill() {
  const job = useJobUiStore((s) => s.job)
  const navigate = useNavigate()

  if (!job) return null

  const eta = formatEta(job.etaSeconds)
  const canOpen = Boolean(job.onOpen || job.href)

  const handleClick = () => {
    // Always navigate when href is set so soft-closed jobs work cross-route.
    if (job.href) {
      navigate(job.href)
    }
    // Then run page-local open (reopen modal/dialog) after navigation settles.
    if (job.onOpen) {
      // Defer so route components mount before local state openers run.
      window.setTimeout(() => {
        job.onOpen?.()
      }, 0)
    }
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={!canOpen}
      className={cn(
        'fixed bottom-20 md:bottom-6 left-1/2 z-40 -translate-x-1/2',
        'flex items-center gap-2 rounded-full border border-border bg-background',
        'px-4 py-2.5 text-sm font-medium text-foreground shadow-md',
        'max-w-[min(92vw,24rem)]',
        !canOpen && 'opacity-80 cursor-default'
      )}
      aria-label={`Open job progress: ${job.label}`}
    >
      {job.isActive ? (
        <Loader2 className="h-4 w-4 shrink-0 animate-spin text-primary" />
      ) : (
        <Sparkles className="h-4 w-4 shrink-0 text-primary" />
      )}
      <span className="truncate">{job.label}</span>
      {eta && job.isActive && (
        <span className="hidden sm:inline text-muted-foreground shrink-0">· {eta}</span>
      )}
      {canOpen && <span className="text-primary shrink-0">View</span>}
    </button>
  )
}

export default JobPill
