import { useEffect, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { BlogImage } from '@/components/blog/BlogImage'
import SEO from '@/components/seo/SEO'
import { cn } from '@/lib/utils'
import { Calendar, Clock, ArrowRight } from 'lucide-react'
import { useBlogCategories } from '@/hooks/useBlog'
import { useInfiniteBlogPosts } from '@/hooks/useInfiniteBlogPosts'
import { InfiniteScrollSentinel } from '@/components/ui/infinite-scroll-sentinel'

export default function BlogIndexPage() {
  const { category } = useParams<{ category: string }>()
  const [searchParams, setSearchParams] = useSearchParams()
  const searchQuery = searchParams.get('search')?.trim() || ''
  const pageSize = 12
  const [searchValue, setSearchValue] = useState(searchQuery)

  useEffect(() => {
    setSearchValue(searchQuery)
  }, [searchQuery])

  const { data: categories, isLoading: isLoadingCategories, error: categoriesError } = useBlogCategories()
  const categoryFilter = category
    ? categories?.find((candidate) => slugifyCategory(candidate) === category)
    : undefined
  const categoryIsResolving = Boolean(category && isLoadingCategories)
  const categoryIsInvalid = Boolean(category && !isLoadingCategories && (categoriesError || !categoryFilter))

  const {
    posts,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isLoadingPosts,
    isError: postsError,
    fetchNextPage,
    refetch: refetchPosts,
  } = useInfiniteBlogPosts({
    category: categoryFilter,
    search: searchQuery,
    pageSize,
    enabled: !categoryIsResolving && !categoryIsInvalid,
  })

  const handleSearchSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev)
      const trimmed = searchValue.trim()
      if (trimmed) next.set('search', trimmed)
      else next.delete('search')
      next.delete('page')
      return next
    })
  }

  const handleClearSearch = () => {
    setSearchValue('')
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev)
      next.delete('search')
      next.delete('page')
      return next
    })
  }

  return (
    <>
      <SEO
        title={category ? `${categoryFilter || category} | FitCheck AI Blog` : 'Style & Wardrobe Blog | FitCheck AI'}
        description={
          category
            ? `${categoryFilter || category} articles on digital closets, AI outfit planning, and style from FitCheck AI.`
            : 'Guides on digital closets, AI outfit planning, virtual try-on, cost-per-wear, and getting more from clothes you own.'
        }
        canonicalUrl={`https://fitcheckaiapp.com/blog${category ? `/category/${category}` : ''}`}
        keywords="wardrobe blog, AI fashion tips, digital closet guides, outfit planning"
      />

      <div className="pt-20">
        {/* Hero Section */}
        <section className="py-16 md:py-24 bg-stone-50 dark:bg-stone-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto">
                <Badge className="mb-4 bg-secondary text-secondary-foreground border-0">
                  {category ? categoryFilter || category : 'Blog'}
                </Badge>
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 dark:text-white mb-6">
                  {category ? `${categoryFilter || category} Articles` : 'Fashion, AI & Style Tips'}
                </h1>
                <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300 mb-8">
                  {category
                    ? `Explore our latest articles on ${categoryFilter || category}`
                    : 'Discover how AI is transforming wardrobe management and get expert style advice'}
                </p>

                <form onSubmit={handleSearchSubmit} className="mx-auto flex max-w-xl gap-2" role="search">
                  <label htmlFor="blog-search" className="sr-only">Search blog posts</label>
                  <input
                    id="blog-search"
                    name="search"
                    autoComplete="off"
                    type="search"
                    value={searchValue}
                    onChange={(event) => setSearchValue(event.target.value)}
                    placeholder="Search articles…"
                    className="min-w-0 flex-1 rounded-lg border border-gray-200 bg-white px-4 py-3 text-sm text-gray-900 focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-primary/20 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
                  />
                  <button type="submit" className="rounded-lg bg-primary px-4 py-3 text-sm font-medium text-primary-foreground hover:bg-primary-pressed">
                    Search
                  </button>
                  {searchQuery && (
                    <button type="button" onClick={handleClearSearch} className="rounded-lg border border-gray-200 px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800">
                      Clear
                    </button>
                  )}
                </form>

                {/* Category Pills — the container is always rendered, but its
                    reserved min-height (which holds the posts grid steady while
                    categories fetch, avoiding CLS) applies only while loading or
                    when categories exist, so an error or empty list leaves no
                    blank band. */}
                <div
                  className={cn(
                    'flex flex-wrap justify-center gap-2',
                    (isLoadingCategories || (categories?.length ?? 0) > 0) && 'min-h-[124px] md:min-h-[44px]'
                  )}
                >
                  {isLoadingCategories ? (
                    // Skeleton pills fill the reserved space (same 36px pill
                    // height + wrap) instead of an empty band.
                    Array.from({ length: 6 }).map((_, i) => (
                      <span
                        key={i}
                        aria-hidden="true"
                        className="h-9 w-20 rounded-full bg-stone-200 dark:bg-stone-800 animate-pulse"
                      />
                    ))
                  ) : (
                    categories &&
                    categories.length > 0 && (
                      <>
                        <Link
                          to="/blog"
                          className={`px-4 py-2 rounded-full text-sm font-medium transition-colors border ${!category
                            ? 'bg-stone-900 text-white border-stone-900 dark:bg-white dark:text-stone-900 dark:border-white'
                            : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-stone-100 dark:hover:bg-stone-800 hover:text-primary dark:hover:text-primary border-gray-200 dark:border-gray-700'
                            }`}
                        >
                          All
                        </Link>
                        {categories.map((cat) => {
                          const catSlug = slugifyCategory(cat)
                          const isActive = category === catSlug
                          return (
                            <Link
                              key={cat}
                              to={`/blog/category/${catSlug}`}
                              className={`px-4 py-2 rounded-full text-sm font-medium transition-colors border ${isActive
                                ? 'bg-stone-900 text-white border-stone-900 dark:bg-white dark:text-stone-900 dark:border-white'
                                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-stone-100 dark:hover:bg-stone-800 hover:text-primary dark:hover:text-primary border-gray-200 dark:border-gray-700'
                                }`}
                            >
                              {cat}
                            </Link>
                          )
                        })}
                      </>
                    )
                  )}
                </div>
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* Blog Posts Grid */}
        <section className="py-16 md:py-24 bg-white dark:bg-gray-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            {categoryIsResolving || isLoadingPosts ? (
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12" role="status" aria-live="polite" aria-busy="true">
                {Array.from({ length: 6 }).map((_, i) => (
                  <div
                    key={i}
                    className="rounded-2xl overflow-hidden border border-stone-200 dark:border-stone-800 bg-stone-50 dark:bg-stone-900"
                  >
                    <div className="aspect-[16/9] bg-stone-200 dark:bg-stone-800 animate-pulse" />
                    <div className="p-6 space-y-3">
                      <div className="h-4 w-1/3 bg-stone-200 dark:bg-stone-800 rounded animate-pulse" />
                      <div className="h-6 w-full bg-stone-200 dark:bg-stone-800 rounded animate-pulse" />
                      <div className="h-4 w-2/3 bg-stone-200 dark:bg-stone-800 rounded animate-pulse" />
                    </div>
                  </div>
                ))}
              </div>
            ) : categoryIsInvalid ? (
              <div className="text-center py-20 space-y-4" role="alert">
                <p className="text-stone-600 dark:text-stone-400">
                  {categoriesError ? 'Unable to load blog categories.' : 'That blog category was not found.'}
                </p>
                <Link to="/blog" className="text-primary hover:underline inline-block">
                  View all posts
                </Link>
              </div>
            ) : postsError ? (
              <div className="text-center py-20 space-y-4" role="alert">
                <p className="text-stone-600 dark:text-stone-400">
                  Failed to load blog posts. Please try again.
                </p>
                <button
                  type="button"
                  onClick={() => refetchPosts()}
                  className="inline-flex items-center px-4 py-2 rounded-lg bg-primary text-white text-sm font-medium hover:bg-primary-pressed"
                >
                  Try again
                </button>
              </div>
            ) : posts.length === 0 ? (
              <div className="text-center py-20">
                <p className="text-stone-600 dark:text-stone-400">
                  No blog posts found{category ? ` in ${categoryFilter || category}` : ''}{searchQuery ? ` matching “${searchQuery}”` : ''}. Check back soon!
                </p>
                {category && (
                  <Link to="/blog" className="text-primary hover:underline mt-4 inline-block">
                    View all posts
                  </Link>
                )}
              </div>
            ) : (
              <>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
                  {posts.map((post, index) => (
                    <AnimatedSection key={post.slug} delay={index * 100}>
                      <Link to={`/blog/${post.slug}`} className="group block h-full">
                        <article className="flex h-full flex-col overflow-hidden rounded-lg border border-gray-100 bg-gray-50 transition-[border-color] duration-300 dark:border-gray-800 dark:bg-gray-900">
                          {/* Image Placeholder */}
                          <div className="aspect-[16/9] bg-stone-200 dark:bg-stone-800 flex items-center justify-center relative overflow-hidden">
                            <BlogImage
                              src={post.featured_image_url}
                              alt={post.title}
                              emoji={post.emoji}
                              emojiClassName="text-6xl md:text-7xl transform group-hover:scale-110 transition-transform duration-300"
                              imgClassName="transform group-hover:scale-105 transition-transform duration-500"
                              sizes="(min-width: 1024px) 33vw, (min-width: 768px) 50vw, 100vw"
                              widths={[320, 480, 640, 800]}
                              width={640}
                              height={360}
                              // The first card's image is the LCP element on
                              // mobile and desktop: eager + high priority so
                              // the preload scanner starts it immediately in
                              // the prerendered HTML, before any JS runs.
                              priority={index === 0}
                            />
                          </div>

                          <div className="p-6 flex-1 flex flex-col">
                            {/* Meta */}
                            <div className="flex items-center gap-3 mb-3 text-sm">
                              <span className="font-medium text-stone-600 dark:text-stone-400 bg-stone-100 dark:bg-stone-800 px-2.5 py-1 rounded">
                                {post.category}
                              </span>
                              <span className="flex items-center text-gray-500 dark:text-gray-400">
                                <Clock className="w-3.5 h-3.5 mr-1" />
                                {post.read_time}
                              </span>
                            </div>

                            {/* Title */}
                            <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3 group-hover:text-primary dark:group-hover:text-primary transition-colors line-clamp-2">
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
                              <span className="text-sm font-medium text-primary dark:text-primary flex items-center">
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

                {/* Infinite scroll */}
                <InfiniteScrollSentinel
                  onLoadMore={fetchNextPage}
                  hasMore={hasNextPage}
                  isLoading={isFetchingNextPage}
                />
              </>
            )}
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 md:py-24 bg-stone-900">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                Ready to transform your wardrobe?
              </h2>
              <p className="text-xl text-stone-300 mb-8">
                Join thousands using AI to organize, plan, and optimize their style
              </p>
              <Link
                to="/auth/register"
                className="inline-flex min-h-11 items-center gap-2 rounded-lg bg-on-image px-8 py-4 text-lg font-semibold text-on-image-foreground hover:opacity-90 transition-opacity"
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

export function slugifyCategory(category: string): string {
  return category
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}
