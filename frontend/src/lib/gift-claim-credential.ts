const CREDENTIAL_TTL_MS = 7 * 24 * 60 * 60 * 1_000
const STORAGE_VERSION = 1
const GIFT_PATH_PATTERN = /^\/gift\/([0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})\/?$/i
const CLAIM_SECRET_PATTERN = /^[A-Za-z0-9_-]{32,160}$/

interface StoredCredential {
  version: typeof STORAGE_VERSION
  value: string
  savedAt: number
}

const memoryCredentials = new Map<string, StoredCredential>()

function credentialKey(publicId: string): string {
  return `fitcheck_gift_claim:${publicId}`
}

function isFresh(stored: StoredCredential): boolean {
  return (
    stored.version === STORAGE_VERSION &&
    CLAIM_SECRET_PATTERN.test(stored.value) &&
    Date.now() - stored.savedAt <= CREDENTIAL_TTL_MS
  )
}

export function readGiftClaimCredential(publicId: string): string {
  const memoryValue = memoryCredentials.get(publicId)
  if (memoryValue) {
    if (isFresh(memoryValue)) return memoryValue.value
    memoryCredentials.delete(publicId)
  }

  try {
    const raw = localStorage.getItem(credentialKey(publicId))
    if (!raw) return ''
    const stored = JSON.parse(raw) as StoredCredential
    if (!isFresh(stored)) {
      localStorage.removeItem(credentialKey(publicId))
      return ''
    }
    memoryCredentials.set(publicId, stored)
    return stored.value
  } catch {
    return ''
  }
}

export function captureGiftClaimCredentialFromLocation(): {
  publicId: string
  credential: string
} | null {
  if (typeof window === 'undefined') return null
  const match = window.location.pathname.match(GIFT_PATH_PATTERN)
  if (!match) return null
  const publicId = match[1]
  const fromHash = new URLSearchParams(window.location.hash.slice(1)).get('claim')
  if (fromHash === null) return null

  window.history.replaceState(
    null,
    document.title,
    `${window.location.pathname}${window.location.search}`,
  )

  if (!CLAIM_SECRET_PATTERN.test(fromHash)) {
    return { publicId, credential: '' }
  }

  const stored: StoredCredential = {
    version: STORAGE_VERSION,
    value: fromHash,
    savedAt: Date.now(),
  }
  memoryCredentials.set(publicId, stored)
  try {
    localStorage.setItem(credentialKey(publicId), JSON.stringify(stored))
  } catch {
    // The in-memory copy keeps the current page usable in private browsing modes.
  }
  return { publicId, credential: fromHash }
}

export function forgetGiftClaimCredential(publicId: string): void {
  memoryCredentials.delete(publicId)
  try {
    localStorage.removeItem(credentialKey(publicId))
  } catch {
    // No cleanup is possible when browser storage is disabled.
  }
}
