import { Navigate, useLocation } from 'react-router-dom'
import { SeoPageLayout } from '@/components/seo/SeoPageLayout'
import { getIntentPageByPath } from '@/components/seo/content/intent-pages'

/** Renders any mapped intent SEO page based on current pathname. */
export default function IntentSeoPage() {
  const { pathname } = useLocation()
  const content = getIntentPageByPath(pathname)

  if (!content) {
    return <Navigate to="/" replace />
  }

  return <SeoPageLayout content={content} />
}
