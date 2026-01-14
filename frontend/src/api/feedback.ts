/**
 * Feedback API endpoints
 */

import { apiClient, getApiError } from './client'
import type { ApiEnvelope } from '../types'

export interface DeviceInfo {
  platform: string
  os_version?: string
  device_model?: string
  browser?: string
  screen_size?: string
}

export type TicketCategory = 'bug_report' | 'feature_request' | 'general_feedback' | 'support_request'
export type TicketStatus = 'open' | 'in_progress' | 'resolved' | 'closed'

export interface FeedbackResponse {
  id: string
  category: TicketCategory
  subject: string
  status: TicketStatus
  created_at: string
  message: string
}

export interface TicketListItem {
  id: string
  category: TicketCategory
  subject: string
  status: TicketStatus
  created_at: string
}

export interface TicketListResponse {
  tickets: TicketListItem[]
  total: number
}

/**
 * Submit feedback with optional attachments
 */
export async function submitFeedback(params: {
  category: TicketCategory
  subject: string
  description: string
  contactEmail?: string
  attachments?: File[]
  deviceInfo?: DeviceInfo
  appVersion?: string
}): Promise<FeedbackResponse> {
  try {
    const formData = new FormData()
    formData.append('category', params.category)
    formData.append('subject', params.subject)
    formData.append('description', params.description)

    if (params.contactEmail) {
      formData.append('contact_email', params.contactEmail)
    }

    if (params.deviceInfo) {
      formData.append('device_info', JSON.stringify(params.deviceInfo))
    }

    if (params.appVersion) {
      formData.append('app_version', params.appVersion)
    }

    formData.append('app_platform', 'web')

    if (params.attachments) {
      for (const file of params.attachments) {
        formData.append('attachments', file)
      }
    }

    const response = await apiClient.post<ApiEnvelope<FeedbackResponse>>(
      '/api/v1/feedback',
      formData,
      {
        headers: { 'Content-Type': 'multipart/form-data' },
      }
    )
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get current user's tickets
 */
export async function getMyTickets(
  limit: number = 20,
  offset: number = 0
): Promise<TicketListResponse> {
  try {
    const response = await apiClient.get<ApiEnvelope<TicketListResponse>>(
      '/api/v1/feedback/my-tickets',
      { params: { limit, offset } }
    )
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}
