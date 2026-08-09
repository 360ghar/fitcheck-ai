/**
 * Keep the session-cached user's avatar URL fresh.
 *
 * `users.avatar_url` is a presigned URL that expires after the backend's
 * `OBJECT_STORAGE_PRESIGN_TTL` (1h). The auth store fetches the user once at
 * rehydration, so a long session renders a dead avatar unless something
 * re-reads `/users/me` (which re-materializes a fresh URL server-side).
 *
 * This hook lives in the authenticated shell (AppLayout) and re-reads the
 * user on four triggers:
 *   1. mount — and every route change (all coalesced through the request
 *      cache, so route hops inside the 30s freshness window are cache hits);
 *   2. the tab becoming visible again (a long-idle session's URL may have
 *      expired while the user was away);
 *   3. a low-frequency poll that only fires once the last refresh approaches
 *      the 1h presign TTL — guarantees the URL never stays expired on a
 *      single idle page.
 *
 * Failures are silent at the store level (the stale URL is cosmetic; the
 * next trigger retries).
 */
import { useCallback, useEffect, useRef } from 'react';
import { useLocation } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';

/** Avatar presigned URLs live for OBJECT_STORAGE_PRESIGN_TTL (1h); refresh before expiry. */
const PRESIGN_TTL_GUARD_MS = 50 * 60 * 1000;
/** Idle poll cadence; a network request only fires when the guard above has elapsed. */
const IDLE_POLL_MS = 5 * 60 * 1000;

export function useUserRefresh(): void {
  const refreshUser = useAuthStore((s) => s.refreshUser);
  const location = useLocation();
  const lastRefreshedAtRef = useRef(0);

  const refresh = useCallback(() => {
    lastRefreshedAtRef.current = Date.now();
    void refreshUser();
  }, [refreshUser]);

  // Mount + every route change.
  useEffect(() => {
    refresh();
  }, [location.pathname, refresh]);

  // Returning to a long-idle tab: the cached presigned URL may have expired
  // while the user was away.
  useEffect(() => {
    const onVisibility = () => {
      if (!document.hidden) refresh();
    };
    document.addEventListener('visibilitychange', onVisibility);
    return () => document.removeEventListener('visibilitychange', onVisibility);
  }, [refresh]);

  // Idle same-page sessions: poll cheaply, request only near the TTL.
  useEffect(() => {
    const id = window.setInterval(() => {
      if (Date.now() - lastRefreshedAtRef.current >= PRESIGN_TTL_GUARD_MS) {
        refresh();
      }
    }, IDLE_POLL_MS);
    return () => window.clearInterval(id);
  }, [refresh]);
}
