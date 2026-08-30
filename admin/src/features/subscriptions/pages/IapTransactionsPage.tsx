import { Navigate, useSearchParams } from 'react-router-dom'

/**
 * IAP transactions — consolidated into SubscriptionsPage single table.
 * This route now redirects to /subscriptions?provider=<platform> to avoid
 * duplicate commerce surfaces. Provider param drives the billing_provider filter.
 */
export function IapTransactionsPage() {
  const [searchParams] = useSearchParams()
  // Map legacy `platform` query param to the new `provider` param.
  // Default to apple so the redirect lands on a store view.
  const platform = searchParams.get('platform')
  const status = searchParams.get('status')
  const provider =
    platform === 'google' ? 'google' : platform === 'apple' ? 'apple' : 'apple'

  const params = new URLSearchParams()
  params.set('provider', provider)
  if (status) params.set('status', status)

  return <Navigate to={`/subscriptions?${params.toString()}`} replace />
}
