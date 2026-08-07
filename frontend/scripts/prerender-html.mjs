/**
 * Post-build: render real HTML into `<div id="root">` for every public
 * marketing route.
 *
 * Why this exists: the app is a client-rendered SPA, so `#root` shipped empty
 * and the browser could not paint anything until ~1 MB of JavaScript had been
 * fetched, parsed and executed. Measured on production, FCP and LCP landed in
 * the same millisecond — there was no earlier paint to have. Prerendering moves
 * first paint to TTFB + CSS.
 *
 * Runs after `prerender-meta.mjs`, which has already written the per-route
 * `dist/<path>/index.html` files with correct title/description/canonical. This
 * script only fills in the body.
 *
 * Route registry is `scripts/seo-content.mjs` SEO_ROUTES — the same list that
 * drives the sitemap and the meta prerender.
 */
import { readFileSync, writeFileSync, existsSync, rmSync, readdirSync, statSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'
import { execFileSync } from 'node:child_process'
import { SEO_ROUTES } from './seo-content.mjs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const dist = join(root, 'dist')

const ROOT_DIV = '<div id="root"></div>'

// ============================================================================
// CSS INLINING
// ============================================================================
//
// The single stylesheet link Vite emits is render-blocking (~400 ms on slow
// 4G, measured 2026-08-07) on every route. The stylesheet is small
// (~17.7 KiB gzipped) and the HTML is served with `must-revalidate`, so
// inlining it into every page costs nothing on repeat visits and removes the
// request from the critical path entirely. CSP already allows
// `style-src 'unsafe-inline'` (netlify.toml), so no policy change is needed.

const CSS_LINK_RE = /<link rel="stylesheet"[^>]*href="\/assets\/index-[^"]+\.css"[^>]*>/i

function findStylesheet() {
  const assetsDir = join(dist, 'assets')
  if (!existsSync(assetsDir)) return null
  for (const name of readdirSync(assetsDir)) {
    if (/^index-[A-Za-z0-9_-]+\.css$/.test(name)) return join(assetsDir, name)
  }
  return null
}

function collectHtmlFiles(dir, out = []) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name)
    if (name === 'assets' || name === '.vite') continue
    if (statSync(full).isDirectory()) collectHtmlFiles(full, out)
    else if (name.endsWith('.html')) out.push(full)
  }
  return out
}

/** Replace the stylesheet <link> with an inline <style> in every dist HTML file. */
function inlineStylesheets() {
  const cssPath = findStylesheet()
  if (!cssPath) {
    console.warn('[prerender-html] no index-*.css found in dist/assets — skipping CSS inlining')
    return
  }
  const css = readFileSync(cssPath, 'utf8')
  let replaced = 0
  for (const htmlPath of collectHtmlFiles(dist)) {
    const html = readFileSync(htmlPath, 'utf8')
    if (!CSS_LINK_RE.test(html)) continue
    const out = html.replace(CSS_LINK_RE, () => `<style>${css}</style>`)
    writeFileSync(htmlPath, out, 'utf8')
    replaced += 1
  }
  console.log(
    `[prerender-html] inlined ${cssPath.replace(dist, 'dist')} (${css.length} bytes) into ${replaced} HTML file(s)`
  )
}

// ============================================================================
// PER-ROUTE MODULEPRELOAD
// ============================================================================
//
// Vite preloads the entry's static imports in the HTML, but route chunks
// (loaded via dynamic import) are only discovered after the entry executes.
// With build.manifest enabled, the manifest maps each source module to its
// emitted chunk + transitive imports, so the prerender can start those
// downloads in parallel with first paint. Currently only /blog — the only
// data-driven route whose chunk graph is worth preloading.

const BLOG_MANIFEST_SOURCE = 'src/pages/blog/BlogIndexPage.tsx'

function readManifest() {
  const manifestPath = join(dist, '.vite', 'manifest.json')
  if (!existsSync(manifestPath)) return null
  try {
    return JSON.parse(readFileSync(manifestPath, 'utf8'))
  } catch (error) {
    console.warn('[prerender-html] could not parse build manifest:', error.message)
    return null
  }
}

/**
 * Modulepreload links for a route's component chunk graph, minus anything the
 * entry already preloads (the HTML shell already lists those).
 *
 * Vite's manifest is inconsistent about chunk naming: `file` values are
 * 'assets/<name>.js', while `imports` reference shared chunks as
 * '_<name>.js' — a leading underscore with NO directory prefix, even though
 * the emitted file is '<name>.js' inside assets/. Every name is therefore
 * normalized to 'assets/<name>.js' so hrefs, the dedupe set and the byFile
 * lookups share one form (without it, emitted hrefs lost the assets/ prefix
 * and 404'd). Non-JS imports ("index.html") and missing files are skipped.
 */
function routePreloads(manifest, sourcePath) {
  if (!manifest) return ''
  const entry = manifest['index.html']
  const page = manifest[sourcePath]
  if (!entry || !page) return ''

  const normalize = (name) => {
    const bare = name.startsWith('_') ? name.slice(1) : name
    return bare.startsWith('assets/') ? bare : `assets/${bare}`
  }

  const entryImports = new Set((entry.imports || []).map(normalize))
  const byFile = new Map()
  for (const value of Object.values(manifest)) {
    if (value && typeof value.file === 'string') byFile.set(value.file, value)
  }

  const seen = new Set()
  const emitted = []
  const push = (name) => {
    const assetPath = normalize(name)
    if (!assetPath.endsWith('.js')) return
    if (!existsSync(join(dist, assetPath))) {
      console.warn(`[prerender-html] modulepreload target not found in dist: ${assetPath}`)
      return
    }
    if (seen.has(assetPath)) return
    seen.add(assetPath)
    emitted.push(`<link rel="modulepreload" crossorigin href="/${assetPath}">`)
  }

  const visit = (name) => {
    const assetPath = normalize(name)
    if (entryImports.has(assetPath)) return
    push(assetPath)
    const meta = byFile.get(assetPath)
    for (const dep of meta?.imports || []) visit(dep)
  }
  visit(page.file)
  return emitted.join('')
}

/**
 * Sibling of dist/index.html that Netlify's SPA fallback serves for every
 * non-prerendered path (/auth/*, /dashboard, /wardrobe, ...). It is the
 * EMPTY-shell template — no #root markup, but with the pre-hydration theme
 * script, JSON-LD blocks and CSP hashes intact — so app routes never flash
 * the prerendered homepage on cold load or refresh. Written here (after
 * prerender-meta.mjs has set per-route meta) and never regenerated afterwards.
 */
const APP_SHELL_FILE = 'app-shell.html'

/**
 * Minimal browser globals for the render.
 *
 * Deliberately does NOT define `window`. `src/lib/theme.ts` already guards
 * every browser call with `typeof window === 'undefined'`, so leaving window
 * undefined makes `getStoredTheme()`/`getSystemTheme()` take their safe Node
 * paths. Defining it would create a window-without-document world and push this
 * and any other library down a browser path that then breaks on `document`.
 *
 * Storage IS shimmed, because zustand's `persist` middleware reaches for it
 * when the auth store module is evaluated — and Navbar imports that store for
 * `useIsAuthenticated()`.
 */
function installBrowserShims() {
  const store = new Map()
  const storageShim = {
    getItem: (key) => (store.has(key) ? store.get(key) : null),
    setItem: (key, value) => store.set(key, String(value)),
    removeItem: (key) => store.delete(key),
    clear: () => store.clear(),
    key: (i) => [...store.keys()][i] ?? null,
    get length() {
      return store.size
    },
  }

  globalThis.localStorage ??= storageShim
  globalThis.sessionStorage ??= storageShim
  globalThis.requestIdleCallback ??= (cb) => setTimeout(cb, 0)
  globalThis.cancelIdleCallback ??= (id) => clearTimeout(id)
}

/**
 * Build the SSR bundle and return its entry path. Kept inside the project (and
 * gitignored) rather than in the OS temp dir, so Vite does not refuse to empty
 * an outDir outside the project root.
 */
function buildSsrBundle() {
  const outDir = join(root, '.prerender-ssr')
  execFileSync(
    'npx',
    [
      'vite',
      'build',
      '--ssr',
      'src/entry-prerender.tsx',
      '--outDir',
      outDir,
      '--emptyOutDir',
      '--logLevel',
      'warn',
    ],
    { cwd: root, stdio: 'inherit' }
  )
  return { outDir, entry: join(outDir, 'entry-prerender.js') }
}

/** dist path for a route: "/" -> dist/index.html, "/faq" -> dist/faq/index.html */
function htmlPathFor(routePath) {
  return routePath === '/'
    ? join(dist, 'index.html')
    : join(dist, routePath.replace(/^\//, ''), 'index.html')
}

async function main() {
  installBrowserShims()

  // Inline the stylesheet into every HTML file FIRST so the app-shell
  // snapshot below (taken from dist/index.html) and all route shells carry
  // the inline CSS too.
  inlineStylesheets()

  // Snapshot the empty-shell template BEFORE the homepage fill below. Netlify's
  // SPA fallback (`/* -> /app-shell.html`, see netlify.toml) serves this file
  // for every non-prerendered path, so a cold load or refresh of /auth/*,
  // /dashboard, etc. must NOT show the prerendered homepage — it would flash
  // marketing content until JS hydrates. Overwrite on every fresh build so a
  // stale shell can never accumulate. The one guard: if dist/index.html is
  // ALREADY filled (this script re-run by hand against a completed dist — the
  // "already prerendered" no-op path below), keep the existing shell instead
  // of capturing homepage markup as the app shell.
  const shellPath = join(dist, APP_SHELL_FILE)
  try {
    const pristine = readFileSync(join(dist, 'index.html'), 'utf8')
    // Empty root, allowing only whitespace between the tags. (The looser
    // `\s*\S` probe used for the route loop is only meaningful on FILLED
    // files; against a fresh shell it matches the closing `</div>`.)
    const emptyRoot = /<div id="root">\s*<\/div>/
    if (pristine.includes(ROOT_DIV) && emptyRoot.test(pristine)) {
      writeFileSync(shellPath, pristine, 'utf8')
      console.log(`[prerender-html] wrote ${APP_SHELL_FILE} (empty shell for the SPA fallback)`)
    } else {
      console.warn(
        `[prerender-html] skipped ${APP_SHELL_FILE}: dist/index.html already prerendered ` +
          '(manual re-run?) — keeping the existing shell'
      )
    }
  } catch (error) {
    throw new Error(`Could not write the app shell at ${shellPath}: ${error.message}`)
  }

  const { outDir, entry } = buildSsrBundle()

  let renderModule
  try {
    renderModule = await import(pathToFileURL(entry).href)
  } catch (error) {
    rmSync(outDir, { recursive: true, force: true })
    throw new Error(`Could not load the SSR bundle at ${entry}: ${error.message}`)
  }

  const { render, PRERENDER_SKIP } = renderModule

  // Read once, before the route loop — per-route modulepreloads use it.
  const manifest = readManifest()

  // Required, not optional. A local fallback copy would silently diverge from
  // routes/publicRoutes.ts the moment someone edits one and not the other, and
  // the failure mode is quiet: a data-driven route gets a loading skeleton baked
  // into its HTML. Better to break the build.
  if (!(PRERENDER_SKIP instanceof Set)) {
    throw new Error(
      'entry-prerender must re-export PRERENDER_SKIP (a Set) from routes/publicRoutes'
    )
  }
  if (typeof render !== 'function') {
    throw new Error('entry-prerender must export a render(pathname) function')
  }
  const skip = PRERENDER_SKIP

  const written = []
  const skipped = []
  const failures = []

  for (const { path: routePath } of SEO_ROUTES) {
    if (skip.has(routePath)) {
      skipped.push(`${routePath} (data-driven)`)
      continue
    }

    const htmlPath = htmlPathFor(routePath)
    if (!existsSync(htmlPath)) {
      skipped.push(`${routePath} (no ${htmlPath.replace(dist, 'dist')})`)
      continue
    }

    let markup
    let headScripts = ''
    let skipRoute = false
    try {
      const result = await render(routePath)
      if (result.skip) {
        // The route's build-time data was unavailable (e.g. blog API down).
        // Ship the empty shell exactly as before prerendering existed — the
        // client renders the page itself.
        skipRoute = true
      } else {
        markup = result.markup
        headScripts = result.headScripts || ''
      }
    } catch (error) {
      failures.push(`${routePath}: ${error.message}`)
      continue
    }

    if (skipRoute) {
      skipped.push(`${routePath} (build-time data unavailable)`)
      continue
    }

    // A route that renders to nothing is a bug, not an acceptable no-op: it
    // would ship an empty #root and look exactly like the problem this script
    // was written to fix.
    if (!markup || markup.trim().length < 200) {
      failures.push(`${routePath}: rendered ${markup ? markup.length : 0} chars (expected real markup)`)
      continue
    }

    const html = readFileSync(htmlPath, 'utf8')
    if (!html.includes(ROOT_DIV)) {
      // `npm run build` always regenerates these shells via prerender-meta.mjs
      // first, so an already-filled root only happens when this script is
      // re-run by hand against an existing dist. That is a no-op, not a fault.
      if (/<div id="root">\s*\S/.test(html)) {
        skipped.push(`${routePath} (already prerendered)`)
        continue
      }
      failures.push(`${routePath}: no empty ${ROOT_DIV} found in ${htmlPath.replace(dist, 'dist')}`)
      continue
    }

    // Bake the page's Helmet-declared JSON-LD (FAQ/HowTo/ItemList/etc.) into
    // <head> so non-JS crawlers and the Lighthouse source pass see structured
    // data without waiting for hydration. Only JSON-LD scripts are emitted;
    // title/description/canonical are already set per-route by prerender-meta.
    let out = html.replace(ROOT_DIV, `<div id="root">${markup}</div>`)
    const headInject = []
    if (headScripts && headScripts.trim()) {
      // De-dupe: skip injection if this page's JSON-LD is already present
      // (e.g. a re-run). Cheap containment check on the first <script of the block.
      const probe = headScripts.slice(0, 60)
      if (!html.includes(probe)) headInject.push(headScripts)
    }
    // The hero image is the LCP element, but it only renders on the homepage.
    // Preload it there only — emitting this on every route would make /faq,
    // /features, etc. fetch a hero image they never display.
    if (routePath === '/') {
      headInject.push(
        '<link rel="preload" as="image" href="/landing/wardrobe-640.webp" imagesrcset="/landing/wardrobe-640.webp 640w, /landing/wardrobe.webp 1152w" imagesizes="(min-width: 1024px) 58vw, 100vw" fetchpriority="high" />'
      )
    }
    // The blog index's JS chunk graph is only discovered after the entry
    // executes; preload it here so hydration starts in parallel with the
    // baked-content paint.
    if (routePath === '/blog') {
      const preloads = routePreloads(manifest, BLOG_MANIFEST_SOURCE)
      if (preloads) headInject.push(preloads)
    }
    if (headInject.length) {
      out = out.replace('</head>', `${headInject.join('')}\n    </head>`)
    }
    writeFileSync(htmlPath, out, 'utf8')
    written.push(routePath)
  }

  rmSync(outDir, { recursive: true, force: true })

  console.log(`[prerender-html] rendered ${written.length} route(s)`)
  if (skipped.length) {
    console.log(`[prerender-html] skipped ${skipped.length}: ${skipped.join(', ')}`)
  }

  if (failures.length) {
    console.error(`[prerender-html] ${failures.length} route(s) failed:`)
    for (const failure of failures) console.error(`  - ${failure}`)
    process.exit(1)
  }

  if (written.length === 0) {
    console.error('[prerender-html] no routes were prerendered — refusing to ship an empty #root')
    process.exit(1)
  }
}

main().catch((error) => {
  console.error('[prerender-html] failed:', error)
  process.exit(1)
})
