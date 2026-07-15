import { Helmet } from 'react-helmet-async'
import { SEO_CONFIG } from './seo-config'

interface SEOProps {
  title?: string
  description?: string
  ogImage?: string
  ogType?: 'website' | 'article'
  canonicalUrl?: string
  noIndex?: boolean
  jsonLd?: object | object[]
  keywords?: string
  children?: React.ReactNode
}

export function SEO({
  title,
  description,
  ogImage,
  ogType = 'website',
  canonicalUrl,
  noIndex = false,
  jsonLd,
  keywords,
  children,
}: SEOProps) {
  const pageTitle = title || SEO_CONFIG.defaultTitle
  const pageDescription = description || SEO_CONFIG.defaultDescription
  const pageImage = ogImage || SEO_CONFIG.defaultOgImage
  const pageUrl =
    canonicalUrl ||
    (typeof window !== 'undefined' ? window.location.href : SEO_CONFIG.siteUrl)

  const jsonLdBlocks = jsonLd
    ? Array.isArray(jsonLd)
      ? jsonLd
      : [jsonLd]
    : []

  return (
    <Helmet>
      <title>{pageTitle}</title>
      <meta name="title" content={pageTitle} />
      <meta name="description" content={pageDescription} />
      {keywords && <meta name="keywords" content={keywords} />}
      {noIndex ? (
        <meta name="robots" content="noindex, nofollow" />
      ) : (
        <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
      )}
      {canonicalUrl && <link rel="canonical" href={canonicalUrl} />}

      <meta property="og:type" content={ogType} />
      <meta property="og:url" content={pageUrl} />
      <meta property="og:title" content={pageTitle} />
      <meta property="og:description" content={pageDescription} />
      <meta property="og:image" content={pageImage} />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="630" />
      <meta property="og:site_name" content={SEO_CONFIG.siteName} />
      <meta property="og:locale" content={SEO_CONFIG.locale} />

      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:url" content={pageUrl} />
      <meta name="twitter:title" content={pageTitle} />
      <meta name="twitter:description" content={pageDescription} />
      <meta name="twitter:image" content={pageImage} />
      {SEO_CONFIG.twitterHandle && (
        <meta name="twitter:site" content={SEO_CONFIG.twitterHandle} />
      )}

      {jsonLdBlocks.map((block) => {
        const json = JSON.stringify(block)
        return (
          <script key={json} type="application/ld+json">
            {json}
          </script>
        )
      })}

      {children}
    </Helmet>
  )
}

export default SEO
