/**
 * Post-build IndexNow ping for instant indexing on Bing, Copilot, Seznam,
 * Naver and Yandex. Verification key file lives at
 * public/.well-known/indexnow/<key>.txt (committed) and the key at
 * public/indexnow-key.txt. Override with INDEXNOW_KEY.
 *
 * No-op when the key or sitemap is missing — local builds stay harmless.
 */
import { readFileSync, existsSync, writeFileSync, mkdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const dist = join(root, 'dist')
const publicDir = join(root, 'public')
const HOST = 'fitcheckaiapp.com'

function readKey() {
  if (process.env.INDEXNOW_KEY) return process.env.INDEXNOW_KEY.trim()
  const file = join(publicDir, 'indexnow-key.txt')
  if (existsSync(file)) return readFileSync(file, 'utf8').trim()
  return null
}

function extractUrls(sitemapPath) {
  if (!existsSync(sitemapPath)) return []
  const xml = readFileSync(sitemapPath, 'utf8')
  return [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]).slice(0, 1000)
}

async function main() {
  const key = readKey()
  if (!key) {
    console.log('[indexnow] No key (public/indexnow-key.txt or INDEXNOW_KEY) — skipping')
    return
  }

  // Ensure the verification file is in dist for Netlify publishing
  const wellKnown = join(dist, '.well-known', 'indexnow', `${key}.txt`)
  mkdirSync(dirname(wellKnown), { recursive: true })
  if (!existsSync(wellKnown)) writeFileSync(wellKnown, key, 'utf8')

  const urls = extractUrls(join(dist, 'sitemap.xml'))
  if (!urls.length) {
    console.log('[indexnow] No sitemap URLs found — skipping')
    return
  }

  const keyLocation = `https://${HOST}/.well-known/indexnow/${key}.txt`
  const body = { host: HOST, key, keyLocation, urlList: urls }

  try {
    const res = await fetch('https://api.indexnow.org/indexnow', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=utf-8' },
      body: JSON.stringify(body),
    })
    console.log(`[indexnow] Submitted ${urls.length} URLs — HTTP ${res.status}`)
    if (!res.ok) console.log('[indexnow] Response:', (await res.text()).slice(0, 300))
  } catch (err) {
    console.warn('[indexnow] Ping failed (non-fatal):', err.message)
  }
}

main()
