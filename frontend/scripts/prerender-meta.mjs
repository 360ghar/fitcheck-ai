/**
 * Post-build: for each public marketing path, write dist/<path>/index.html
 * with unique title/description/canonical so crawlers do not only see the SPA shell homepage meta.
 *
 * Netlify serves these static files when present (before SPA fallback).
 *
 * Keep ROUTES in sync with:
 * - src/App.tsx public routes
 * - src/components/seo/seo-config.ts STATIC_PUBLIC_ROUTES
 * - src/components/seo/content/intent-pages.ts
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync, cpSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { SITE, SEO_ROUTES } from './seo-content.mjs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const dist = join(root, 'dist')
const OG = `${SITE}/og-default.jpg`

// Shared route registry — the single source of truth for build-time SEO files.
const ROUTES = SEO_ROUTES.map(({ path, title, description }) => ({ path, title, description }))


function escapeAttr(s) {
  return s
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function injectMeta(html, { path, title, description }) {
  const canonical = path === '/' ? `${SITE}/` : `${SITE}${path}`
  const t = escapeAttr(title)
  const d = escapeAttr(description)
  const c = escapeAttr(canonical)

  let out = html

  out = out.replace(/<title>[^<]*<\/title>/i, `<title>${t}</title>`)
  out = out.replace(
    /<meta name="title" content="[^"]*"\s*\/?>/i,
    `<meta name="title" content="${t}" />`
  )
  out = out.replace(
    /<meta name="description" content="[^"]*"\s*\/?>/i,
    `<meta name="description" content="${d}" />`
  )
  out = out.replace(
    /<link rel="canonical" href="[^"]*"\s*\/?>/i,
    `<link rel="canonical" href="${c}" />`
  )
  out = out.replace(
    /<meta property="og:url" content="[^"]*"\s*\/?>/i,
    `<meta property="og:url" content="${c}" />`
  )
  out = out.replace(
    /<meta property="og:title" content="[^"]*"\s*\/?>/i,
    `<meta property="og:title" content="${t}" />`
  )
  out = out.replace(
    /<meta property="og:description" content="[^"]*"\s*\/?>/i,
    `<meta property="og:description" content="${d}" />`
  )
  out = out.replace(
    /<meta property="og:image" content="[^"]*"\s*\/?>/i,
    `<meta property="og:image" content="${OG}" />`
  )
  out = out.replace(
    /<meta name="twitter:url" content="[^"]*"\s*\/?>/i,
    `<meta name="twitter:url" content="${c}" />`
  )
  out = out.replace(
    /<meta name="twitter:title" content="[^"]*"\s*\/?>/i,
    `<meta name="twitter:title" content="${t}" />`
  )
  out = out.replace(
    /<meta name="twitter:description" content="[^"]*"\s*\/?>/i,
    `<meta name="twitter:description" content="${d}" />`
  )
  out = out.replace(
    /<meta name="twitter:image" content="[^"]*"\s*\/?>/i,
    `<meta name="twitter:image" content="${OG}" />`
  )

  // Optional crawler-visible teaser (React will replace #root on hydrate)
  const teaser = `
    <noscript>
      <main style="font-family:system-ui,sans-serif;max-width:42rem;margin:2rem auto;padding:0 1rem">
        <h1>${t}</h1>
        <p>${d}</p>
        <p><a href="${c}">Continue to FitCheck AI</a> · <a href="${SITE}/auth/register">Create free account</a></p>
      </main>
    </noscript>`

  if (!out.includes('<noscript>')) {
    out = out.replace('<div id="root"></div>', `<div id="root"></div>${teaser}`)
  }

  return out
}

function main() {
  const indexPath = join(dist, 'index.html')
  if (!existsSync(indexPath)) {
    console.error('[prerender-meta] dist/index.html missing — run vite build first')
    process.exit(1)
  }

  const baseHtml = readFileSync(indexPath, 'utf8')
  let count = 0

  for (const route of ROUTES) {
    const html = injectMeta(baseHtml, route)
    if (route.path === '/') {
      writeFileSync(indexPath, html, 'utf8')
    } else {
      const dir = join(dist, route.path.replace(/^\//, ''))
      mkdirSync(dir, { recursive: true })
      writeFileSync(join(dir, 'index.html'), html, 'utf8')
    }
    count += 1
  }

  // Ensure OG jpg is in dist (copied from public by vite, but be safe)
  const ogSrc = join(root, 'public', 'og-default.jpg')
  const ogDest = join(dist, 'og-default.jpg')
  if (existsSync(ogSrc) && !existsSync(ogDest)) {
    cpSync(ogSrc, ogDest)
  }

  console.log(`[prerender-meta] Wrote unique meta HTML for ${count} routes`)
}

main()
