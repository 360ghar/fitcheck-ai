import { FeaturePageTemplate } from '@/components/landing/FeaturePageTemplate'
import { featurePages } from './featurePageContent'

export default function OutfitRecommendationsPage() {
  return <FeaturePageTemplate {...featurePages.recommendations} />
}
