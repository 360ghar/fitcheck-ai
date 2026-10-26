#!/usr/bin/env node
/**
 * App Store Connect API client. No dependencies — node:crypto and fetch only.
 *
 * Auth is a JWT signed with an App Store Connect API key (ES256 / P-256).
 * Apple caps a token's lifetime at 20 minutes, so this mints a fresh one every
 * 15 and caches it.
 *
 * Credentials resolve in this order:
 *   1. ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_PATH from the real environment
 *   2. the same three names from `scripts/.env.asc` (gitignored)
 *   3. the convention the App Store Connect tooling already uses on this
 *      machine: `~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8` plus
 *      `~/.appstoreconnect/issuer_id`, taking the key id from the file name.
 *
 * Step 3 exists because the key is already there. Requiring a copy of a
 * credential into the repo to run a read-only report would be a worse default
 * than discovering the standard location.
 *
 * The .p8 is a credential. It is read, used to sign, and never logged; this
 * module has no code path that prints it or the token it produces.
 */

import { createPrivateKey, sign as signPayload } from 'node:crypto';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { homedir } from 'node:os';

const BASE = 'https://api.appstoreconnect.apple.com';
const AUDIENCE = 'appstoreconnect-v1';
/** Apple rejects anything over 20 minutes. Stay clear of the boundary. */
const TOKEN_LIFETIME_SECONDS = 15 * 60;

const HERE = dirname(fileURLToPath(import.meta.url));
export const ROOT = join(HERE, '..', '..');
export const STORE_DIR = join(ROOT, 'store', 'asc');

function base64url(value) {
  return Buffer.from(value).toString('base64url');
}

/**
 * Signs a JWT the way App Store Connect expects.
 *
 * The one non-obvious part: JOSE requires the ECDSA signature as raw R||S, and
 * Node defaults to DER for ECDSA. Without `dsaEncoding: 'ieee-p1363'` the
 * signature is well-formed DER and Apple rejects it with a 401 that says
 * nothing about encoding.
 */
export function createToken({ keyId, issuerId, privateKey }) {
  const issuedAt = Math.floor(Date.now() / 1000);
  const header = { alg: 'ES256', kid: keyId, typ: 'JWT' };
  const payload = {
    iss: issuerId,
    iat: issuedAt,
    exp: issuedAt + TOKEN_LIFETIME_SECONDS,
    aud: AUDIENCE,
  };

  const signingInput = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const signature = signPayload('sha256', Buffer.from(signingInput), {
    key: privateKey,
    dsaEncoding: 'ieee-p1363',
  });

  return `${signingInput}.${signature.toString('base64url')}`;
}

/**
 * Loads a gitignored env file without a dependency. Values already present in
 * the real environment always win, so a one-off override works.
 */
export function loadEnvFile(path = join(HERE, '.env.asc'), env = process.env) {
  const out = { ...env };
  if (!existsSync(path)) return out;
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    const name = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"'))
      || (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!(name in env)) out[name] = value;
  }
  return out;
}

export function redact(value) {
  if (!value) return '(unset)';
  if (value.length <= 6) return '*'.repeat(value.length);
  return `${value.slice(0, 4)}…${value.slice(-2)}`;
}

/**
 * Resolves the three credentials, with the standard macOS location as the
 * fallback. Returns { keyId, issuerId, keyPath, source } or throws with a
 * message that names which of the three is missing.
 */
export function credentialsFromEnv(env = loadEnvFile()) {
  let keyId = env.ASC_KEY_ID;
  let issuerId = env.ASC_ISSUER_ID;
  let keyPath = env.ASC_KEY_PATH;
  let source = 'environment';

  if (!keyId || !issuerId || !keyPath) {
    const dir = join(homedir(), '.appstoreconnect');
    const keyDir = join(dir, 'private_keys');
    if (existsSync(keyDir)) {
      const keys = readdirSync(keyDir).filter((name) => /^AuthKey_[A-Z0-9]+\.p8$/.test(name));
      if (keys.length === 1) {
        keyId = keyId || keys[0].slice('AuthKey_'.length, -'.p8'.length);
        keyPath = keyPath || join(keyDir, keys[0]);
        source = '~/.appstoreconnect';
      } else if (keys.length > 1) {
        throw new Error(
          `Found ${keys.length} keys in ${keyDir}. Set ASC_KEY_ID and ASC_KEY_PATH to choose one.`,
        );
      }
    }
    const issuerFile = join(dir, 'issuer_id');
    if (!issuerId && existsSync(issuerFile)) {
      issuerId = readFileSync(issuerFile, 'utf8').trim();
    }
  }

  const missing = [
    !keyId && 'ASC_KEY_ID (or a single AuthKey_*.p8 in ~/.appstoreconnect/private_keys)',
    !issuerId && 'ASC_ISSUER_ID (or ~/.appstoreconnect/issuer_id)',
    !keyPath && 'ASC_KEY_PATH',
  ].filter(Boolean);
  if (missing.length > 0) {
    throw new Error(`Missing App Store Connect credentials: ${missing.join(', ')}`);
  }
  if (!existsSync(keyPath)) {
    throw new Error(`ASC_KEY_PATH does not exist: ${keyPath}`);
  }
  return { keyId, issuerId, keyPath, source };
}

/**
 * Creates a client. `dryRun` records writes instead of sending them, so every
 * command has a safe default that still prints the exact calls it would make.
 */
export function createClient({ keyId, issuerId, keyPath, log = () => {}, dryRun = false }) {
  const privateKey = createPrivateKey(readFileSync(keyPath));
  let token = null;
  let mintedAt = 0;

  const authToken = () => {
    const now = Math.floor(Date.now() / 1000);
    if (!token || now - mintedAt > TOKEN_LIFETIME_SECONDS - 60) {
      token = createToken({ keyId, issuerId, privateKey });
      mintedAt = now;
    }
    return token;
  };

  const calls = [];

  async function request(method, path, { body, query } = {}) {
    const url = new URL(BASE + path);
    if (query) {
      for (const [name, value] of Object.entries(query)) {
        if (value !== undefined && value !== null) url.searchParams.set(name, value);
      }
    }
    const label = `${method} ${url.pathname}${url.search}`;
    calls.push({ method, path: url.pathname + url.search, body });

    if (dryRun && method !== 'GET') {
      log(`  [dry-run] ${label}`);
      if (body) log(`            ${JSON.stringify(body).slice(0, 600)}`);
      return { data: [], _dryRun: true };
    }
    log(`  ${label}`);

    for (let attempt = 0; attempt < 4; attempt += 1) {
      const response = await fetch(url, {
        method,
        headers: {
          Authorization: `Bearer ${authToken()}`,
          'Content-Type': 'application/json',
        },
        body: body === undefined ? undefined : JSON.stringify(body),
      });

      if (response.status === 429) {
        const retryAfter = Number(response.headers.get('retry-after') || '2');
        await new Promise((resolve) => setTimeout(resolve, retryAfter * 1000));
        continue;
      }

      const text = await response.text();
      const json = text ? JSON.parse(text) : {};
      if (!response.ok) {
        const detail = (json.errors ?? [])
          .map((error) => `${error.code}: ${error.detail ?? error.title}`)
          .join('; ');
        const error = new Error(`${method} ${url.pathname} → ${response.status} ${detail}`);
        error.status = response.status;
        error.payload = json;
        throw error;
      }
      return json;
    }
    throw new Error(`${method} ${url.pathname} → rate limited after 4 attempts`);
  }

  return {
    keyId,
    dryRun,
    calls,
    get: (path, options) => request('GET', path, options),
    post: (path, body) => request('POST', path, { body }),
    patch: (path, body) => request('PATCH', path, { body }),
    delete: (path) => request('DELETE', path),
    /** Walks every page. A `limit` already in `path` is respected, not doubled. */
    async getAll(path, { query, limit = 200 } = {}) {
      const items = [];
      let cursor;
      const hasLimit = /[?&]limit=/.test(path);
      do {
        const params = [];
        if (!hasLimit) params.push(`limit=${limit}`);
        if (cursor) params.push(`cursor=${cursor}`);
        const separator = path.includes('?') ? '&' : '?';
        const url = params.length > 0 ? `${path}${separator}${params.join('&')}` : path;
        const json = await request('GET', url, { query });
        items.push(...(json.data ?? []));
        cursor = json.links?.next ? new URL(json.links.next).searchParams.get('cursor') : null;
      } while (cursor);
      return items;
    },
  };
}

/**
 * Resolves the app record by bundle id and asserts it matches the configured
 * numeric id. Writing to the wrong app is unrecoverable in the obvious way
 * (the copy lands on someone else's listing), so this is a hard check.
 */
export async function findApp(client, { appId, bundleId }) {
  const json = await client.get('/v1/apps', { query: { 'filter[bundleId]': bundleId } });
  const apps = json.data ?? [];
  if (apps.length === 0) throw new Error(`No app found for bundle id ${bundleId}`);
  const app = apps[0];
  if (appId && String(app.id) !== String(appId)) {
    throw new Error(
      `store/asc/app.json says appId ${appId}, but ${bundleId} resolves to ${app.id}. `
      + 'Fix app.json before writing anything.',
    );
  }
  return app;
}

/** Reads a JSON file from store/asc. */
export function readStoreFile(name) {
  return JSON.parse(readFileSync(join(STORE_DIR, name), 'utf8'));
}
