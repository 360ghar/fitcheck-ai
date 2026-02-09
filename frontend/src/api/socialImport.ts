import { apiClient, getAccessToken, getApiError } from './client'
import type { SocialImportJobData, SocialImportItem, SocialImportSSEEvent } from '@/types'

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000'

interface ApiEnvelope<T> {
  data: T
  message?: string
}

export interface StartSocialImportResponse {
  job_id: string
  status: string
  platform: string
  source_url: string
  normalized_url: string
  message: string
}

export async function startSocialImportJob(sourceUrl: string): Promise<StartSocialImportResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<StartSocialImportResponse>>('/api/v1/ai/social-import/jobs', {
      source_url: sourceUrl,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function getSocialImportStatus(jobId: string): Promise<SocialImportJobData> {
  try {
    const response = await apiClient.get<ApiEnvelope<SocialImportJobData>>(
      `/api/v1/ai/social-import/jobs/${jobId}/status`
    )
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function submitSocialImportOAuth(
  jobId: string,
  payload: {
    provider_access_token: string
    provider_refresh_token?: string
    provider_user_id?: string
    expires_at?: string
  }
): Promise<void> {
  try {
    await apiClient.post(`/api/v1/ai/social-import/jobs/${jobId}/auth/oauth`, payload)
  } catch (error) {
    throw getApiError(error)
  }
}

export async function submitSocialImportScraperLogin(
  jobId: string,
  payload: {
    username: string
    password: string
    otp_code?: string
  }
): Promise<void> {
  try {
    await apiClient.post(`/api/v1/ai/social-import/jobs/${jobId}/auth/scraper-login`, payload)
  } catch (error) {
    throw getApiError(error)
  }
}

export async function patchSocialImportItem(
  jobId: string,
  photoId: string,
  itemId: string,
  payload: Partial<SocialImportItem>
): Promise<SocialImportItem> {
  try {
    const response = await apiClient.patch<ApiEnvelope<SocialImportItem>>(
      `/api/v1/ai/social-import/jobs/${jobId}/photos/${photoId}/items/${itemId}`,
      payload
    )
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function approveSocialImportPhoto(jobId: string, photoId: string): Promise<void> {
  try {
    await apiClient.post(`/api/v1/ai/social-import/jobs/${jobId}/photos/${photoId}/approve`)
  } catch (error) {
    throw getApiError(error)
  }
}

export async function rejectSocialImportPhoto(jobId: string, photoId: string): Promise<void> {
  try {
    await apiClient.post(`/api/v1/ai/social-import/jobs/${jobId}/photos/${photoId}/reject`)
  } catch (error) {
    throw getApiError(error)
  }
}

export async function cancelSocialImportJob(jobId: string): Promise<void> {
  try {
    await apiClient.post(`/api/v1/ai/social-import/jobs/${jobId}/cancel`)
  } catch (error) {
    throw getApiError(error)
  }
}

export function createSocialImportSSEConnection(
  jobId: string,
  onMessage: (event: SocialImportSSEEvent) => void,
  onError?: (error: Error) => void,
  lastEventId?: number
): () => void {
  const controller = new AbortController()
  const token = getAccessToken()

  const search = new URLSearchParams()
  if (lastEventId !== undefined) {
    search.set('last_event_id', String(lastEventId))
  }
  const suffix = search.toString() ? `?${search.toString()}` : ''
  const url = `${API_BASE_URL}/api/v1/ai/social-import/jobs/${jobId}/events${suffix}`

  const connect = async () => {
    try {
      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'text/event-stream',
        },
        signal: controller.signal,
      })

      if (!response.ok) {
        throw new Error(`SSE connection failed: ${response.status}`)
      }

      const reader = response.body?.getReader()
      if (!reader) {
        throw new Error('No SSE response body')
      }

      const decoder = new TextDecoder()
      let buffer = ''
      let currentEvent = ''
      let currentEventId = ''
      let dataLines: string[] = []
      let sawTerminalEvent = false
      const terminalEvents: ReadonlySet<SocialImportSSEEvent['type']> = new Set([
        'job_completed',
        'job_failed',
        'job_cancelled',
      ])

      const dispatch = () => {
        if (!currentEvent && dataLines.length === 0) return

        const payload = dataLines.join('\n')
        const type = currentEvent || 'message'
        if (terminalEvents.has(type as SocialImportSSEEvent['type'])) {
          sawTerminalEvent = true
        }

        try {
          const parsed = payload ? JSON.parse(payload) : null
          onMessage({
            type: type as SocialImportSSEEvent['type'],
            data: parsed,
            id: currentEventId ? Number(currentEventId) : undefined,
          })
        } catch {
          onMessage({
            type: type as SocialImportSSEEvent['type'],
            data: payload,
            id: currentEventId ? Number(currentEventId) : undefined,
          })
        }

        currentEvent = ''
        currentEventId = ''
        dataLines = []
      }

      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        buffer += decoder.decode(value, { stream: true })
        const lines = buffer.split('\n')
        buffer = lines.pop() || ''

        for (const rawLine of lines) {
          const line = rawLine.replace(/\r$/, '')

          if (line.startsWith('event:')) {
            currentEvent = line.slice(6).trim()
            continue
          }

          if (line.startsWith('id:')) {
            currentEventId = line.slice(3).trim()
            continue
          }

          if (line.startsWith('data:')) {
            dataLines.push(line.slice(5).trimStart())
            continue
          }

          if (line === '') {
            dispatch()
          }
        }
      }

      dispatch()
      if (!controller.signal.aborted && !sawTerminalEvent) {
        throw new Error('Social import live updates disconnected unexpectedly')
      }
    } catch (error) {
      if ((error as Error).name !== 'AbortError') {
        onError?.(error as Error)
      }
    }
  }

  connect()

  return () => {
    controller.abort()
  }
}
