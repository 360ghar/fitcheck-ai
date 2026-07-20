/**
 * Post-build: for each public marketing path, write dist/<path>/index.html
 * with unique title/description/canonical so crawlers do not only see the SPA shell homepage meta.
 *
 * Netlify serves these static files when present (before SPA fallback).
 *
 * Keep ROUTES in sync with:
 * - src/App.tsx public routes
 * - scripts/generate-sitemap.mjs STATIC_ROUTES
 * - src/components/seo/seo-config.ts STATIC_PUBLIC_ROUTES
 * - src/components/seo/content/intent-pages.ts
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync, cpSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const dist = join(root, 'dist')
const SITE = 'https://fitcheckaiapp.com'
const OG = `${SITE}/og-default.jpg`

const ROUTES = [
  { path: '/', title: 'AI Virtual Closet & Outfit Planner | FitCheck AI', description: 'AI virtual closet app: photograph clothes, get weather-aware outfit ideas, virtual try-on, and AI photoshoots. Free digital wardrobe on web and Android.' },
  { path: '/features', title: 'Features | AI Wardrobe, Try-On & Outfit Planner | FitCheck AI', description: 'Explore AI wardrobe extraction, virtual try-on, outfit recommendations, photoshoot generator, and wardrobe analytics.' },
  { path: '/features/ai-wardrobe-extraction', title: 'AI Wardrobe Extraction | Digitize Your Closet in Minutes', description: 'Upload photos of your clothes. AI detects items, colors, and categories so you build a digital wardrobe without manual tagging.' },
  { path: '/features/virtual-try-on', title: 'AI Virtual Try-On | See Outfits on You Before You Wear Them', description: 'Visualize any outfit from your wardrobe on your body with AI virtual try-on. Mix pieces, save looks, shop with confidence.' },
  { path: '/features/ai-photoshoot-generator', title: 'AI Photoshoot Generator | LinkedIn, Dating & Social Photos', description: 'Create professional-looking photos from your selfies for LinkedIn, dating apps, and social media — without a studio.' },
  { path: '/features/outfit-recommendations', title: 'AI Outfit Recommendations | What to Wear Today', description: 'Get daily outfit ideas from clothes you already own. Weather-aware, occasion-ready recommendations in seconds.' },
  { path: '/features/wardrobe-analytics', title: 'Wardrobe Analytics & Cost-Per-Wear | FitCheck AI', description: 'See what you wear, what you ignore, and cost-per-wear for every item. Buy smarter and wear more of your closet.' },
  { path: '/about', title: 'About FitCheck AI | AI Wardrobe & Style App', description: 'FitCheck AI helps you digitize your closet, plan outfits, and look better with less decision fatigue. Learn our mission and product story.' },
  { path: '/faq', title: 'FAQ | FitCheck AI Virtual Closet & Outfit Planner', description: 'Answers about AI wardrobe extraction, virtual try-on, photoshoots, pricing, privacy, and how FitCheck AI organizes your clothes.' },
  { path: '/blog', title: 'Style & Wardrobe Blog | FitCheck AI', description: 'Guides on digital closets, AI outfit planning, virtual try-on, cost-per-wear, and getting more from clothes you own.' },
  { path: '/support', title: 'Support | FitCheck AI', description: 'Contact FitCheck AI support, report content or abuse, and find privacy and account help.' },
  { path: '/privacy', title: 'Privacy Policy | FitCheck AI', description: 'How FitCheck AI collects, stores, and protects your wardrobe photos and account data.' },
  { path: '/terms', title: 'Terms of Service | FitCheck AI', description: 'Terms governing use of the FitCheck AI web app, mobile apps, and related services.' },
  { path: '/best/virtual-closet-apps', title: 'Best Virtual Closet Apps in 2026 | FitCheck AI', description: 'Compare the best virtual closet and digital wardrobe apps. See which AI outfit planners help you wear more of what you own.' },
  { path: '/best/ai-outfit-planners', title: 'Best AI Outfit Planners in 2026 | FitCheck AI', description: 'A practical comparison of AI outfit planners and stylists — free options, try-on, wardrobe digitization, and daily recommendations.' },
  { path: '/compare/fitcheck-vs-acloset', title: 'FitCheck AI vs Acloset | Virtual Closet Comparison', description: 'Side-by-side comparison of FitCheck AI and Acloset: wardrobe extraction, try-on, recommendations, pricing, and who each app is for.' },
  { path: '/compare/fitcheck-vs-whering', title: 'FitCheck AI vs Whering | Digital Wardrobe Comparison', description: 'Compare FitCheck AI and Whering for digital wardrobes, outfit planning, analytics, and AI features.' },
  { path: '/alternatives/acloset-alternatives', title: 'Best Acloset Alternatives in 2026 | FitCheck AI', description: 'Looking for Acloset alternatives? Compare virtual closet apps with AI try-on, photoshoots, and smarter outfit recommendations.' },
  { path: '/for/busy-professionals', title: 'Outfit Planner for Busy Professionals | FitCheck AI', description: 'Spend less time deciding what to wear. AI outfits from your real wardrobe, planned around weather and your calendar.' },
  { path: '/for/content-creators', title: 'AI Wardrobe & Try-On for Content Creators | FitCheck AI', description: 'Plan looks, visualize outfits, and generate photoshoot-style images for content calendars — from clothes you already own.' },
  { path: '/for/festive-and-wedding-outfits', title: 'Festive & Wedding Guest Outfit Planner | FitCheck AI', description: 'Plan festive, wedding guest, and occasion looks from your wardrobe. Digitize ethnic and formal wear, then mix outfits with AI.' },
  { path: '/guides/how-to-digitize-your-wardrobe', title: 'How to Digitize Your Wardrobe (Step-by-Step) | FitCheck AI', description: 'A practical guide to photographing and cataloging your clothes into a digital closet — faster with AI extraction.' },
  { path: '/guides/what-to-wear-today', title: 'What to Wear Today: A Simple System | FitCheck AI', description: 'Stop staring at a full closet. Use weather, occasion, and your real clothes to decide what to wear in minutes.' },
  { path: '/guides/cost-per-wear-calculator-explained', title: 'Cost Per Wear Explained (+ How to Track It) | FitCheck AI', description: 'What cost-per-wear means, how to calculate it, and how wardrobe analytics help you buy less and wear more.' },
  { path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on', title: 'Reduce Clothing Returns with Virtual Try-On | FitCheck AI', description: 'How AI virtual try-on helps you visualize purchases with clothes you own — and cut return-prone shopping mistakes.' },
]

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
