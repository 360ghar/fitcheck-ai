#!/usr/bin/env node
/**
 * Bundle-size budget check (spec §9 performance).
 *
 * Parses `dist/assets/*.js` after `npm run build`, computes minified + gzip
 * sizes per chunk, and enforces a budget on the INITIAL (index) chunk:
 *
 *   - > 320 KB gzip  → hard fail (exit 1, breaks CI)
 *   - > 250 KB gzip  → warn (printed, exit 0)
 *
 * The initial chunk is the entry referenced by dist/index.html. Every chunk
 * is printed as a table so regressions are visible in CI logs.
 *
 * Usage: npm run build && npm run check:bundle
 */
import { readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { gzipSync } from 'node:zlib'

const WARN_KB = 250
const FAIL_KB = 320

const root = fileURLToPath(new URL('..', import.meta.url))
const distDir = join(root, 'dist')
const assetsDir = join(distDir, 'assets')

function fail(message) {
  console.error(`[check-bundle] ${message}`)
  process.exit(1)
}

/** @type {string[]} */
let files
try {
  files = /** @type {string[]} */ (readdirSync(assetsDir)).filter((name) => name.endsWith('.js'))
} catch {
  fail(`dist/assets not found — run \`npm run build\` first. (cwd assets: ${assetsDir})`)
}

if (files.length === 0) {
  fail('dist/assets contains no .js chunks — did the build emit them?')
}

// The entry chunk is the one index.html references as a module script.
/** @type {string} */
let indexHtml
try {
  indexHtml = /** @type {string} */ (readFileSync(join(distDir, 'index.html'), 'utf8'))
} catch {
  indexHtml = ''
}
const entryMatch = indexHtml.match(/<script type="module" crossorigin src="([^"]+)">/)
const entryPath = entryMatch?.[1]
const entryName = entryPath ? entryPath.split('/').pop() : 'index-*.js'
const entryFiles = entryName.includes('*')
  ? files.filter((name) => /^index-[a-zA-Z0-9_-]+\.js$/.test(name))
  : files.filter((name) => name === entryName)

if (entryFiles.length === 0) {
  fail(`could not locate the initial chunk (${entryName}) in dist/assets.`)
}

/** Format KB with one decimal. */
function kb(bytes) {
  return (bytes / 1024).toFixed(1)
}

const rows = files.map((name) => {
  const raw = readFileSync(join(assetsDir, name))
  const gz = gzipSync(raw, { level: 9 }).length
  return { name, raw: raw.length, gz }
})
rows.sort((a, b) => b.raw - a.raw)

const isEntry = (/** @type {string} */ name) => entryFiles.includes(name)
const entryGzBytes = Math.max(
  ...entryFiles.map((name) => rows.find((r) => r.name === name)?.gz ?? 0),
)
const entryRawBytes = Math.max(
  ...entryFiles.map((name) => rows.find((r) => r.name === name)?.raw ?? 0),
)

// ── Report ─────────────────────────────────────────────────────────────────
const label = (/** @type {string} */ name) => (isEntry(name) ? '  ← initial' : '')
console.log('[check-bundle] production chunk sizes (minified / gzip):')
console.log(
  rows
    .map(
      (row) =>
        `  ${row.name.padEnd(48)} ${kb(row.raw).padStart(8)} KB  ${kb(row.gz).padStart(7)} KB${label(row.name)}`,
    )
    .join('\n'),
)
console.log(
  `[check-bundle] initial chunk: ${kb(entryRawBytes)} KB minified / ${kb(entryGzBytes)} KB gzip (budget: ${WARN_KB} KB warn / ${FAIL_KB} KB fail)`,
)

if (entryGzBytes / 1024 > FAIL_KB) {
  fail(
    `initial chunk is ${kb(entryGzBytes)} KB gzip — over the ${FAIL_KB} KB hard budget. Split heavy imports (recharts, cmdk, i18next) into lazy chunks.`,
  )
}
if (entryGzBytes / 1024 > WARN_KB) {
  console.warn(
    `[check-bundle] ⚠ initial chunk is ${kb(entryGzBytes)} KB gzip — over the ${WARN_KB} KB soft budget. Consider code-splitting before this grows further.`,
  )
  process.exit(0)
}
console.log('[check-bundle] initial chunk within budget.')
