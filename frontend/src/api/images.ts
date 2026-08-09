/**
 * Images API endpoints
 */

import { apiClient, getApiError } from './client';
import type { ApiEnvelope } from '../types';

// ============================================================================
// IMAGE SERVING
// ============================================================================

/**
 * Mint a fresh client-fetchable URL for a caller-owned storage object.
 *
 * Presigned URLs are short-lived (OBJECT_STORAGE_PRESIGN_TTL); a URL that was
 * minted at generation time can expire before the user looks at the result.
 * This is the re-mint path: given the durable `storage_path` from a
 * try-on/outfit response, get a URL that is fetchable right now. Server-side
 * it is scoped to the caller's own objects (another user's key 404s).
 */
export async function getPresignedUrl(storagePath: string): Promise<string> {
  try {
    const response = await apiClient.get<ApiEnvelope<{ url: string; storage_path: string }>>(
      `/api/v1/images/presigned?storage_path=${encodeURIComponent(storagePath)}`
    );
    return response.data.data.url;
  } catch (error) {
    throw getApiError(error);
  }
}
