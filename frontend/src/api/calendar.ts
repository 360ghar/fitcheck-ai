/**
 * Calendar API endpoints
 */

import { apiClient, getApiError } from './client'
import type { ApiEnvelope } from '../types'

export interface CalendarConnection {
  id: string
  provider: string
  email?: string | null
  connected_at: string
}

export interface CalendarEvent {
  id: string
  calendar_id?: string | null
  title: string
  description?: string | null
  start_time: string
  end_time: string
  location?: string | null
  outfit_id?: string | null
}

export interface CalendarEventOutfitUpdate {
  id: string
  outfit_id: string | null
  updated_at: string
}

export async function connectCalendar(provider: string, auth_code?: string): Promise<CalendarConnection> {
  try {
    const response = await apiClient.post<ApiEnvelope<CalendarConnection>>('/api/v1/calendar/connect', {
      provider,
      auth_code,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function getCalendarEvents(params?: {
  start_date?: string
  end_date?: string
}): Promise<CalendarEvent[]> {
  try {
    const qs = new URLSearchParams()
    if (params?.start_date) qs.append('start_date', params.start_date)
    if (params?.end_date) qs.append('end_date', params.end_date)

    const response = await apiClient.get<ApiEnvelope<{ events: CalendarEvent[] }>>(
      `/api/v1/calendar/events${qs.toString() ? `?${qs.toString()}` : ''}`
    )
    return response.data.data.events
  } catch (error) {
    throw getApiError(error)
  }
}

export async function createCalendarEvent(data: {
  title: string
  description?: string
  start_time: string
  end_time: string
  location?: string
  calendar_id?: string
}): Promise<CalendarEvent> {
  try {
    const response = await apiClient.post<ApiEnvelope<CalendarEvent>>('/api/v1/calendar/events', data)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function assignOutfitToEvent(eventId: string, outfitId: string): Promise<CalendarEventOutfitUpdate> {
  try {
    const response = await apiClient.post<ApiEnvelope<CalendarEventOutfitUpdate>>(`/api/v1/calendar/events/${eventId}/outfit`, {
      outfit_id: outfitId,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function removeOutfitFromEvent(eventId: string): Promise<CalendarEventOutfitUpdate> {
  try {
    const response = await apiClient.delete<ApiEnvelope<CalendarEventOutfitUpdate>>(`/api/v1/calendar/events/${eventId}/outfit`)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}
