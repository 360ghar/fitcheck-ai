/**
 * Shared inline status treatment for quick, page-embedded AI actions
 * (a button that calls one synchronous endpoint and swaps its own label).
 * Not for long full-screen AI waits — see components/jobs/GeneratingSurface.
 */

import { Loader2 } from 'lucide-react'

/**
 * Button label that swaps to a spinner + phase copy while loading, and after
 * ~3s degrades to an honest elapsed-time readout instead of a fake progress
 * bar (these are plain synchronous calls with no queue/phases to report).
 */
export function ActionStatusLabel({
  loading,
  phaseText,
  elapsedSeconds,
  idleText,
}: {
  loading: boolean
  phaseText: string
  elapsedSeconds: number
  idleText: string
}) {
  if (!loading) return <>{idleText}</>
  return (
    <span className="inline-flex items-center gap-2">
      <Loader2 className="h-4 w-4 animate-spin" aria-hidden />
      {elapsedSeconds > 3 ? `Processing… (${elapsedSeconds}s elapsed)` : phaseText}
    </span>
  )
}

/** Persistent inline failure note — the real API error, plus a retry hint.
 * Re-clicking the trigger button is the retry action; nothing else to wire. */
export function ActionErrorNote({ message }: { message: string }) {
  return (
    <p className="text-sm text-destructive" role="alert">
      {message} — try again.
    </p>
  )
}
