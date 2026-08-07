/**
 * Compute the sha256 CSP hashes for the inline <script> blocks in index.html.
 *
 * Why this exists: netlify.toml ships an ACTIVE Content-Security-Policy that
 * pins the six inline scripts (the pre-hydration theme script + five JSON-LD
 * data blocks) by sha256 instead of 'unsafe-inline'. These blocks are
 * byte-stable across builds (prerender only edits title/meta/canonical/og and
 * fills #root; Vite does not minify inline scripts), so static hashes work.
 *
 * If you edit index.html's inline scripts, re-run this and paste the new
 * script-src hash list into netlify.toml, or the theme script / JSON-LD will
 * be blocked on the next deploy.
 *
 *   node scripts/csp-hashes.mjs            # print hashes
 *   node scripts/csp-hashes.mjs --check    # exit 1 if they no longer match netlify.toml
 */
import { readFileSync } from 'node:fs'
import { createHash } from 'node:crypto'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const check = process.argv.includes('--check')

const html = readFileSync(join(root, 'index.html'), 'utf8')

// Inline scripts: a <script> with no src attribute. Captures the exact bytes
// between the tags (CSP hashes the content including whitespace/indentation).
const re = /<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g
const hashes = []
let m
while ((m = re.exec(html)) !== null) {
  const content = m[1]
  const hash = createHash('sha256').update(content, 'utf8').digest('base64')
  const kind = m[0].includes('ld+json') ? 'JSON-LD' : 'THEME'
  hashes.push({ kind, hash: `sha256-${hash}` })
}

if (check) {
  const toml = readFileSync(join(root, 'netlify.toml'), 'utf8')
  const missing = hashes.filter((h) => !toml.includes(h.hash))
  if (missing.length) {
    console.error('CSP hashes out of date in netlify.toml. Re-run without --check and update script-src:')
    for (const h of missing) console.error(`  ${h.kind}: ${h.hash}`)
    process.exit(1)
  }
  console.log(`OK: all ${hashes.length} inline-script hashes are present in netlify.toml`)
} else {
  console.log(`# script-src hashes (${hashes.length} inline blocks) — paste into netlify.toml:`)
  console.log(hashes.map((h) => `'${h.hash}'`).join(' '))
}
