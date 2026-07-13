import { Helmet } from 'react-helmet-async'
import { SEO_CONFIG } from './seo-config'

function JsonLdScript({ schema }: { schema: Record<string, unknown> }) {
  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

export function OrganizationJsonLd() {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'FitCheck AI',
    url: SEO_CONFIG.siteUrl,
    logo: `${SEO_CONFIG.siteUrl}/og-default.jpg`,
    description: SEO_CONFIG.positioning,
    sameAs: [
      'https://twitter.com/fitcheckai',
      'https://instagram.com/fitcheckai',
      'https://linkedin.com/company/fitcheckai',
    ],
    contactPoint: {
      '@type': 'ContactPoint',
      contactType: 'Customer Support',
      email: 'support@fitcheckaiapp.com',
      availableLanguage: ['English'],
    },
  }

  return <JsonLdScript schema={schema} />
}

export function SoftwareApplicationJsonLd() {
  const schema = {
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

  return <JsonLdScript schema={schema} />
}

export function WebSiteJsonLd() {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'FitCheck AI',
    url: SEO_CONFIG.siteUrl,
    description: SEO_CONFIG.positioning,
  }

  return <JsonLdScript schema={schema} />
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
