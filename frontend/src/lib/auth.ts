/**
 * Auth/token plumbing shared by the API client, stores, and pages.
 *
 * Kept separate from api/client.ts so the HTTP transport layer owns retries
 * and interceptors only, while auth flow decisions (token CRUD, forced
 * logout redirects) live in a single, testable module.
 */

const TOKEN_STORAGE_KEY = 'fitcheck_auth_tokens';
const AUTH_STORAGE_KEY = 'fitcheck-auth-storage';
const USER_STORAGE_KEY = 'fitcheck_user';

export { TOKEN_STORAGE_KEY, AUTH_STORAGE_KEY, USER_STORAGE_KEY };

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
}

export interface PersistedAuth {
  state?: {
    tokens?: AuthTokens;
    isAuthenticated?: boolean;
  };
}

let hasForcedLogout = false;

export function forceLogout(): void {
  if (hasForcedLogout) return;
  hasForcedLogout = true;
  clearTokens();
  localStorage.removeItem(AUTH_STORAGE_KEY);
  localStorage.removeItem(USER_STORAGE_KEY);
  if (typeof window !== 'undefined') {
    // Preserve the current path as returnTo so a re-login returns the user to
    // where they were instead of dumping them on the dashboard. Guard against
    // /auth/* paths (e.g. a 401 on the OAuth callback) to avoid a redirect loop.
    const currentPath = window.location.pathname + window.location.search;
    const isAuthPage = currentPath.startsWith('/auth/');
    if (!isAuthPage && currentPath && currentPath !== '/') {
      window.location.href = `/auth/login?returnTo=${encodeURIComponent(currentPath)}`;
    } else {
      window.location.href = '/auth/login';
    }
  }
}

export function resetForcedLogoutFlag(): void {
  hasForcedLogout = false;
}

export function getTokens(): AuthTokens | null {
  try {
    const stored = localStorage.getItem(TOKEN_STORAGE_KEY);
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
}

export function setTokens(tokens: AuthTokens): void {
  localStorage.setItem(TOKEN_STORAGE_KEY, JSON.stringify(tokens));
  syncPersistedTokens(tokens);
}

export function clearTokens(): void {
  localStorage.removeItem(TOKEN_STORAGE_KEY);
  localStorage.removeItem(AUTH_STORAGE_KEY);
  localStorage.removeItem(USER_STORAGE_KEY);
}

export function getAccessToken(): string | null {
  return getTokens()?.access_token || null;
}

export function isAuthenticated(): boolean {
  return Boolean(getAccessToken());
}

export function syncPersistedTokens(tokens: AuthTokens): void {
  // Keep Zustand persist in sync so rehydrate does not restore stale tokens.
  try {
    const raw = localStorage.getItem(AUTH_STORAGE_KEY);
    if (!raw) return;
    const parsed = JSON.parse(raw) as PersistedAuth;
    if (!parsed.state) return;
    parsed.state.tokens = tokens;
    parsed.state.isAuthenticated = true;
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(parsed));
  } catch {
    // Non-fatal: request-path tokens are already updated via setTokens.
  }
}

export function storeUser(user: unknown): void {
  try {
    localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(user));
  } catch {
    // Non-fatal; user will be refetched on next route load.
  }
}

export function clearUser(): void {
  localStorage.removeItem(USER_STORAGE_KEY);
}

export { hasForcedLogout };

export function isTokenExpired(jwt: string): boolean {
  try {
    const b64 = jwt.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = b64.padEnd(b64.length + ((4 - (b64.length % 4)) % 4), '=');
    const payload = JSON.parse(atob(padded));
    return typeof payload.exp === 'number' && payload.exp * 1000 < Date.now() + 30_000;
  } catch {
    return false;
  }
}
