/**
 * App-level job UI store.
 *
 * Surfaces a single background "job pill" for long AI work so users can leave
 * a flow and return without losing progress awareness.
 */

import { create } from 'zustand'

export interface JobUiStatus {
  /** Stable id for the active job (batch job id, feature key, etc.) */
  id: string
  /** Short human label shown in the pill */
  label: string
  /** True while work is in flight (spinner) */
  isActive: boolean
  /** Optional ETA in seconds */
  etaSeconds?: number | null
  /** Open the originating UI when the pill is clicked */
  onOpen?: () => void
  /** Optional route to navigate if onOpen is not set */
  href?: string
}

interface JobUiState {
  job: JobUiStatus | null
  setJob: (job: JobUiStatus | null) => void
  /**
   * Clear the pill. When `id` is provided, only clears if it matches the
   * active job (so one feature cannot wipe another's status).
   * When `id` is omitted, clears whatever is active (use sparingly).
   */
  clearJob: (id?: string) => void
}

export const useJobUiStore = create<JobUiState>((set, get) => ({
  job: null,

  setJob: (job) => set({ job }),

  clearJob: (id) => {
    const current = get().job
    if (!current) return
    if (id != null && current.id !== id) return
    set({ job: null })
  },
}))
