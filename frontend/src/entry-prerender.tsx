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
 * Render one public route to static HTML.
 *
 * Returns `{ markup, headScripts }`: `markup` is the page body to fill into
 * #root; `headScripts` is the Helmet-captured `<script type="application/ld+json">`
 * tags the page declares (e.g. FAQPage, HowTo, ItemList, BreadcrumbList) so the
 * caller can bake them into <head> for non-JS crawlers. Only JSON-LD scripts
 * are surfaced — title/description/canonical/og are already owned per-route by
 * scripts/prerender-meta.mjs, so we deliberately do NOT emit helmet.title/meta
 * to avoid duplicating or racing them.
 *
 * Throws when the path is not a registered public route, or when the component
 * fails to render — the caller turns that into a build failure rather than
 * silently emitting an empty `#root`.
 */
export async function render(
  pathname: string
): Promise<{ markup: string; headScripts: string }> {
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
          <StaticRouter location={pathname}>
            <TooltipProvider delayDuration={0}>
              <Routes>
                <Route element={<PublicLayout />}>
                  <Route path={route.path} element={<Page />} />
                </Route>
              </Routes>
            </TooltipProvider>
          </StaticRouter>
        </ThemeProvider>
      </HelmetProvider>
    </StrictMode>
  )

  // helmet.script is the rendered JSON-LD <script> tags declared by the page
  // (FAQ/HowTo/ItemList/etc.). It may be '' for pages that declare none.
  const helmet = (helmetContext.helmet ?? {}) as { script?: { toString: () => string } }
  const headScripts = helmet.script ? helmet.script.toString() : ''

  return { markup, headScripts }
}
