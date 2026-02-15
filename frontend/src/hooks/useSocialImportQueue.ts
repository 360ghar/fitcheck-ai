import { useCallback, useEffect, useRef, useState } from 'react'
import {
  approveSocialImportPhoto,
  API_BASE_URL,
  cancelSocialImportJob,
  createSocialImportSSEConnection,
  getSocialImportOAuthConnectUrl,
  getSocialImportStatus,
  patchSocialImportItem,
  rejectSocialImportPhoto,
  startSocialImportJob,
  submitSocialImportOAuth,
  submitSocialImportScraperLogin,
} from '@/api/socialImport'
import type { SocialImportJobData, SocialImportItem, SocialImportSSEEvent } from '@/types'

const SOCIAL_IMPORT_ACTIVE_JOB_KEY = 'fitcheck.socialImport.activeJobId'
const SOCIAL_IMPORT_OAUTH_MESSAGE_SOURCE = 'fitcheck-social-oauth'
const SOCIAL_IMPORT_OAUTH_WINDOW_NAME = 'fitcheck-social-import-oauth'
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
  startOAuthConnect: () => Promise<void>
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
  reset: (options?: { cancelActiveJob?: boolean }) => Promise<void>
}

export function useSocialImportQueue(): UseSocialImportQueue {
  const [state, setState] = useState<SocialImportQueueState>(initialState)
  const disconnectRef = useRef<(() => void) | null>(null)
  const reconnectAttempts = useRef(0)
  const reconnectTimerRef = useRef<number | null>(null)
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
    if (reconnectTimerRef.current !== null && typeof window !== 'undefined') {
      window.clearTimeout(reconnectTimerRef.current)
      reconnectTimerRef.current = null
    }
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
          reconnectAttempts.current = 0
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
            if (reconnectTimerRef.current !== null && typeof window !== 'undefined') {
              window.clearTimeout(reconnectTimerRef.current)
            }
            reconnectTimerRef.current = window.setTimeout(
              () => connect(jobId),
              1000 * reconnectAttempts.current
            )
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

  const startOAuthConnect = useCallback(async () => {
    if (!state.jobId) return

    const jobId = state.jobId
    setState((prev) => ({ ...prev, isLoading: true, error: null }))

    try {
      const oauth = await getSocialImportOAuthConnectUrl(jobId)
      const popup = window.open(
        oauth.auth_url,
        SOCIAL_IMPORT_OAUTH_WINDOW_NAME,
        'width=520,height=740'
      )
      if (!popup) {
        throw new Error('Popup blocked. Please allow popups to connect your social account.')
      }
      popup.focus()

      await new Promise<void>((resolve, reject) => {
        let settled = false
        const expectedOrigin = new URL(API_BASE_URL).origin

        const cleanup = () => {
          if (settled) return
          settled = true
          window.clearTimeout(timeoutId)
          window.clearInterval(closePollId)
          window.removeEventListener('message', onMessage)
        }

        const onMessage = (event: MessageEvent) => {
          if (event.origin !== expectedOrigin) return

          const data = event.data as Record<string, unknown> | null
          if (!data || data.source !== SOCIAL_IMPORT_OAUTH_MESSAGE_SOURCE) return

          const eventJobId = typeof data.job_id === 'string' ? data.job_id : null
          if (eventJobId && eventJobId !== jobId) return

          cleanup()

          const oauthStatus = typeof data.status === 'string' ? data.status : 'error'
          const message =
            typeof data.message === 'string'
              ? data.message
              : 'Social account authorization failed'
          if (oauthStatus === 'success') {
            resolve()
            return
          }
          reject(new Error(message))
        }

        const timeoutId = window.setTimeout(() => {
          cleanup()
          reject(new Error('Social login timed out. Please retry.'))
        }, 120000)

        const closePollId = window.setInterval(() => {
          if (popup.closed) {
            cleanup()
            reject(new Error('Social login window was closed before completion.'))
          }
        }, 300)

        window.addEventListener('message', onMessage)
      })

      await refreshStatus()
      connect(jobId)
    } catch (error) {
      setState((prev) => ({
        ...prev,
        error:
          error instanceof Error
            ? error.message
            : 'Failed to connect social account',
      }))
    } finally {
      setState((prev) => ({ ...prev, isLoading: false }))
    }
  }, [connect, refreshStatus, state.jobId])

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
      setState((prev) => ({ ...prev, isLoading: true, error: null }))
      try {
        await submitSocialImportScraperLogin(state.jobId, payload)
        await refreshStatus()
        connect(state.jobId)
      } catch (error) {
        setState((prev) => ({
          ...prev,
          error: error instanceof Error ? error.message : 'Failed to submit login details',
        }))
      } finally {
        setState((prev) => ({ ...prev, isLoading: false }))
      }
    },
    [connect, refreshStatus, state.jobId]
  )

  const updateItem = useCallback(
    async (photoId: string, itemId: string, updates: Partial<SocialImportItem>) => {
      if (!state.jobId) return
      try {
        await patchSocialImportItem(state.jobId, photoId, itemId, updates)
        await refreshStatus()
      } catch (error) {
        setState((prev) => ({
          ...prev,
          error: error instanceof Error ? error.message : 'Failed to update item',
        }))
      }
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

  const reset = useCallback(async (options?: { cancelActiveJob?: boolean }) => {
    const shouldCancel = options?.cancelActiveJob ?? true
    const activeJobId = state.jobId
    const activeStatus = state.status
    if (shouldCancel && activeJobId && !isTerminalStatus(activeStatus)) {
      try {
        await cancelSocialImportJob(activeJobId)
      } catch {
        // Even if cancel fails, continue resetting local state to prevent stale UI.
      }
    }

    disconnect()
    reconnectAttempts.current = 0
    if (reconnectTimerRef.current !== null && typeof window !== 'undefined') {
      window.clearTimeout(reconnectTimerRef.current)
      reconnectTimerRef.current = null
    }
    lastEventIdRef.current = null
    setActiveJobId(null)
    setState(initialState)
  }, [disconnect, state.jobId, state.status])

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
    startOAuthConnect,
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
