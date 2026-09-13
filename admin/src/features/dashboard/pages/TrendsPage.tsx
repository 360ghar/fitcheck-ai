import { Navigate, useSearchParams } from 'react-router-dom'

/**
 * Legacy trends route — single-page dashboard now owns daily trends.
 * Redirects to /dashboard?section=trends preserving ?days (7/15/30/90) so
 * the Trends section's Tabs keep the selected window. Never renders charts
 * itself; DashboardPage is the single source of truth (build-time flag path).
 */
export function TrendsPage() {
  const [searchParams] = useSearchParams()
  const days = searchParams.get('days')

  const next = new URLSearchParams()
  // Preserve valid ?days=7/15/30/90 for the dashboard Trends section.
  if (days && ['7', '15', '30', '90'].includes(days)) next.set('days', days)
  next.set('section', 'trends')

  return <Navigate to={`/dashboard?${next.toString()}`} replace />
}
