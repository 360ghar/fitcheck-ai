/**
 * User-facing error message for starting a batch extraction job.
 *
 * The backend logs the diagnostic detail (which DB RPC / migration is
 * missing, provider failures) server-side; clients must never render raw
 * backend error bodies ("Request failed with status code 503", "AI quota
 * reservation is unavailable: ...", SQL migration paths). This helper maps
 * the error's machine fields (code / status / errorKind) to friendly,
 * stable copy instead.
 */
import { getApiError, isAxiosLike } from '@/lib/errors';

export const BATCH_START_ERROR_FALLBACK = 'Failed to start extraction. Please try again.'
export const BATCH_START_ERROR_NETWORK =
  "We couldn't reach our servers. Check your connection and try again."
export const BATCH_START_ERROR_SERVICE =
  'Something went wrong while starting extraction. Please try again shortly.'

export function getBatchExtractionErrorMessage(error: unknown): string {
  if (!error) return BATCH_START_ERROR_FALLBACK

  const apiError = getApiError(error)

  // Transport-level failure: an HTTP error with no response (network down,
  // timeout, CORS). Plain Errors (local failures) are not network errors.
  if (isAxiosLike(error) && apiError.status === undefined) {
    return BATCH_START_ERROR_NETWORK
  }

  // 5xx / AI_SERVICE_ERROR / provider capacity (upstream_quota|transient)
  // are "on us" — friendly retry copy, never the backend's raw explanation.
  if (
    apiError.status !== undefined &&
    apiError.status >= 500
  ) {
    return BATCH_START_ERROR_SERVICE
  }
  if (
    apiError.code === 'AI_SERVICE_ERROR' ||
    apiError.errorKind === 'upstream_quota' ||
    apiError.errorKind === 'transient'
  ) {
    return BATCH_START_ERROR_SERVICE
  }

  return BATCH_START_ERROR_FALLBACK
}
