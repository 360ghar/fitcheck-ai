import { STORAGE_KEYS } from '@/shared/lib/constants'

/**
 * Token storage for the admin app. Mirrors the main frontend convention
 * (frontend/src/lib/auth.ts): tokens live in localStorage, keyed per app.
 * The API client reads them here — the session store never holds tokens in
 * memory, so a page reload cannot desync the two.
 */

export interface AuthTokens {
  access_token: string
  refresh_token: string
}

export function getTokens(): AuthTokens | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEYS.tokens)
    if (!raw) return null
    const parsed: unknown = JSON.parse(raw)
    if (
      typeof parsed === 'object' &&
      parsed !== null &&
      'access_token' in parsed &&
      'refresh_token' in parsed &&
      typeof (parsed as AuthTokens).access_token === 'string' &&
      typeof (parsed as AuthTokens).refresh_token === 'string'
    ) {
      return parsed as AuthTokens
    }
    return null
  } catch {
    return null
  }
}

export function setTokens(tokens: AuthTokens): void {
  localStorage.setItem(STORAGE_KEYS.tokens, JSON.stringify(tokens))
}

export function clearTokens(): void {
  localStorage.removeItem(STORAGE_KEYS.tokens)
}
