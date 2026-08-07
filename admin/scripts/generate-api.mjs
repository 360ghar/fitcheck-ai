#!/usr/bin/env node
/**
 * Regenerates `src/shared/api/schema.d.ts` from `contracts/openapi.json`
 * (published by the backend agent).
 *
 * Exits 0 with a notice when the contract file is missing so local/CI runs
 * are not blocked while the backend work is in flight. Once it exists, this
 * runs the openapi-typescript CLI against the checked-in schema.
 */
import { execSync } from 'node:child_process'
import { existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const root = fileURLToPath(new URL('..', import.meta.url))
const contract = fileURLToPath(new URL('../contracts/openapi.json', import.meta.url))

if (!existsSync(contract)) {
  console.log(
    '[generate-api] contracts/openapi.json not found — skipping codegen (backend contract not published yet).',
  )
  process.exit(0)
}

console.log('[generate-api] regenerating src/shared/api/schema.d.ts from contracts/openapi.json…')
execSync('npx --no-install openapi-typescript contracts/openapi.json -o src/shared/api/schema.d.ts', {
  cwd: root,
  stdio: 'inherit',
})
console.log('[generate-api] done.')
