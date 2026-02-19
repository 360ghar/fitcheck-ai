import { Link } from 'react-router-dom'
import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { Calendar, Clock, ArrowRight, Loader2 } from 'lucide-react'
import { useBlogPosts, useBlogCategories } from '@/hooks/useBlog'
import { useState } from 'react'

export default function BlogIndexPage() {
  const [page] = useState(1)
  const [pageSize] = useState(12)

  const { data: postsData, isLoading: isLoadingPosts, error: postsError } = useBlogPosts(page, pageSize)
  const { data: categories, isLoading: isLoadingCategories } = useBlogCategories()

  const posts = postsData?.posts || []

  return (
    <>
      <SEO
        title="FitCheck AI Blog - Fashion Tips, AI Trends & Style Guides"
        description="Discover the latest in AI fashion technology, wardrobe organization tips, style guides, and outfit inspiration from FitCheck AI."
        canonicalUrl="https://fitcheckaiapp.com/blog"
      />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto">
                <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                  Blog
                </Badge>
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 dark:text-white mb-6">
                  Fashion, AI & Style Tips
                </h1>
                <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300 mb-8">
                  Discover how AI is transforming wardrobe management and get expert style advice
                </p>

                {/* Category Pills */}
                {!isLoadingCategories && categories && categories.length > 0 && (
                  <div className="flex flex-wrap justify-center gap-2">
                    {categories.map((category) => (
                      <Link
                        key={category}
                        to={`/blog/category/${category.toLowerCase().replace(/\s+/g, '-')}`}
                        className="px-4 py-2 bg-white dark:bg-gray-800 rounded-full text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-indigo-50 dark:hover:bg-indigo-900/30 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors border border-gray-200 dark:border-gray-700"
                      >
                        {category}
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Blog Posts Grid */}
        <section className="py-16 md:py-24 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            {isLoadingPosts ? (
              <div className="flex justify-center py-20">
                <Loader2 className="w-10 h-10 animate-spin text-indigo-600" />
              </div>
            ) : postsError ? (
              <div className="text-center py-20">
                <p className="text-gray-600 dark:text-gray-400">
                  Failed to load blog posts. Please try again later.
                </p>
              </div>
            ) : posts.length === 0 ? (
              <div className="text-center py-20">
                <p className="text-gray-600 dark:text-gray-400">
                  No blog posts yet. Check back soon!
                </p>
              </div>
            ) : (
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                {posts.map((post, index) => (
                  <AnimatedSection key={post.slug} delay={index * 100}>
                    <Link to={`/blog/${post.slug}`} className="group block h-full">
                      <article className="bg-gray-50 dark:bg-gray-900 rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition-all duration-300 h-full flex flex-col border border-gray-100 dark:border-gray-800">
                        {/* Image Placeholder */}
                        <div className="aspect-[16/9] bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 flex items-center justify-center relative overflow-hidden">
                          {post.featured_image_url ? (
                            <img
                              src={post.featured_image_url}
                              alt={post.title}
                              className="absolute inset-0 w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500"
                            />
                          ) : (
                            <>
                              <div className="absolute inset-0 bg-black/10 group-hover:bg-black/0 transition-colors" />
                              <span className="text-6xl md:text-7xl relative z-10 transform group-hover:scale-110 transition-transform duration-300">
                                {post.emoji}
                              </span>
                            </>
                          )}
                        </div>

                        <div className="p-6 flex-1 flex flex-col">
                          {/* Meta */}
                          <div className="flex items-center gap-3 mb-3 text-sm">
                            <span className="font-medium text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-2.5 py-1 rounded">
                              {post.category}
                            </span>
                            <span className="flex items-center text-gray-500 dark:text-gray-400">
                              <Clock className="w-3.5 h-3.5 mr-1" />
                              {post.read_time}
                            </span>
                          </div>

                          {/* Title */}
                          <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors line-clamp-2">
                            {post.title}
                          </h2>

                          {/* Excerpt */}
                          <p className="text-gray-600 dark:text-gray-400 text-sm flex-1 line-clamp-3 mb-4">
                            {post.excerpt}
                          </p>

                          {/* Footer */}
                          <div className="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-800">
                            <span className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                              <Calendar className="w-3.5 h-3.5 mr-1.5" />
                              {formatDate(post.date)}
                            </span>
                            <span className="text-sm font-medium text-indigo-600 dark:text-indigo-400 group-hover:underline flex items-center">
                              Read more
                              <ArrowRight className="w-4 h-4 ml-1 transform group-hover:translate-x-1 transition-transform" />
                            </span>
                          </div>
                        </div>
                      </article>
                    </Link>
                  </AnimatedSection>
                ))}
              </div>
            )}
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-indigo-600 to-purple-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                Ready to transform your wardrobe?
              </h2>
              <p className="text-xl text-indigo-100 mb-8">
                Join thousands using AI to organize, plan, and optimize their style
              </p>
              <Link
                to="/auth/register"
                className="inline-flex items-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-colors"
              >
                Get Started Free
                <ArrowRight className="w-5 h-5" />
              </Link>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
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
