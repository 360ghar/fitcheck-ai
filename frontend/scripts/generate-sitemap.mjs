/**
 * Build-time sitemap generator.
 * Writes public/sitemap.xml (and dist/sitemap.xml when dist exists).
 * Optionally merges published blog posts from the API.
 */
import { writeFileSync, mkdirSync, existsSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const SITE = 'https://fitcheckaiapp.com'
const today = new Date().toISOString().slice(0, 10)

const STATIC_ROUTES = [
  { path: '/', priority: '1.0', changefreq: 'weekly' },
  { path: '/features', priority: '0.9', changefreq: 'monthly' },
  { path: '/features/ai-wardrobe-extraction', priority: '0.9', changefreq: 'monthly' },
  { path: '/features/virtual-try-on', priority: '0.9', changefreq: 'monthly' },
  { path: '/features/ai-photoshoot-generator', priority: '0.9', changefreq: 'monthly' },
  { path: '/features/outfit-recommendations', priority: '0.9', changefreq: 'monthly' },
  { path: '/features/wardrobe-analytics', priority: '0.8', changefreq: 'monthly' },
  { path: '/about', priority: '0.7', changefreq: 'monthly' },
  { path: '/faq', priority: '0.8', changefreq: 'monthly' },
  { path: '/blog', priority: '0.8', changefreq: 'weekly' },
  { path: '/privacy', priority: '0.4', changefreq: 'yearly' },
  { path: '/terms', priority: '0.4', changefreq: 'yearly' },
  { path: '/best/virtual-closet-apps', priority: '0.9', changefreq: 'monthly' },
  { path: '/best/ai-outfit-planners', priority: '0.9', changefreq: 'monthly' },
  { path: '/compare/fitcheck-vs-acloset', priority: '0.85', changefreq: 'monthly' },
  { path: '/compare/fitcheck-vs-whering', priority: '0.85', changefreq: 'monthly' },
  { path: '/alternatives/acloset-alternatives', priority: '0.85', changefreq: 'monthly' },
  { path: '/for/busy-professionals', priority: '0.85', changefreq: 'monthly' },
  { path: '/for/content-creators', priority: '0.85', changefreq: 'monthly' },
  { path: '/for/festive-and-wedding-outfits', priority: '0.85', changefreq: 'monthly' },
  { path: '/guides/how-to-digitize-your-wardrobe', priority: '0.85', changefreq: 'monthly' },
  { path: '/guides/what-to-wear-today', priority: '0.85', changefreq: 'monthly' },
  { path: '/guides/cost-per-wear-calculator-explained', priority: '0.8', changefreq: 'monthly' },
  { path: '/guides/how-to-reduce-clothing-returns-with-virtual-try-on', priority: '0.8', changefreq: 'monthly' },
]

function escapeXml(s) {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function urlEntry({ loc, lastmod, changefreq, priority, image }) {
  let xml = `  <url>
    <loc>${escapeXml(loc)}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>${changefreq}</changefreq>
    <priority>${priority}</priority>`
  if (image) {
    xml += `
    <image:image>
      <image:loc>${escapeXml(image.loc)}</image:loc>
      <image:title>${escapeXml(image.title)}</image:title>
    </image:image>`
  }
  xml += `
  </url>`
  return xml
}

async function fetchBlogSlugs() {
  const base =
    process.env.SITEMAP_API_URL ||
    process.env.VITE_API_URL ||
    process.env.VITE_API_BASE_URL ||
    'https://fitcheck-backend.railway.app'

  const posts = []
  try {
    let page = 1
    let totalPages = 1
    while (page <= totalPages && page <= 20) {
      const res = await fetch(
        `${base.replace(/\/$/, '')}/api/v1/blog/posts?page=${page}&page_size=50`,
        { headers: { Accept: 'application/json' } }
      )
      if (!res.ok) break
      const json = await res.json()
      const data = json.data || json
      const list = data.posts || data.items || []
      for (const p of list) {
        if (p.slug) {
          posts.push({
            slug: p.slug,
            lastmod: (p.updated_at || p.date || today).toString().slice(0, 10),
          })
        }
      }
      totalPages = data.total_pages || data.totalPages || 1
      page += 1
    }
  } catch (err) {
    console.warn('[sitemap] Blog fetch skipped:', err.message)
  }
  return posts
}

async function main() {
  const blogPosts = await fetchBlogSlugs()

  const entries = [
    urlEntry({
      loc: `${SITE}/`,
      lastmod: today,
      changefreq: 'weekly',
      priority: '1.0',
      image: {
        loc: `${SITE}/og-default.jpg`,
        title: 'FitCheck AI - AI Virtual Closet & Outfit Planner',
      },
    }),
    ...STATIC_ROUTES.filter((r) => r.path !== '/').map((r) =>
      urlEntry({
        loc: `${SITE}${r.path}`,
        lastmod: today,
        changefreq: r.changefreq,
        priority: r.priority,
      })
    ),
    ...blogPosts.map((p) =>
      urlEntry({
        loc: `${SITE}/blog/${p.slug}`,
        lastmod: p.lastmod,
        changefreq: 'monthly',
        priority: '0.7',
      })
    ),
  ]

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
${entries.join('\n')}
</urlset>
`

  const targets = [join(root, 'public', 'sitemap.xml')]
  if (existsSync(join(root, 'dist'))) {
    targets.push(join(root, 'dist', 'sitemap.xml'))
  }

  for (const file of targets) {
    mkdirSync(dirname(file), { recursive: true })
    writeFileSync(file, xml, 'utf8')
    console.log(`[sitemap] Wrote ${file} (${entries.length} URLs, ${blogPosts.length} blog)`)
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
