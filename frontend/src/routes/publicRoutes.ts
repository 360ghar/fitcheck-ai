/**
 * The public (marketing) route table — the single source of truth shared by
 * the client router in App.tsx and the build-time prerender in
 * entry-prerender.tsx.
 *
 * Why a manifest instead of JSX in App.tsx: the prerender has to render the
 * same components at build time, and two hand-maintained lists would drift.
 *
 * ## The Suspense flash this file exists to prevent
 *
 * The prerender writes real HTML into `<div id="root">`, so the page is on
 * screen at TTFB. Then main.tsx calls `createRoot().render()`, which clears
 * that markup and renders fresh. If the matched page were still an unresolved
 * `React.lazy`, React would paint the `<Suspense>` spinner over our
 * already-visible content — destroying the paint we just bought and pushing
 * LCP back out to the final render.
 *
 * So main.tsx awaits `preloadRoute(pathname)` before the first render, and
 * `componentFor()` then returns the *already-resolved* component
 * synchronously. No suspend, no fallback frame, no flash. Routes the user
 * navigates to later still resolve through the normal lazy path.
 */

import { lazy, type ComponentType } from 'react'
import { matchPath } from 'react-router-dom'

export interface PublicRouteDef {
  path: string
  importer: () => Promise<{ default: ComponentType }>
}

type PageModule = Promise<{ default: ComponentType }>

/**
 * Every route rendered inside `PublicLayout`. Keep in sync with
 * `scripts/seo-content.mjs` SEO_ROUTES (which drives sitemap + meta) — that
 * registry is what the prerender iterates.
 */
export const PUBLIC_ROUTES: PublicRouteDef[] = [
  { path: '/', importer: () => import('@/pages/public/LandingPage') as PageModule },
  { path: '/about', importer: () => import('@/pages/public/AboutPage') as PageModule },
  { path: '/terms', importer: () => import('@/pages/public/TermsPage') as PageModule },
  { path: '/privacy', importer: () => import('@/pages/public/PrivacyPage') as PageModule },
  { path: '/support', importer: () => import('@/pages/public/SupportPage') as PageModule },
  { path: '/faq', importer: () => import('@/pages/public/FAQPage') as PageModule },

  // Blog is data-driven (fetches posts on mount) and already has the
  // `seo-html` Netlify edge function in front of it, so the prerender skips
  // these — see PRERENDER_SKIP below.
  { path: '/blog', importer: () => import('@/pages/blog/BlogIndexPage') as PageModule },
  {
    path: '/blog/category/:category',
    importer: () => import('@/pages/blog/BlogIndexPage') as PageModule,
  },
  { path: '/blog/:slug', importer: () => import('@/pages/blog/BlogPostPage') as PageModule },

  // Feature landing pages
  { path: '/features', importer: () => import('@/pages/features/FeaturesIndexPage') as PageModule },
  {
    path: '/features/ai-wardrobe-extraction',
    importer: () => import('@/pages/features/AIWardrobeExtractionPage') as PageModule,
  },
  {
    path: '/features/virtual-try-on',
    importer: () => import('@/pages/features/VirtualTryOnPage') as PageModule,
  },
  {
    path: '/features/ai-photoshoot-generator',
    importer: () => import('@/pages/features/AIPhotoshootGeneratorPage') as PageModule,
  },
  {
    path: '/features/outfit-recommendations',
    importer: () => import('@/pages/features/OutfitRecommendationsPage') as PageModule,
  },
  {
    path: '/features/wardrobe-analytics',
    importer: () => import('@/pages/features/WardrobeAnalyticsPage') as PageModule,
  },

  // SEO intent pages: best-of, comparisons, personas, guides. All render the
  // same path-driven component.
  ...[
    '/best/virtual-closet-apps',
    '/best/ai-outfit-planners',
    '/compare/fitcheck-vs-acloset',
    '/compare/fitcheck-vs-whering',
    '/compare/fitcheck-vs-stylebook',
    '/compare/fitcheck-vs-indyx',
    '/compare/fitcheck-vs-cladwell',
    '/compare/fitcheck-vs-open-wardrobe',
    '/alternatives/acloset-alternatives',
    '/for/busy-professionals',
    '/for/content-creators',
    '/for/festive-and-wedding-outfits',
    '/guides/how-to-digitize-your-wardrobe',
    '/guides/what-to-wear-today',
    '/guides/cost-per-wear-calculator-explained',
    '/guides/how-to-reduce-clothing-returns-with-virtual-try-on',
    '/guides/what-is-a-capsule-wardrobe',
    '/guides/what-is-wardrobe-utilization',
    '/wear/:citySlug',
  ].map((path) => ({
    path,
    importer: () => import('@/pages/seo/IntentSeoPage') as PageModule,
  })),

  {
    path: '/tools/cost-per-wear-calculator',
    importer: () => import('@/pages/tools/CostPerWearCalculatorPage') as PageModule,
  },
]

/**
 * Routes the prerender must not emit markup for, because their content comes
 * from a network fetch — baking a loading skeleton into the HTML would be worse
 * than an empty root.
 */
export const PRERENDER_SKIP = new Set(['/blog'])

/**
 * One `lazy()` wrapper per route, created once at module scope. Creating these
 * inside render would remount the page on every parent render.
 */
const lazyComponents = new Map<string, ComponentType>(
  PUBLIC_ROUTES.map((route) => [route.path, lazy(route.importer)])
)

/** Modules resolved before the first render by `preloadRoute`. */
const resolved = new Map<string, ComponentType>()

/**
 * The registered route whose pattern matches `pathname`, or undefined.
 *
 * Pattern match, not string equality: SEO_ROUTES lists concrete paths like
 * /wear/what-to-wear-in-mumbai while this manifest registers /wear/:citySlug.
 *
 * Owned here so the prerender entry and the client preloader cannot disagree
 * about which module a URL resolves to — they had each written this `find` out,
 * and `preloadRoute` additionally took the matcher as a parameter purely to dodge
 * importing react-router, which its own consumers already depend on.
 */
export function routeFor(pathname: string): PublicRouteDef | undefined {
  return PUBLIC_ROUTES.find((route) => matchPath(route.path, pathname) !== null)
}

/** The component to render for a route: resolved if preloaded, else lazy. */
export function componentFor(path: string): ComponentType {
  const eager = resolved.get(path)
  if (eager) return eager
  const lazyComponent = lazyComponents.get(path)
  if (!lazyComponent) {
    throw new Error(`No public route registered for "${path}"`)
  }
  return lazyComponent
}

/**
 * Resolve the page module for `pathname` before the first React render, so the
 * prerendered HTML is replaced in one shot instead of flashing a spinner.
 *
 * Never rejects: a chunk that fails to load falls through to the normal lazy
 * path (and its Suspense boundary), which is the pre-existing behaviour.
 */
export async function preloadRoute(pathname: string): Promise<void> {
  const match = routeFor(pathname)
  if (!match) return
  try {
    const mod = await match.importer()
    resolved.set(match.path, mod.default)
  } catch {
    // Fall back to lazy + Suspense.
  }
}
