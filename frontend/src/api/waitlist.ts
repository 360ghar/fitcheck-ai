/**
 * Waitlist API endpoints
 */

import { apiClient, getApiError } from './client';
import type { ApiEnvelope } from '../types';

// ============================================================================
// TYPES
// ============================================================================

export interface WaitlistJoinRequest {
  email: string;
  full_name?: string;
}

export interface WaitlistJoinResponse {
  id: string;
  email: string;
  full_name?: string;
  created_at: string;
}

// ============================================================================
// API FUNCTIONS
// ============================================================================

/**
 * Join the mobile app waitlist
 */
export async function joinWaitlist(
  data: WaitlistJoinRequest
): Promise<WaitlistJoinResponse> {
  try {
    const response = await apiClient.post<
      ApiEnvelope<WaitlistJoinResponse>
    >('/api/v1/waitlist/join', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}
