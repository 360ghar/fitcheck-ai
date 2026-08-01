/**
 * Post-build: writes LLM-facing artifacts from the shared route registry:
 *  - dist/llms.txt        (copy of the maintained public/llms.txt)
 *  - dist/llms-full.txt   (llms.txt + page summaries for context-window use)
 *  - dist/<path>.md       (markdown mirror per public page, per llms.txt spec)
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { SITE, SEO_ROUTES, urlForPath } from './seo-content.mjs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const dist = join(root, 'dist')
const publicDir = join(root, 'public')

function escapeMd(text) {
  return String(text).replace(/\|/g, '\\|').trim()
}

function routeMarkdown(route) {
  const lines = [
    `# ${escapeMd(route.title)}`,
    '',
    `> ${escapeMd(route.description)}`,
    '',
    `Canonical: ${urlForPath(route.path)}`,
    '',
  ]
  const points = route.keyPoints || []
  if (points.length) {
    lines.push('## Key points')
    for (const point of points) lines.push(`- ${escapeMd(point)}`)
    lines.push('')
  }
  return lines.join('\n')
}

function main() {
  mkdirSync(dist, { recursive: true })

  const basePath = join(publicDir, 'llms.txt')
  if (!existsSync(basePath)) {
    console.error('[llms] public/llms.txt missing — aborting')
    process.exit(1)
  }
  const base = readFileSync(basePath, 'utf8')

  // dist/llms.txt — plain copy so crawlers get the same file as public/
  writeFileSync(join(dist, 'llms.txt'), base, 'utf8')

  // llms-full.txt — base + summaries of every indexed page
  const sections = SEO_ROUTES.map(routeMarkdown)
  const full = `${base.trimEnd()}\n\n# Page summaries\n\n${sections.join('\n')}`
  writeFileSync(join(dist, 'llms-full.txt'), full, 'utf8')

  // Per-page markdown mirrors
  let mdCount = 0
  for (const route of SEO_ROUTES) {
    const rel = route.path === '/' ? 'index.md' : `${route.path.replace(/^\//, '')}.md`
    const file = join(dist, rel)
    mkdirSync(dirname(file), { recursive: true })
    writeFileSync(file, routeMarkdown(route), 'utf8')
    mdCount += 1
  }

  console.log(
    `[llms] Wrote llms.txt, llms-full.txt and ${mdCount} .md mirrors (${SEO_ROUTES.length} routes)`
  )
}

main()
