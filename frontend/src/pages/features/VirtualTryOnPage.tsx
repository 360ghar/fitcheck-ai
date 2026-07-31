import { FeaturePageTemplate } from '@/components/landing/FeaturePageTemplate'
import { featurePages } from './featurePageContent'

export default function VirtualTryOnPage() {
  return <FeaturePageTemplate {...featurePages.virtualTryOn} />
}
