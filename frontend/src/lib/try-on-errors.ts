/**
 * User-facing failure copy for try-on generation.
 *
 * The backend logs the diagnostic detail (which DB RPC / migration is
 * missing, provider internals); the UI must show stable copy and never a
 * raw Axios message like "Request failed with status code 429". Matches
 * the interceptor's categories so inline copy and the global toast/upgrade
 * prompt never contradict each other.
 */
import { getApiError, isAxiosLike, RATE_LIMIT_EXCEEDED } from '@/lib/errors';

export function getTryOnErrorMessage(error: unknown): string {
  const apiError = getApiError(error);
  // The user's own plan limit — the global interceptor opens the upgrade
  // prompt for this; the inline copy just states the wall.
  if (apiError.code === RATE_LIMIT_EXCEEDED) {
    return 'You have reached today’s try-on limit. Please upgrade or try again tomorrow.';
  }
  if (apiError.code === 'AVATAR_REQUIRED') {
    return 'Please add a clear photo of you first.';
  }
  // Upstream AI capacity/provider failures are "on us" — retry, never upgrade.
  if (apiError.errorKind === 'upstream_quota' || apiError.errorKind === 'transient') {
    return 'Our AI service is busy. Please try again in a few minutes.';
  }
  // Transport-level failure (network down, timeout, CORS): an HTTP error with
  // no response. Plain local Errors are NOT network errors.
  if (isAxiosLike(error) && apiError.status === undefined) {
    return 'We couldn’t reach our servers. Check your connection and try again.';
  }
  return 'Couldn’t generate your try-on. Please try again.';
}
