import { useCallback, useEffect, useRef, useState } from 'react'
import {
  approveSocialImportPhoto,
  cancelSocialImportJob,
  createSocialImportSSEConnection,
  getSocialImportStatus,
  patchSocialImportItem,
  rejectSocialImportPhoto,
  startSocialImportJob,
  submitSocialImportOAuth,
  submitSocialImportScraperLogin,
} from '@/api/socialImport'
import type { SocialImportJobData, SocialImportItem, SocialImportSSEEvent } from '@/types'

const SOCIAL_IMPORT_ACTIVE_JOB_KEY = 'fitcheck.socialImport.activeJobId'
const TERMINAL_JOB_STATUSES: SocialImportJobData['status'][] = ['completed', 'cancelled', 'failed']

interface SocialImportQueueState {
  jobId: string | null
  job: SocialImportJobData | null
  awaitingPhotoId: string | null
  bufferedPhotoId: string | null
  processingPhotoId: string | null
  status: SocialImportJobData['status'] | null
  authRequired: boolean
  isConnected: boolean
  lastEventId: number | null
  isLoading: boolean
  error: string | null
}

const initialState: SocialImportQueueState = {
  jobId: null,
  job: null,
  awaitingPhotoId: null,
  bufferedPhotoId: null,
  processingPhotoId: null,
  status: null,
  authRequired: false,
  isConnected: false,
  lastEventId: null,
  isLoading: false,
  error: null,
}

function isTerminalStatus(status: SocialImportJobData['status'] | null | undefined): boolean {
  if (!status) return false
  return TERMINAL_JOB_STATUSES.includes(status)
}

function setActiveJobId(jobId: string | null): void {
  if (typeof window === 'undefined') return
  if (!jobId) {
    window.localStorage.removeItem(SOCIAL_IMPORT_ACTIVE_JOB_KEY)
    return
  }
  window.localStorage.setItem(SOCIAL_IMPORT_ACTIVE_JOB_KEY, jobId)
}

export interface UseSocialImportQueue {
  state: SocialImportQueueState
  startJob: (sourceUrl: string) => Promise<void>
  refreshStatus: () => Promise<void>
  submitOAuthAuth: (payload: {
    provider_access_token: string
    provider_refresh_token?: string
    provider_user_id?: string
    expires_at?: string
  }) => Promise<void>
  submitScraperAuth: (payload: { username: string; password: string; otp_code?: string }) => Promise<void>
  updateItem: (photoId: string, itemId: string, updates: Partial<SocialImportItem>) => Promise<void>
  approveAwaiting: () => Promise<void>
  rejectAwaiting: () => Promise<void>
  cancelJob: () => Promise<void>
  reset: () => void
}

export function useSocialImportQueue(): UseSocialImportQueue {
  const [state, setState] = useState<SocialImportQueueState>(initialState)
  const disconnectRef = useRef<(() => void) | null>(null)
  const reconnectAttempts = useRef(0)
  const lastEventIdRef = useRef<number | null>(null)

  const applyJobData = useCallback((job: SocialImportJobData) => {
    const terminal = isTerminalStatus(job.status)
    setActiveJobId(terminal ? null : job.id)
    setState((prev) => ({
      ...prev,
      jobId: job.id,
      job,
      status: job.status,
      authRequired: job.auth_required || job.status === 'awaiting_auth',
      awaitingPhotoId: job.awaiting_review_photo?.id || null,
      bufferedPhotoId: job.buffered_photo?.id || null,
      processingPhotoId: job.processing_photo?.id || null,
      error: job.error_message || null,
    }))
  }, [])

  const disconnect = useCallback(() => {
    if (disconnectRef.current) {
      disconnectRef.current()
      disconnectRef.current = null
    }
    setState((prev) => ({ ...prev, isConnected: false }))
  }, [])

  const refreshStatus = useCallback(async () => {
    if (!state.jobId) return
    const job = await getSocialImportStatus(state.jobId)
    applyJobData(job)
  }, [applyJobData, state.jobId])

  const connect = useCallback(
    (jobId: string) => {
      disconnect()

      disconnectRef.current = createSocialImportSSEConnection(
        jobId,
        (event: SocialImportSSEEvent) => {
          if (typeof event.id === 'number') {
            lastEventIdRef.current = event.id
          }
          setState((prev) => ({
            ...prev,
            isConnected: true,
            lastEventId: event.id ?? prev.lastEventId,
          }))

          if (event.type === 'heartbeat') {
            return
          }

          if (event.type === 'connected') {
            return
          }

          // Keep client state authoritative by re-fetching compact status snapshot.
          void getSocialImportStatus(jobId)
            .then((job) => {
              applyJobData(job)
              if (isTerminalStatus(job.status)) {
                disconnect()
              }
            })
            .catch((err) => {
              setState((prev) => ({
                ...prev,
                error: err instanceof Error ? err.message : 'Failed to refresh status',
              }))
            })
        },
        (error) => {
          setState((prev) => ({
            ...prev,
            isConnected: false,
            error: error.message,
          }))

          if (reconnectAttempts.current < 3) {
            reconnectAttempts.current += 1
            window.setTimeout(() => connect(jobId), 1000 * reconnectAttempts.current)
          }
        },
        lastEventIdRef.current ?? undefined
      )
    },
    [applyJobData, disconnect]
  )

  const startJob = useCallback(
    async (sourceUrl: string) => {
      setState((prev) => ({ ...prev, isLoading: true, error: null }))
      try {
        const started = await startSocialImportJob(sourceUrl)
        const jobId = started.job_id
        setActiveJobId(jobId)
        const job = await getSocialImportStatus(jobId)
        setState((prev) => ({
          ...prev,
          isLoading: false,
          jobId,
        }))
        applyJobData(job)
        reconnectAttempts.current = 0
        connect(jobId)
      } catch (error) {
        setState((prev) => ({
          ...prev,
          isLoading: false,
          error: error instanceof Error ? error.message : 'Failed to start import',
        }))
      }
    },
    [applyJobData, connect]
  )

  const submitOAuthAuth = useCallback(
    async (payload: {
      provider_access_token: string
      provider_refresh_token?: string
      provider_user_id?: string
      expires_at?: string
    }) => {
      if (!state.jobId) return
      await submitSocialImportOAuth(state.jobId, payload)
      await refreshStatus()
      connect(state.jobId)
    },
    [connect, refreshStatus, state.jobId]
  )

  const submitScraperAuth = useCallback(
    async (payload: { username: string; password: string; otp_code?: string }) => {
      if (!state.jobId) return
      await submitSocialImportScraperLogin(state.jobId, payload)
      await refreshStatus()
      connect(state.jobId)
    },
    [connect, refreshStatus, state.jobId]
  )

  const updateItem = useCallback(
    async (photoId: string, itemId: string, updates: Partial<SocialImportItem>) => {
      if (!state.jobId) return
      await patchSocialImportItem(state.jobId, photoId, itemId, updates)
      await refreshStatus()
    },
    [refreshStatus, state.jobId]
  )

  const approveAwaiting = useCallback(async () => {
    if (!state.jobId || !state.awaitingPhotoId) return
    await approveSocialImportPhoto(state.jobId, state.awaitingPhotoId)
    await refreshStatus()
  }, [refreshStatus, state.awaitingPhotoId, state.jobId])

  const rejectAwaiting = useCallback(async () => {
    if (!state.jobId || !state.awaitingPhotoId) return
    await rejectSocialImportPhoto(state.jobId, state.awaitingPhotoId)
    await refreshStatus()
  }, [refreshStatus, state.awaitingPhotoId, state.jobId])

  const cancelJob = useCallback(async () => {
    if (!state.jobId) return
    await cancelSocialImportJob(state.jobId)
    await refreshStatus()
    setActiveJobId(null)
    disconnect()
  }, [disconnect, refreshStatus, state.jobId])

  const reset = useCallback(() => {
    disconnect()
    reconnectAttempts.current = 0
    lastEventIdRef.current = null
    setActiveJobId(null)
    setState(initialState)
  }, [disconnect])

  useEffect(() => {
    lastEventIdRef.current = state.lastEventId
  }, [state.lastEventId])

  useEffect(() => {
    if (typeof window === 'undefined') return
    const cachedJobId = window.localStorage.getItem(SOCIAL_IMPORT_ACTIVE_JOB_KEY)
    if (!cachedJobId) return

    setState((prev) => ({ ...prev, isLoading: true, error: null }))
    void getSocialImportStatus(cachedJobId)
      .then((job) => {
        applyJobData(job)
        setState((prev) => ({ ...prev, isLoading: false }))
        reconnectAttempts.current = 0
        if (!isTerminalStatus(job.status)) {
          connect(job.id)
        }
      })
      .catch((error) => {
        setState((prev) => ({
          ...prev,
          isLoading: false,
          error: error instanceof Error ? error.message : 'Failed to resume social import job',
        }))
        setActiveJobId(null)
      })
  }, [applyJobData, connect])

  useEffect(
    () => () => {
      disconnect()
    },
    [disconnect]
  )

  return {
    state,
    startJob,
    refreshStatus,
    submitOAuthAuth,
    submitScraperAuth,
    updateItem,
    approveAwaiting,
    rejectAwaiting,
    cancelJob,
    reset,
  }
}

export default useSocialImportQueue
