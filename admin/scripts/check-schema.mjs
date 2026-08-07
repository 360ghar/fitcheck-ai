#!/usr/bin/env node
/**
 * CI drift check for the OpenAPI-generated types.
 *
 * Regenerates `schema.d.ts` into a temp dir and diffs it against the checked
 * in copy. Exits 1 (CI failure) when they differ — the backend contract moved
 * and the admin app has not been regenerated.
 *
 * Exits 0 with a notice when `contracts/openapi.json` is missing.
 */
import { execSync } from 'node:child_process'
import { existsSync, mkdtempSync, readFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = fileURLToPath(new URL('..', import.meta.url))
const contract = fileURLToPath(new URL('../contracts/openapi.json', import.meta.url))
const current = fileURLToPath(new URL('../src/shared/api/schema.d.ts', import.meta.url))

if (!existsSync(contract)) {
  console.log('[check-schema] contracts/openapi.json not found — skipping drift check.')
  process.exit(0)
}
if (!existsSync(current)) {
  console.error('[check-schema] src/shared/api/schema.d.ts is missing. Run `npm run generate:api` and commit it.')
  process.exit(1)
}

const tmpDir = mkdtempSync(join(tmpdir(), 'fitcheck-admin-schema-'))
const tmpOut = join(tmpDir, 'schema.d.ts')
try {
  execSync(`npx --no-install openapi-typescript contracts/openapi.json -o "${tmpOut}"`, {
    cwd: root,
    stdio: 'inherit',
  })
} catch {
  console.error('[check-schema] codegen failed — is the contract valid OpenAPI?')
  rmSync(tmpDir, { recursive: true, force: true })
  process.exit(1)
}

const a = readFileSync(current, 'utf8').trim()
const b = readFileSync(tmpOut, 'utf8').trim()
rmSync(tmpDir, { recursive: true, force: true })

if (a !== b) {
  console.error(
    '[check-schema] DRIFT detected: src/shared/api/schema.d.ts is out of date. Run `npm run generate:api` and commit the result.',
  )
  process.exit(1)
}
console.log('[check-schema] generated types are up to date.')
