import { useParams, Link, Navigate } from 'react-router-dom'
import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd } from '@/components/seo/JsonLd'
import { Calendar, Clock, ArrowLeft, User, ArrowRight, Loader2 } from 'lucide-react'
import { useBlogPost, useBlogPosts } from '@/hooks/useBlog'

export default function BlogPostPage() {
  const { slug } = useParams<{ slug: string }>()

  const { data: post, isLoading, error } = useBlogPost(slug)

  // Fetch related posts (same category, excluding current)
  const { data: relatedPostsData } = useBlogPosts(
    1,
    4,
    post?.category,
    undefined,
    { enabled: !!post }
  )

  const relatedPosts = relatedPostsData?.posts
    ?.filter(p => p.slug !== post?.slug)
    ?.slice(0, 3) || []

  if (isLoading) {
    return (
      <div className="min-h-screen pt-32 flex justify-center">
        <Loader2 className="w-10 h-10 animate-spin text-indigo-600" />
      </div>
    )
  }

  if (error || !post) {
    return <Navigate to="/blog" replace />
  }

  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'Blog', url: 'https://fitcheckaiapp.com/blog' },
    { name: post.title, url: `https://fitcheckaiapp.com/blog/${post.slug}` }
  ]

  // Generate Article schema
  const articleSchema = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    author: {
      '@type': 'Organization',
      name: post.author
    },
    publisher: {
      '@type': 'Organization',
      name: 'FitCheck AI',
      logo: {
        '@type': 'ImageObject',
        url: 'https://fitcheckaiapp.com/og-default.svg'
      }
    },
    datePublished: new Date(post.date).toISOString(),
    dateModified: new Date(post.updated_at || post.date).toISOString(),
    keywords: post.keywords.join(', '),
    articleSection: post.category
  }

  return (
    <>
      <SEO
        title={`${post.title} | FitCheck AI Blog`}
        description={post.excerpt}
        canonicalUrl={`https://fitcheckaiapp.com/blog/${post.slug}`}
        ogType="article"
        jsonLd={articleSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="py-12 md:py-20 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              {/* Back Link */}
              <Link
                to="/blog"
                className="inline-flex items-center text-sm text-gray-600 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 mb-6 transition-colors"
              >
                <ArrowLeft className="w-4 h-4 mr-1" />
                Back to Blog
              </Link>

              {/* Category */}
              <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                {post.category}
              </Badge>

              {/* Title */}
              <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-6">
                {post.title}
              </h1>

              {/* Meta */}
              <div className="flex flex-wrap items-center gap-6 text-sm text-gray-600 dark:text-gray-400">
                <span className="flex items-center">
                  <User className="w-4 h-4 mr-2" />
                  {post.author}
                  {post.author_title && (
                    <span className="text-gray-400 dark:text-gray-500 ml-1">
                      — {post.author_title}
                    </span>
                  )}
                </span>
                <span className="flex items-center">
                  <Calendar className="w-4 h-4 mr-2" />
                  {formatDate(post.date)}
                </span>
                <span className="flex items-center">
                  <Clock className="w-4 h-4 mr-2" />
                  {post.read_time}
                </span>
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Featured Image */}
        <section className="pb-12 md:pb-16">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="aspect-[21/9] bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 rounded-2xl flex items-center justify-center shadow-xl overflow-hidden relative">
                {post.featured_image_url ? (
                  <img
                    src={post.featured_image_url}
                    alt={post.title}
                    className="absolute inset-0 w-full h-full object-cover"
                  />
                ) : (
                  <span className="text-8xl md:text-9xl">{post.emoji}</span>
                )}
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Content */}
        <section className="pb-16 md:pb-24">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <article className="prose prose-lg md:prose-xl dark:prose-invert max-w-none">
                {/* Render content as HTML-like structure */}
                {post.content.split('\n\n').map((paragraph, index) => {
                  const trimmed = paragraph.trim()

                  // Skip empty paragraphs
                  if (!trimmed) return null

                  // Handle headers
                  if (trimmed.startsWith('# ')) {
                    return (
                      <h1
                        key={index}
                        className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mt-12 mb-6"
                      >
                        {trimmed.replace('# ', '')}
                      </h1>
                    )
                  }
                  if (trimmed.startsWith('## ')) {
                    return (
                      <h2
                        key={index}
                        className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-white mt-10 mb-4"
                      >
                        {trimmed.replace('## ', '')}
                      </h2>
                    )
                  }
                  if (trimmed.startsWith('### ')) {
                    return (
                      <h3
                        key={index}
                        className="text-xl md:text-2xl font-bold text-gray-900 dark:text-white mt-8 mb-3"
                      >
                        {trimmed.replace('### ', '')}
                      </h3>
                    )
                  }

                  // Handle bullet lists
                  if (trimmed.startsWith('- ')) {
                    const items = trimmed.split('\n').filter(line => line.trim().startsWith('- '))
                    return (
                      <ul key={index} className="list-disc list-inside space-y-2 my-6 text-gray-700 dark:text-gray-300">
                        {items.map((item, i) => (
                          <li
                            key={i}
                            dangerouslySetInnerHTML={{
                              __html: formatInlineText(item.replace('- ', ''))
                            }}
                          />
                        ))}
                      </ul>
                    )
                  }

                  // Handle numbered lists
                  if (/^\d+\./.test(trimmed)) {
                    const items = trimmed.split('\n').filter(line => /^\d+\./.test(line.trim()))
                    return (
                      <ol key={index} className="list-decimal list-inside space-y-2 my-6 text-gray-700 dark:text-gray-300">
                        {items.map((item, i) => (
                          <li
                            key={i}
                            dangerouslySetInnerHTML={{
                              __html: formatInlineText(item.replace(/^\d+\.\s*/, ''))
                            }}
                          />
                        ))}
                      </ol>
                    )
                  }

                  // Regular paragraphs
                  return (
                    <p
                      key={index}
                      className="text-gray-700 dark:text-gray-300 mb-6 leading-relaxed"
                      dangerouslySetInnerHTML={{ __html: formatInlineText(trimmed) }}
                    />
                  )
                })}
              </article>

              {/* Keywords */}
              <div className="mt-12 pt-8 border-t border-gray-200 dark:border-gray-800">
                <h3 className="text-sm font-semibold text-gray-900 dark:text-white mb-3">
                  Related Topics
                </h3>
                <div className="flex flex-wrap gap-2">
                  {post.keywords.map((keyword) => (
                    <span
                      key={keyword}
                      className="px-3 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm"
                    >
                      {keyword}
                    </span>
                  ))}
                </div>
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Related Posts */}
        {relatedPosts.length > 0 && (
          <section className="py-16 md:py-24 bg-gray-50 dark:bg-gray-900">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <AnimatedSection>
                <h2 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-white mb-8">
                  Related Articles
                </h2>

                <div className="grid md:grid-cols-3 gap-6">
                  {relatedPosts.map((relatedPost) => (
                    <Link
                      key={relatedPost.slug}
                      to={`/blog/${relatedPost.slug}`}
                      className="group block"
                    >
                      <article className="bg-white dark:bg-gray-800 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                        <div className="aspect-video bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center overflow-hidden relative">
                          {relatedPost.featured_image_url ? (
                            <img
                              src={relatedPost.featured_image_url}
                              alt={relatedPost.title}
                              className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                            />
                          ) : (
                            <span className="text-4xl">{relatedPost.emoji}</span>
                          )}
                        </div>
                        <div className="p-4">
                          <span className="text-xs font-medium text-indigo-600 dark:text-indigo-400">
                            {relatedPost.category}
                          </span>
                          <h3 className="font-semibold text-gray-900 dark:text-white mt-1 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors line-clamp-2">
                            {relatedPost.title}
                          </h3>
                          <p className="text-sm text-gray-600 dark:text-gray-400 mt-2 line-clamp-2">
                            {relatedPost.excerpt}
                          </p>
                        </div>
                      </article>
                    </Link>
                  ))}
                </div>
              </AnimatedSection>
            </div>
          </section>
        )}

        {/* CTA Section */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-indigo-600 to-purple-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                Transform your wardrobe with AI
              </h2>
              <p className="text-xl text-indigo-100 mb-8">
                Join thousands organizing, planning, and optimizing their style
              </p>
              <Link
                to="/auth/register"
                className="inline-flex items-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-colors"
              >
                Start Free Today
                <ArrowRight className="w-5 h-5" />
              </Link>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}

// Helper function to format inline text (bold, links, etc.)
function formatInlineText(text: string): string {
  return text
    // Bold text: **text**
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    // Italic text: *text*
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    // Links: [text](url)
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-indigo-600 dark:text-indigo-400 hover:underline">$1</a>')
}

/**
 * Format ISO date string to display format
 */
function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}
