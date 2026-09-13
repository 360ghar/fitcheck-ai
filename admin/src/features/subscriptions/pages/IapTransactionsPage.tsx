import { Navigate, useSearchParams } from 'react-router-dom'

/**
 * IAP transactions — consolidated into SubscriptionsPage single table.
 * This route now redirects to /subscriptions?provider=<platform> to avoid
 * duplicate commerce surfaces. Provider param drives the billing_provider filter.
 */
export function IapTransactionsPage() {
  const [searchParams] = useSearchParams()
  // Map legacy `platform` query param to the new `provider` param. When no
  // recognized platform is requested, keep the unfiltered view (all
  // providers) instead of hiding every non-Apple transaction.
  const platform = searchParams.get('platform')

  const params = new URLSearchParams(searchParams)
  params.delete('platform')
  if (platform === 'apple' || platform === 'google') {
    params.set('provider', platform)
  }

  return <Navigate to={`/subscriptions?${params.toString()}`} replace />
}
