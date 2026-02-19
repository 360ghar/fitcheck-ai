import { Helmet } from 'react-helmet-async'
import { SEO_CONFIG } from './seo-config'

// Organization schema
export function OrganizationJsonLd() {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'FitCheck AI',
    url: SEO_CONFIG.siteUrl,
    logo: `${SEO_CONFIG.siteUrl}/og-default.svg`,
    description: SEO_CONFIG.defaultDescription,
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

// SoftwareApplication schema for the app
export function SoftwareApplicationJsonLd() {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'FitCheck AI',
    applicationCategory: 'LifestyleApplication',
    operatingSystem: 'Web',
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
    },
    description: SEO_CONFIG.defaultDescription,
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

// WebSite schema with search action
export function WebSiteJsonLd() {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'FitCheck AI',
    url: SEO_CONFIG.siteUrl,
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

// Article/Outfit schema for shared outfits
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
        url: `${SEO_CONFIG.siteUrl}/og-default.svg`,
      },
    },
    keywords: tags?.join(', ') || 'outfit, fashion, style',
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

// BreadcrumbList schema
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

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}

// HowTo schema for tutorials and step-by-step guides
export function HowToJsonLd(schema: Record<string, unknown>) {
  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(schema)}</script>
    </Helmet>
  )
}
