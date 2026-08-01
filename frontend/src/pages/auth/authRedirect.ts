export const PENDING_AUTH_RETURN_TO_KEY = 'pending_auth_return_to'

/** Keep post-auth redirects inside the current application. */
export function getSafeReturnTo(value: string | null | undefined): string | undefined {
  if (!value || !value.startsWith('/') || value.startsWith('//') || value.includes('\\')) {
    return undefined
  }

  try {
    const url = new URL(value, window.location.origin)
    if (url.origin !== window.location.origin) return undefined
    return `${url.pathname}${url.search}${url.hash}`
  } catch {
    return undefined
  }
}

export function getPostAuthDestination(
  returnTo: string | null | undefined,
  planType?: string | null,
  promoCode?: string | null,
): string {
  const safeReturnTo = getSafeReturnTo(returnTo)
  if (safeReturnTo) return safeReturnTo
  // A promo code from a shared campaign URL lands the user on the plan page
  // where the code is pre-filled and validated (redemption is one tap).
  if (promoCode) return '/profile?tab=plan'
  return planType
    ? `/profile?tab=plan&plan_type=${encodeURIComponent(planType)}`
    : '/dashboard'
}

export function persistAuthReturnTo(returnTo: string | null | undefined): void {
  const safeReturnTo = getSafeReturnTo(returnTo)
  if (safeReturnTo) {
    localStorage.setItem(PENDING_AUTH_RETURN_TO_KEY, safeReturnTo)
  } else {
    localStorage.removeItem(PENDING_AUTH_RETURN_TO_KEY)
  }
}

export function consumeAuthReturnTo(): string | undefined {
  const returnTo = getSafeReturnTo(localStorage.getItem(PENDING_AUTH_RETURN_TO_KEY))
  localStorage.removeItem(PENDING_AUTH_RETURN_TO_KEY)
  return returnTo
}

export function withAuthContext(path: string, planType?: string | null, returnTo?: string | null): string {
  const params = new URLSearchParams()
  if (planType) params.set('plan_type', planType)
  const safeReturnTo = getSafeReturnTo(returnTo)
  if (safeReturnTo) params.set('returnTo', safeReturnTo)
  const query = params.toString()
  return query ? `${path}?${query}` : path
}
