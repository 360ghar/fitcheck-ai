import { apiClient, getAccessToken, getApiError } from './client'
import { API_BASE_URL } from '@/lib/apiBaseUrl'
import { createSSEConnection, type SSEMessage } from '@/lib/sse'
import type { SocialImportJobData, SocialImportItem, SocialImportSSEEvent } from '@/types'

export { API_BASE_URL }

/** Social import terminal event names (note: `job_completed`, not `job_complete`). */
const SOCIAL_IMPORT_TERMINAL_EVENTS: ReadonlySet<string> = new Set([
  'job_completed',
  'job_failed',
  'job_cancelled',
])

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

export interface SocialImportOAuthConnectResponse {
  auth_url: string
  expires_in_seconds: number
  provider: string
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

export async function getSocialImportOAuthConnectUrl(
  jobId: string
): Promise<SocialImportOAuthConnectResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<SocialImportOAuthConnectResponse>>(
      `/api/v1/ai/social-import/jobs/${jobId}/auth/oauth/connect`
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
    provider_page_access_token?: string
    provider_page_id?: string
    provider_username?: string
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

export interface ApprovedSavedItem {
  id: string
  category?: string | null
}

export async function approveSocialImportPhoto(
  jobId: string,
  photoId: string
): Promise<ApprovedSavedItem[]> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ saved_items?: ApprovedSavedItem[] }>>(
      `/api/v1/ai/social-import/jobs/${jobId}/photos/${photoId}/approve`
    )
    return response.data.data?.saved_items ?? []
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
  const token = getAccessToken()
  if (!token) {
    // Historical behavior: fail the connection instead of streaming with no
    // credentials (the shared client never calls fetch in this case).
    onError?.(new Error('Authentication required to receive social import updates'))
    return () => {}
  }

  const search = new URLSearchParams()
  if (lastEventId !== undefined) {
    search.set('last_event_id', String(lastEventId))
  }
  const suffix = search.toString() ? `?${search.toString()}` : ''
  const url = `${API_BASE_URL}/api/v1/ai/social-import/jobs/${jobId}/events${suffix}`

  return createSSEConnection({
    url,
    // Runtime shape matches: { type, data, id? }. The cast bridges the shared
    // SSEMessage type (string union) to the narrower SocialImportSSEEvent.
    onMessage: onMessage as (message: SSEMessage) => void,
    onError,
    terminalEvents: SOCIAL_IMPORT_TERMINAL_EVENTS,
    headers: { Authorization: `Bearer ${token}` },
    onClose: (sawTerminal) => {
      // Preserve the historical "unexpected disconnect" error: a stream that
      // ends without a terminal event is treated as a failure here.
      if (!sawTerminal) {
        onError?.(new Error('Social import live updates disconnected unexpectedly'))
      }
    },
  })
}
