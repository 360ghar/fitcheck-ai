/**
 * Build-time prerender entry. NOT part of the client bundle — it is compiled
 * separately by `vite build --ssr` and consumed by scripts/prerender-html.mjs.
 *
 * Because nothing here ships to the browser, it can import page components
 * eagerly without affecting client chunking at all.
 *
 * Scope is deliberately the public marketing tree only: PublicLayout (Navbar +
 * Footer) plus the matched page. The authenticated app, the analytics provider
 * and the query client are not involved, so this never needs a Supabase client
 * or a live API at build time.
 */

import { StrictMode } from 'react'
import { renderToString } from 'react-dom/server'
import { StaticRouter } from 'react-router'
import { Routes, Route } from 'react-router-dom'
import { HelmetProvider } from 'react-helmet-async'
import { QueryClient, QueryClientProvider, dehydrate } from '@tanstack/react-query'
import { TooltipProvider } from './components/ui/tooltip'
import { ThemeProvider } from './components/theme/ThemeProvider'
import PublicLayout from './layouts/PublicLayout'
import { routeFor } from './routes/publicRoutes'

// No `./index.css` import here: this entry only produces markup, and the built
// client stylesheet is already linked from the HTML shell.

// Re-exported so scripts/prerender-html.mjs reads the skip list from the same
// module the routes come from, instead of keeping its own copy.
export { PRERENDER_SKIP } from './routes/publicRoutes'

/**
 * Blog index build-time data. The blog index is data-driven (posts come from
 * the API), but an empty `#root` means nothing paints until ~700 KB of JS
 * parses — the page's FCP/LCP problem (2026-08-07 PSI: LCP 5.2s lab). Instead
 * the prerender fetches the first page + categories at build time and bakes
 * the real grid into the HTML (see render() below).
 */
const BLOG_API = 'https://api.fitcheckaiapp.com'
const BLOG_PAGE_SIZE = 12
const PRERENDER_FETCH_TIMEOUT_MS = 10_000

async function fetchJson<T>(url: string): Promise<T | null> {
  try {
    const res = await fetch(url, {
      headers: { Accept: 'application/json' },
      signal: AbortSignal.timeout(PRERENDER_FETCH_TIMEOUT_MS),
    })
    if (!res.ok) return null
    return (await res.json()) as T
  } catch {
    return null
  }
}

/**
 * Prefetch the blog index's first page + categories into the query cache so
 * the prerendered HTML contains real posts. Returns false when the API is
 * unreachable at build time — the caller then SKIPS the route (empty shell),
 * which is exactly the pre-prerender behaviour: the client fetches the data
 * itself. A build must never fail because a marketing page's API was down.
 */
async function prefetchBlogIndex(queryClient: QueryClient): Promise<boolean> {
  const [postsEnvelope, categoriesEnvelope] = await Promise.all([
    fetchJson<{ data?: { posts?: unknown[] } }>(
      `${BLOG_API}/api/v1/blog/posts?page=1&page_size=${BLOG_PAGE_SIZE}`
    ),
    fetchJson<{ data?: { categories?: string[] } }>(`${BLOG_API}/api/v1/blog/categories`),
  ])

  const postsBody = postsEnvelope?.data
  const categories = categoriesEnvelope?.data?.categories

  // A partial bake (one endpoint down) is not worth the extra branch — either
  // both land, or the client renders the page itself.
  if (!postsBody || !Array.isArray(postsBody.posts) || !Array.isArray(categories)) return false

  // Keys must match the client hooks exactly:
  //   useInfiniteBlogPosts -> ['blog', 'infinite', { category, search, pageSize }]
  //   useBlogCategories    -> ['blog', 'categories']
  // Note `search: ''` (not undefined): BlogIndexPage always passes the trimmed
  // search string, which defaults to '' — react-query hashes keys by their
  // stringified value, so `search: undefined` would miss the cache entirely.
  queryClient.setQueryData(
    ['blog', 'infinite', { category: undefined, search: '', pageSize: BLOG_PAGE_SIZE }],
    // The full list body (posts + page + has_next) so the client's
    // getNextPageParam keeps working after hydration.
    { pages: [postsEnvelope.data], pageParams: [1] }
  )
  queryClient.setQueryData(['blog', 'categories'], categories)
  return true
}

/** The <head> script that carries the baked query state to the client. */
const QUERY_STATE_ID = '__FITCHECK_QUERY_STATE__'

function serializeQueryState(queryClient: QueryClient): string {
  const state = dehydrate(queryClient)
  // Force client-side staleness: the baked copy reflects the deploy, not the
  // live API. Stamped stale, the client hooks refetch on mount and swap in
  // fresh posts without waiting for the next deploy.
  for (const query of state.queries) query.state.dataUpdatedAt = 0
  // Escape '<' so post content can never terminate the script element early.
  const json = JSON.stringify(state).replace(/</g, '\\u003c')
  return `<script id="${QUERY_STATE_ID}" type="application/json">${json}</script>`
}

/**
 * Render one public route to static HTML.
 *
 * Returns `{ markup, headScripts, skip? }`: `markup` is the page body to fill
 * into #root; `headScripts` is the Helmet-captured `<script type="application/ld+json">`
 * tags the page declares (e.g. FAQPage, HowTo, ItemList, BreadcrumbList) plus,
 * for /blog, the serialized query state, so the caller can bake them into
 * <head> for non-JS crawlers. Only JSON-LD scripts are surfaced —
 * title/description/canonical/og are already owned per-route by
 * scripts/prerender-meta.mjs, so we deliberately do NOT emit helmet.title/meta
 * to avoid duplicating or racing them.
 *
 * `skip: true` means "do not prerender this route" (build-time blog data
 * unavailable) — the caller ships the empty shell and the client renders the
 * page as it did before prerendering existed.
 *
 * Throws when the path is not a registered public route, or when the component
 * fails to render — the caller turns that into a build failure rather than
 * silently emitting an empty `#root`.
 */
export async function render(
  pathname: string
): Promise<{ markup: string; headScripts: string; skip?: boolean }> {
  // Rendering `path={route.path}` under `location={pathname}` is what gives the
  // page its useParams() values.
  const route = routeFor(pathname)
  if (!route) {
    throw new Error(`"${pathname}" is not a registered public route`)
  }

  const { default: Page } = await route.importer()

  // Capture Helmet's server head so the page's JSON-LD can be baked into the
  // static HTML. A fresh context per render keeps routes from leaking schema
  // into each other.
  const helmetContext: Record<string, unknown> = {}

  // The blog index gets a query client with the first page + categories
  // baked in (see prefetchBlogIndex). All other routes render without any
  // query state — the provider is a no-op for them.
  let prerenderHead = ''
  let queryClient: QueryClient | null = null
  if (pathname === '/blog') {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false,
          staleTime: Infinity,
          gcTime: Infinity,
          refetchOnMount: false,
          refetchOnWindowFocus: false,
          refetchOnReconnect: false,
        },
      },
    })
    const baked = await prefetchBlogIndex(queryClient)
    if (!baked) {
      return { markup: '', headScripts: '', skip: true }
    }
    prerenderHead = serializeQueryState(queryClient)
  }

  // Theme is applied as a class on <html> by the inline script in index.html,
  // and every themed style is a Tailwind `dark:` variant, so the *markup* is
  // identical in both themes. Rendering with the default theme here is safe.
  //
  // The nesting mirrors App.tsx exactly — PublicLayout renders its page through
  // <Outlet />, so it has to be a parent Route, not a wrapper with children.
  const markup = renderToString(
    <StrictMode>
      <HelmetProvider context={helmetContext}>
        <ThemeProvider defaultTheme="system">
          <QueryClientProvider client={queryClient ?? new QueryClient()}>
            <StaticRouter location={pathname}>
              <TooltipProvider delayDuration={0}>
                <Routes>
                  <Route element={<PublicLayout />}>
                    <Route path={route.path} element={<Page />} />
                  </Route>
                </Routes>
              </TooltipProvider>
            </StaticRouter>
          </QueryClientProvider>
        </ThemeProvider>
      </HelmetProvider>
    </StrictMode>
  )

  // helmet.script is the rendered JSON-LD <script> tags declared by the page
  // (FAQ/HowTo/ItemList/etc.). It may be '' for pages that declare none.
  const helmet = (helmetContext.helmet ?? {}) as { script?: { toString: () => string } }
  const headScripts = helmet.script ? helmet.script.toString() : ''

  return { markup, headScripts: `${headScripts}\n    ${prerenderHead}` }
}
