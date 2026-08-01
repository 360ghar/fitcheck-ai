import { Helmet } from 'react-helmet-async'
import { SEO_CONFIG } from './seo-config'

function JsonLdScript({ schema }: { schema: Record<string, unknown> }) {
  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

const ORGANIZATION_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'FitCheck AI',
  url: SEO_CONFIG.siteUrl,
  logo: `${SEO_CONFIG.siteUrl}/og-default.jpg`,
  description: SEO_CONFIG.positioning,
  sameAs: [
    'https://play.google.com/store/apps/details?id=com.fitcheckaiapp.fitcheckai',
    'https://x.com/FitCheckAI',
    'https://www.linkedin.com/company/fitcheck-ai',
    'https://www.youtube.com/@FitCheckAI',
  ],
  contactPoint: {
    '@type': 'ContactPoint',
    contactType: 'Customer Support',
    email: 'info@fitcheckaiapp.com',
    availableLanguage: ['English'],
  },
}

export function OrganizationJsonLd() {
  return <JsonLdScript schema={ORGANIZATION_SCHEMA} />
}

const SOFTWARE_APPLICATION_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  name: 'FitCheck AI',
  applicationCategory: 'LifestyleApplication',
  operatingSystem: 'Web, iOS, Android',
  url: SEO_CONFIG.siteUrl,
  description: SEO_CONFIG.positioning,
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'USD',
    description: 'Free plan available with wardrobe limits and monthly AI generations',
  },
  featureList: [
    'AI-powered clothing detection from photos',
    'Virtual try-on with AI visualization',
    'AI photoshoot generator',
    'Weather-based outfit recommendations',
    'Wardrobe analytics and cost-per-wear tracking',
  ],
}

export function SoftwareApplicationJsonLd() {
  return <JsonLdScript schema={SOFTWARE_APPLICATION_SCHEMA} />
}

const WEBSITE_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'FitCheck AI',
  url: SEO_CONFIG.siteUrl,
  description: SEO_CONFIG.positioning,
  potentialAction: {
    '@type': 'SearchAction',
    target: {
      '@type': 'EntryPoint',
      urlTemplate: `${SEO_CONFIG.siteUrl}/blog?search={search_term_string}`,
    },
    'query-input': 'required name=search_term_string',
  },
}

export function WebSiteJsonLd() {
  return <JsonLdScript schema={WEBSITE_SCHEMA} />
}

interface OutfitJsonLdProps {
  name: string
  description?: string
  imageUrl?: string
  datePublished?: string
  tags?: string[]
}

export function OutfitJsonLd({
  name,
  description,
  imageUrl,
  datePublished,
  tags,
}: OutfitJsonLdProps) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: name,
    description: description || `Outfit: ${name}`,
    image: imageUrl || SEO_CONFIG.defaultOgImage,
    datePublished: datePublished || new Date().toISOString(),
    author: {
      '@type': 'Organization',
      name: 'FitCheck AI',
    },
    publisher: {
      '@type': 'Organization',
      name: 'FitCheck AI',
      logo: {
        '@type': 'ImageObject',
        url: SEO_CONFIG.defaultOgImage,
      },
    },
    keywords: tags?.join(', ') || 'outfit, fashion, style',
  }

  return <JsonLdScript schema={schema} />
}

interface BreadcrumbItem {
  name: string
  url: string
}

export function BreadcrumbJsonLd({ items }: { items: BreadcrumbItem[] }) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: item.url,
    })),
  }

  return <JsonLdScript schema={schema} />
}

export function HowToJsonLd(schema: Record<string, unknown>) {
  return <JsonLdScript schema={schema} />
}

export function FaqJsonLd({
  faqs,
}: {
  faqs: Array<{ question: string; answer: string }>
}) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((faq) => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  }

  return <JsonLdScript schema={schema} />
}

export function buildFaqSchema(faqs: Array<{ question: string; answer: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((faq) => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  }
}

export function buildHowToSchema({
  name,
  description,
  steps,
}: {
  name: string
  description: string
  steps: Array<{ name: string; text: string; url?: string }>
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name,
    description,
    step: steps.map((step, index) => ({
      '@type': 'HowToStep',
      position: index + 1,
      name: step.name,
      text: step.text,
      ...(step.url ? { url: step.url } : {}),
    })),
  }
}

export function buildFeatureItemListSchema(
  items: Array<{ name: string; url: string; description?: string }>
) {
  return {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    name: 'FitCheck AI core features',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      url: item.url,
      ...(item.description ? { description: item.description } : {}),
    })),
  }
}

/**
 * speakable — for voice assistants / answer engines. The cssSelectors must
 * resolve on the rendered page (Add the ids to the markup you target).
 */
export function buildSpeakableSchema(cssSelectors: string[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    name: 'FitCheck AI',
    url: SEO_CONFIG.siteUrl,
    speakable: {
      '@type': 'SpeakableSpecification',
      cssSelector: cssSelectors,
    },
  }
}

export interface VideoObjectSchemaInput {
  name: string
  description: string
  contentUrl: string
  thumbnailUrl: string
  uploadDate: string
  duration?: string
}

/** VideoObject schema for the site-hosted promo video (see /public/video/promo.mp4). */
export function buildVideoObjectSchema({
  name,
  description,
  contentUrl,
  thumbnailUrl,
  uploadDate,
  duration,
}: VideoObjectSchemaInput) {
  return {
    '@context': 'https://schema.org',
    '@type': 'VideoObject',
    name,
    description,
    contentUrl,
    thumbnailUrl,
    uploadDate,
    ...(duration ? { duration } : {}),
  }
}

/**
 * Article schema with a named Person author + optional speakable — stronger
 * E-E-A-T and answer-engine signals than an anonymous Organization author.
 */
export function buildArticleSchema({
  headline,
  description,
  authorName,
  datePublished,
  dateModified,
  image,
  keywords,
  section,
  url,
  speakableSelectors,
}: {
  headline: string
  description?: string
  authorName: string
  datePublished: string
  dateModified?: string
  image?: string
  keywords?: string[]
  section?: string
  url: string
  speakableSelectors?: string[]
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline,
    description: description || headline,
    author: { '@type': 'Person', name: authorName },
    publisher: {
      '@type': 'Organization',
      name: 'FitCheck AI',
      logo: {
        '@type': 'ImageObject',
        url: `${SEO_CONFIG.siteUrl}/og-default.jpg`,
      },
    },
    datePublished,
    dateModified: dateModified || datePublished,
    mainEntityOfPage: url,
    image: image || `${SEO_CONFIG.siteUrl}/og-default.jpg`,
    ...(keywords?.length ? { keywords: keywords.join(', ') } : {}),
    ...(section ? { articleSection: section } : {}),
    ...(speakableSelectors?.length
      ? { speakable: { '@type': 'SpeakableSpecification', cssSelector: speakableSelectors } }
      : {}),
  }
}
