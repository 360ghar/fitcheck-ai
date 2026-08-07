#!/usr/bin/env node
/**
 * Prints the sha256 hash of the inline theme script in index.html.
 *
 * netlify.toml pins the pre-paint theme script with a static CSP hash
 * (script-src 'self' 'sha256-…'). The script is byte-stable across builds
 * (Vite does not minify inline scripts), so the hash only changes when the
 * script itself is edited. Run this after any edit and update netlify.toml.
 *
 * Usage: node scripts/csp-hash.mjs
 */
import { createHash } from 'node:crypto'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const indexPath = fileURLToPath(new URL('../index.html', import.meta.url))
const html = readFileSync(indexPath, 'utf8')

const match = html.match(/<script>([\s\S]*?)<\/script>/)
if (!match) {
  console.error('No inline <script> block found in index.html')
  process.exit(1)
}

const script = match[1]
const hash = createHash('sha256').update(script, 'utf8').digest('base64')
console.log(`sha256-${hash}`)
