#!/usr/bin/env node
/**
 * Asset publishing for FitCheck AI: bytes into the App Asset Library, then
 * placements that decide where those bytes appear.
 *
 *   node scripts/asc/media.mjs status
 *   node scripts/asc/media.mjs upload --manifest store/creative/manifest.json
 *   node scripts/asc/media.mjs upload --manifest store/creative/manifest.json --apply
 *   node scripts/asc/media.mjs sync  --manifest store/creative/manifest.json
 *
 * Everything is dry by default and `--apply` is required to write.
 *
 * ---------------------------------------------------------------------------
 * Why this is not a one-request upload
 * ---------------------------------------------------------------------------
 * App Store Connect replaced `appScreenshotSets` + `appScreenshots` with the
 * App Asset Library. The new flow is three requests plus N part uploads:
 *
 *   1. POST   /v1/appAssetLibraryImages      reserve a slot, returns asset id
 *                                            and `uploadOperations[]`
 *   2. PUT    <operation.url>                the raw bytes, one request per
 *                                            operation, with the operation's
 *                                            own requestHeaders
 *   3. PATCH  /v1/appAssetLibraryImages/{id} { uploaded: true } commits it
 *
 * Three details differ from the deprecated set-based flow and each one costs an
 * afternoon if guessed:
 *
 *   - The commit takes `uploaded: true` alone. There is no checksum field, and
 *     sending the old `sourceFileChecksum` is accepted but ignored.
 *   - The asset relates to `appAssetLibraries`, not to a screenshot set. One
 *     library holds every image for the app; the same bytes can back a main
 *     page screenshot, a custom product page frame and an in-app event card.
 *   - Processing state is `attributes.state`, not `assetDeliveryState.state`.
 *     A finished asset reports PREPARE_FOR_SUBMISSION (editable parent) or
 *     APPROVED (live parent) — never COMPLETE — so "wait for COMPLETE" hangs
 *     forever on an asset that finished seconds ago.
 *
 * ---------------------------------------------------------------------------
 * Why placements are separate from uploads
 * ---------------------------------------------------------------------------
 * The manifest describes pixels. It does not say which product page a frame
 * belongs to, because the same frame legitimately belongs to several: the
 * "virtual try on" frame is frame 3 of the main page and frame 1 of the
 * try-on custom product page. Uploading is keyed by content hash and happens
 * once; placing is keyed by target and happens per surface. `grow.mjs` owns the
 * targets; this module owns the bytes and the placement primitive.
 */

import { createHash } from 'node:crypto';
import { closeSync, existsSync, openSync, readFileSync, readSync, statSync } from 'node:fs';
import { basename, isAbsolute, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

import { ROOT, createClient, credentialsFromEnv, findApp, readStoreFile } from './asc.mjs';
import { loadLocales } from './plan.mjs';

// ---------------------------------------------------------------------------
// Manifest
// ---------------------------------------------------------------------------

export const DEFAULT_MANIFEST = join(ROOT, 'store', 'creative', 'manifest.json');

/**
 * How many images upload at once.
 *
 * Each file is 1-2 MB and the run is transfer-bound, so a single stream spends
 * most of its time waiting. Four keeps App Store Connect well clear of rate
 * limits while cutting a 705-asset run from about eight hours to about two.
 * Override with `MEDIA_UPLOAD_CONCURRENCY` when a smaller library makes it moot.
 */
export const UPLOAD_CONCURRENCY = Number(process.env.MEDIA_UPLOAD_CONCURRENCY ?? 4) || 4;

/** Placement type per manifest kind. `null` means library-only, no placement. */
export const PLACEMENT_TYPES = {
  frame: 'APP_SCREENSHOT',
  header: 'PRODUCT_PAGE_HEADER_ASSET',
  search: 'APP_STORE_SEARCH_RESULTS_ASSET',
  previewPoster: null,
  eventCard: 'EVENT_CARD_ASSET',
  eventDetails: 'EVENT_DETAILS_PAGE_ASSET',
};

/** Upload category per manifest kind. Apple validates these against the type. */
export const CATEGORIES = {
  frame: 'APP_SCREENSHOTS_AND_PREVIEWS',
  previewPoster: 'APP_SCREENSHOTS_AND_PREVIEWS',
  header: 'CREATIVE_ASSETS',
  search: 'CREATIVE_ASSETS',
  eventCard: 'CREATIVE_ASSETS',
  eventDetails: 'CREATIVE_ASSETS',
};

/** Apple's per-group cap. A full inherited set leaves no room for new frames. */
export const MAX_PER_GROUP = 10;

/**
 * Manifest kind aliases.
 *
 * The render pipeline names screenshots `screenshot`, because that is what they
 * are on the device; this module calls the same thing a `frame`, because that is
 * what it is on a product page. Both are correct, so both are accepted rather
 * than forcing one side to break its own vocabulary. So is the pipeline's habit
 * of tagging a 1320x2868 image `APP_IPHONE_67`: the label is advisory and the
 * dimensions decide, which is why the cross-check compares groups and not names.
 */
const KIND_ALIASES = {
  screenshot: 'frame',
  screenshots: 'frame',
  frames: 'frame',
  phone: 'frame',
  pageHeader: 'header',
  productPageHeader: 'header',
  searchCreative: 'search',
  searchResults: 'search',
  poster: 'previewPoster',
  preview: 'previewPoster',
  event_card: 'eventCard',
  event_details: 'eventDetails',
};

/**
 * Reads the creative manifest produced by the render pipeline and resolves
 * every entry to an absolute path.
 *
 * The contract is fixed: `entries[]` of `{ locale, kind, frame, displayType,
 * path, width, height, bytes, sha256 }`. Anything missing is a hard error
 * rather than a default, because a manifest with a silent default publishes
 * the wrong picture to a real storefront.
 */
export function loadManifest(path = DEFAULT_MANIFEST) {
  if (!existsSync(path)) return null;
  const raw = JSON.parse(readFileSync(path, 'utf8'));
  const entries = Array.isArray(raw.entries) ? raw.entries : [];
  const problems = [];
  const seen = new Set();

  const resolved = entries.map((entry, index) => {
    const where = `entries[${index}]`;
    const kind = KIND_ALIASES[entry.kind] ?? entry.kind;
    for (const field of ['locale', 'path', 'width', 'height']) {
      if (entry[field] === undefined || entry[field] === null) {
        problems.push(`${where}: missing ${field}`);
      }
    }
    if (kind && !(kind in PLACEMENT_TYPES)) {
      problems.push(`${where}: unknown kind "${entry.kind}" (expected one of ${Object.keys(PLACEMENT_TYPES).join('|')})`);
    }
    const filePath = isAbsolute(entry.path) ? entry.path : join(ROOT, entry.path);
    if (!existsSync(filePath)) {
      problems.push(`${where}: file not found: ${entry.path}`);
    } else if (entry.sha256 && sha256File(filePath) !== entry.sha256) {
      // A stale hash means the manifest describes bytes that are no longer on
      // disk. Uploading it would publish artwork nobody rendered.
      problems.push(`${where}: sha256 does not match ${entry.path} — re-render or re-hash`);
    }

    // The manifest is the contract, so a path that disagrees with its own
    // dimensions is a render bug, not an acceptable variance.
    const key = `${entry.locale}:${kind}:${entry.frame ?? '-'}:${entry.displayType ?? '-'}`;
    if (seen.has(key)) problems.push(`${where}: duplicate slot ${key}`);
    seen.add(key);

    return { ...entry, kind, filePath };
  });

  return { ...raw, entries: resolved, problems, source: path };
}

/** Content hash. This is the asset's identity; the path is not. */
export function sha256File(filePath) {
  return createHash('sha256').update(readFileSync(filePath)).digest('hex');
}

// ---------------------------------------------------------------------------
// Image inspection
// ---------------------------------------------------------------------------

/**
 * Reads header dimensions and alpha from the file itself.
 *
 * This exists so a wrong-sized or transparent PNG fails here, with a named
 * problem, instead of after reserving an asset and pushing a megabyte to
 * Apple's upload host. Dimension and alpha mismatches are rejected at commit
 * time with an error that names neither the file nor the expected size.
 *
 * PNG: signature, then IHDR at byte 16 (width, height, bitDepth, colorType).
 * Color type 4 is gray+alpha and 6 is RGBA; type 3 is palette, which may carry
 * a tRNS chunk and is therefore treated as suspect rather than as opaque.
 *
 * JPEG: walk the marker segments to the first start-of-frame, which carries
 * height then width. JPEG has no alpha channel.
 */
export function probeImage(filePath) {
  const head = readFileSync(filePath);
  if (
    head.length > 26
    && head[0] === 0x89 && head[1] === 0x50 && head[2] === 0x4e && head[3] === 0x47
  ) {
    const width = head.readUInt32BE(16);
    const height = head.readUInt32BE(20);
    const bitDepth = head[24];
    const colorType = head[25];
    return {
      format: 'png',
      width,
      height,
      bitDepth,
      colorType,
      hasAlpha: colorType === 4 || colorType === 6,
      suspiciousAlpha: colorType === 3,
    };
  }
  if (head.length > 4 && head[0] === 0xff && head[1] === 0xd8) {
    let offset = 2;
    while (offset + 9 < head.length) {
      if (head[offset] !== 0xff) { offset += 1; continue; }
      const marker = head[offset + 1];
      const length = head.readUInt16BE(offset + 2);
      // SOF0..SOF15, excluding DHT (C4), DAC (CC) and JPG (C8).
      if (marker >= 0xc0 && marker <= 0xcf && ![0xc4, 0xcc, 0xc8].includes(marker)) {
        return {
          format: 'jpeg',
          height: head.readUInt16BE(offset + 5),
          width: head.readUInt16BE(offset + 7),
          hasAlpha: false,
          suspiciousAlpha: false,
        };
      }
      offset += 2 + length;
    }
    return { format: 'jpeg', width: null, height: null, hasAlpha: false, suspiciousAlpha: false };
  }
  return { format: 'unknown', width: null, height: null, hasAlpha: false, suspiciousAlpha: false };
}

// ---------------------------------------------------------------------------
// Placement catalog
// ---------------------------------------------------------------------------

/**
 * Reads the live placement catalog. Apple publishes the authority on which
 * placement types exist, which groups each accepts and what pixel bounds each
 * group allows — so a typo in a type name becomes "here are the real names"
 * instead of a 400 that repeats the bad name back.
 */
export async function loadCatalog(client) {
  const ref = await client.get('/v1/appAssetLibraryRefData');
  const datum = ref?.data?.[0]?.attributes ?? {};
  return {
    groups: datum.placementProfileGroups ?? [],
    types: datum.placementTypes ?? [],
    features: datum.features ?? [],
    specs: datum.imageSpecs ?? [],
    displayClasses: datum.displayClasses ?? [],
  };
}

/**
 * The App Store Connect display-type label each placement group corresponds to.
 *
 * Apple's manifest-visible names (`APP_IPHONE_69`) do not appear anywhere in
 * the API; the API speaks only in groups (`IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE`).
 * Only the entries that are certain are listed. An unlisted label is not an
 * error — the dimensions decide the group — it only means the cross-check is
 * skipped for that entry.
 */
export const DISPLAY_TYPE_GROUPS = {
  APP_IPHONE_69: 'IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE',
  APP_IPHONE_67: 'IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE',
  APP_IPHONE_65: 'IPHONE_FACE_ID_LARGE_PROFILE',
  APP_IPHONE_61: 'IPHONE_FACE_ID_MEDIUM_PROFILE',
  APP_IPHONE_55: 'IPHONE_HOME_BUTTON_LARGE_PROFILE',
  APP_IPHONE_47: 'IPHONE_HOME_BUTTON_MEDIUM_PROFILE',
  APP_IPHONE_40: 'IPHONE_HOME_BUTTON_40_PROFILE',
  APP_IPHONE_35: 'IPHONE_HOME_BUTTON_35_PROFILE',
  APP_IPAD_13: 'IPAD_13_PROFILE',
  APP_IPAD_PRO_3GEN_129: 'IPAD_129_PROFILE',
  APP_IPAD_PRO_129: 'IPAD_129_PROFILE',
  APP_IPAD_PRO_11: 'IPAD_11_PROFILE',
  APP_IPAD_PRO_105: 'IPAD_105_PROFILE',
  APP_IPAD_97: 'IPAD_97_PROFILE',
  APP_IPHONE_DUO: 'IPHONE_DUO_PROFILE',
};

/**
 * The group a manifest's display-type label claims, or undefined when the label
 * cannot mean anything for this placement type.
 *
 * Only screenshots are device-shaped. A product page header (3840x1646) and a
 * search creative (3840x2160) live in `DEFAULT_PROFILE` regardless of which
 * device the manifest tagged them with, so cross-checking their label against a
 * device group would reject every correct manifest.
 */
function expectGroup(placementType, displayType) {
  if (placementType !== 'APP_SCREENSHOT' || !displayType) return undefined;
  return DISPLAY_TYPE_GROUPS[displayType];
}

/**
 * Resolves the placement group for one file.
 *
 * Dimensions are authoritative: Apple's `imageSpecs` give each group's allowed
 * pixel bounds, and for every size this app ships exactly one group matches.
 * The display-type label is then cross-checked, so a manifest that labels a
 * 1320x2868 frame `APP_IPHONE_65` fails loudly instead of publishing it to the
 * 6.5" shelf where it will be rejected or, worse, accepted and letterboxed.
 */
export function resolveGroup(catalog, { placementType, width, height, displayType }) {
  const type = catalog.types.find((entry) => entry.placementTypeId === placementType);
  if (!type) {
    return {
      error: `unknown placement type "${placementType}"; Apple exposes ${catalog.types
        .map((t) => t.placementTypeId).join(', ')}`,
    };
  }

  const specById = new Map(catalog.specs.map((spec) => [spec.specId, spec]));
  const candidates = [];
  for (const mapping of type.specMappings ?? []) {
    const fits = (mapping.specs ?? []).some((specId) => {
      const dimensions = specById.get(specId)?.dimensions;
      if (!dimensions) return false;
      return width >= dimensions.minWidth && width <= dimensions.maxWidth
        && height >= dimensions.minHeight && height <= dimensions.maxHeight;
    });
    if (fits) candidates.push(mapping.placementGroupId);
  }

  if (candidates.length === 0) {
    const bounds = (type.specMappings ?? []).flatMap((mapping) => (mapping.specs ?? []).map((id) => {
      const dimensions = specById.get(id)?.dimensions;
      return dimensions
        ? `${dimensions.minWidth}x${dimensions.minHeight}..${dimensions.maxWidth}x${dimensions.maxHeight}`
        : '?';
    }));
    return {
      error: `${placementType} has no group accepting ${width}x${height}; allowed ranges: ${[...new Set(bounds)].join(' ')}`,
    };
  }
  if (candidates.length === 1) {
    const expected = expectGroup(placementType, displayType);
    if (expected && expected !== candidates[0]) {
      return {
        error: `manifest labels this ${width}x${height} file "${displayType}", but those dimensions only fit `
          + `${candidates[0]}. Fix the manifest's displayType.`,
      };
    }
    return { group: candidates[0] };
  }

  const expected = expectGroup(placementType, displayType);
  if (expected && candidates.includes(expected)) return { group: expected };
  return {
    error: `${width}x${height} fits several groups for ${placementType}: ${candidates.join(', ')}; `
      + `set displayType to one of the matching labels`,
  };
}

// ---------------------------------------------------------------------------
// Library access
// ---------------------------------------------------------------------------

export async function libraryIdFor(client, appId) {
  const library = await client.get(`/v1/apps/${appId}/assetLibrary`);
  const id = library?.data?.id;
  if (!id) {
    throw new Error(
      'This app has no asset library. Open the app once in App Store Connect (any screenshots tab) '
      + 'and Apple provisions it.',
    );
  }
  return id;
}

/**
 * Every image in the library, indexed by `referenceName`.
 *
 * Assets uploaded by this tool are named by sha256, so a `referenceName` that
 * is a 64-character hex string is ours and can be reconciled. The other naming
 * scheme in the library is the original file name, left behind by the web UI;
 * those assets are reported as untracked and never touched, because deleting
 * an asset the web UI owns would silently blank a live storefront.
 */
export async function libraryImages(client, libraryId) {
  const assets = await client.getAll(`/v1/appAssetLibraries/${libraryId}/images?limit=200`);
  const byRef = new Map();
  for (const asset of assets) {
    const ref = asset.attributes?.referenceName;
    if (ref) byRef.set(ref, asset);
  }
  return { assets, byRef };
}

export const HASH_RE = /^[0-9a-f]{64}$/;

// ---------------------------------------------------------------------------
// Upload
// ---------------------------------------------------------------------------

/**
 * Pushes one file through reserve -> parts -> commit.
 *
 * Failure handling is deliberate, because each of these leaves a different
 * mess and only one of them is safe to retry:
 *
 *   - 401  the token expired mid-run (a 500MB upload can outlive a 20-minute
 *          token). Retried by the caller with a freshly minted client.
 *   - 409  a conflicting record exists. Not retried: the caller looks the asset
 *          up by referenceName and reuses it if it is there.
 *   - 413  the file exceeds the spec's maxFileSize. Checked locally first, so
 *          this should never be reached.
 *   - part failure  the reservation is left uncommitted. Deleted before
 *          rethrowing, otherwise the library accumulates orphan records that
 *          count against quota and show as "processing" forever.
 */
export async function uploadImage(client, {
  libraryId,
  filePath,
  category,
  referenceName,
  dryRun = false,
  log = () => {},
  retryTransient = true,
}) {
  const fileName = basename(filePath);
  const fileSize = statSync(filePath).size;

  const reservation = await client.post('/v1/appAssetLibraryImages', {
    data: {
      type: 'appAssetLibraryImages',
      attributes: {
        fileName,
        fileSize,
        ...(category ? { category } : {}),
        ...(referenceName ? { referenceName } : {}),
      },
      relationships: {
        assetLibrary: { data: { type: 'appAssetLibraries', id: libraryId } },
      },
    },
  });

  if (dryRun) {
    return { dryRun: true, fileName, fileSize, referenceName };
  }

  const assetId = reservation?.data?.id;
  const operations = reservation?.data?.attributes?.uploadOperations ?? [];
  if (!assetId) throw new Error(`Reservation for ${fileName} returned no asset id.`);
  if (operations.length === 0) {
    throw new Error(
      `Reservation for ${fileName} returned no upload operations. The file is probably already `
      + 'committed under this name; retry with sync.',
    );
  }

  const descriptor = openSync(filePath, 'r');
  try {
    for (const operation of operations) {
      const { method = 'PUT', url, length, offset, requestHeaders } = operation;
      const chunk = Buffer.alloc(length);
      readSync(descriptor, chunk, 0, length, offset);

      const headers = Object.fromEntries(
        (requestHeaders ?? []).map((header) => [header.name, header.value]),
      );
      log(`  ${method} ${url.split('?')[0]} (${length} bytes @ ${offset})`);

      let response;
      try {
        response = await fetch(url, { method, headers, body: chunk });
      } catch (cause) {
        // A dropped connection on a part is transient: the reservation is
        // still valid and the part can be sent again.
        if (!retryTransient) throw new Error(`Uploading ${fileName} @${offset} failed: ${cause.message}`);
        response = await fetch(url, { method, headers, body: chunk });
      }
      if (!response.ok) {
        const body = await response.text().catch(() => '');
        await client.delete(`/v1/appAssetLibraryImages/${assetId}`).catch(() => {});
        throw new Error(
          `Uploading ${fileName} part at offset ${offset} failed: HTTP ${response.status}`
          + `${body ? ` ${body.slice(0, 400)}` : ''}`,
        );
      }
    }
  } finally {
    closeSync(descriptor);
  }

  await client.patch(`/v1/appAssetLibraryImages/${assetId}`, {
    data: { type: 'appAssetLibraryImages', id: assetId, attributes: { uploaded: true } },
  });

  return { assetId, fileName, fileSize, referenceName };
}

/**
 * Polls until Apple finishes processing an asset.
 *
 * The state vocabulary is inverted from what it looks like: `PROCESSING` and
 * `UPLOAD_COMPLETE` are the only pending states, and an absent state means the
 * record has not been materialised yet. Everything else — PREPARE_FOR_SUBMISSION,
 * APPROVED, MISSING_METADATA — means done. `FAILED` is terminal and must be
 * re-uploaded, so it raises instead of waiting out the timeout.
 */
export async function waitForImage(client, assetId, { timeoutMs = 300_000 } = {}) {
  const deadline = Date.now() + timeoutMs;
  let delay = 1000;
  let last = null;
  for (;;) {
    const response = await client.get(`/v1/appAssetLibraryImages/${assetId}`);
    const attributes = response?.data?.attributes ?? {};
    const state = attributes.state;

    if (state === 'FAILED') {
      const details = attributes.stateDetails;
      throw new Error(
        `Asset ${assetId} failed processing: `
        + `${typeof details === 'string' ? details : JSON.stringify(details ?? {})}`,
      );
    }
    if (state !== undefined && state !== 'PROCESSING' && state !== 'UPLOAD_COMPLETE') {
      return response.data;
    }
    last = state;
    if (Date.now() >= deadline) {
      throw new Error(`Asset ${assetId} still ${last ?? 'unknown'} after ${timeoutMs / 1000}s.`);
    }
    await new Promise((resolve) => setTimeout(resolve, delay));
    delay = Math.min(delay * 1.5, 5000);
  }
}

/**
 * Creates one placement, or reports that an equivalent one already exists.
 *
 * Idempotency here is by (placementType, placementGroup, target, image): the
 * same target cannot hold two placements of the same type in the same group,
 * so an existing row of that type/group is treated as satisfied. Replacing
 * bytes means deleting the placement first, which `--replace` does.
 */
export async function placeImage(client, {
  imageId,
  placementType,
  placementGroup,
  targetKind,
  targetId,
  existing = [],
}) {
  // The image is part of the identity. A gallery legitimately holds several
  // placements of one type in one group — Apple allows up to 10 screenshots in
  // a group — so matching on (type, group) alone treats every frame as a repeat
  // of the first. That is what happened: frames 2-6 of every locale resolved to
  // frame 1's placement id, only one screenshot was ever placed, and the
  // ordering request then submitted the same id six times. Apple rejected the
  // whole run with "the 'orderedPlacements' relationship must not contain the
  // same placement more than once". Callers must fetch `existing` with
  // `include=image`, or this comparison silently sees `undefined` and never
  // matches anything, which is at least a loud failure rather than a silent one.
  const duplicate = existing.find(
    (row) => row.attributes?.placementType === placementType
      && row.attributes?.placementGroup === placementGroup
      && row.relationships?.image?.data?.id === imageId,
  );
  if (duplicate) return { status: 'present', id: duplicate.id };

  const created = await client.post('/v1/appAssetLibraryPlacements', {
    data: {
      type: 'appAssetLibraryPlacements',
      attributes: { placementType, placementGroup },
      relationships: {
        image: { data: { type: 'appAssetLibraryImages', id: imageId } },
        [targetKind]: { data: { type: `${targetKind}s`, id: targetId } },
      },
    },
  });
  return { status: 'created', id: created?.data?.id };
}

/**
 * Sets the display order for one group on one target.
 *
 * Display order is not upload order, so a gallery built purely from placements
 * renders in Apple's own sequence — which is how a well-designed first frame
 * ends up third. Apple exposes ordering as a separate request that submits the
 * whole sequence at once.
 */
export async function orderPlacements(client, {
  placementGroup,
  orderedPlacementIds,
  targetKind,
  targetId,
}) {
  if (orderedPlacementIds.length < 2) return { status: 'skipped' };
  await client.post('/v1/appAssetLibraryPlacementOrderingRequests', {
    data: {
      type: 'appAssetLibraryPlacementOrderingRequests',
      attributes: { placementGroup },
      relationships: {
        orderedPlacements: {
          data: orderedPlacementIds.map((id) => ({ type: 'appAssetLibraryPlacements', id })),
        },
        [targetKind]: { data: { type: `${targetKind}s`, id: targetId } },
      },
    },
  });
  return { status: 'ordered' };
}

// ---------------------------------------------------------------------------
// Shared connection
// ---------------------------------------------------------------------------

/**
 * Resolves credentials, the app record and a client. `dryRun` defaults to true
 * so no command can write without an explicit flag.
 */
export async function connect({ dryRun = true, log = () => {} } = {}) {
  const app = readStoreFile('app.json');
  const creds = credentialsFromEnv();
  const client = createClient({ ...creds, dryRun, log });
  const record = await findApp(client, app);
  return { app, creds, client, appId: record.id, record };
}

/** Tier-1 locales: the storefronts worth native creative. Read from locales.json. */
export function tierOneLocales() {
  return loadLocales().locales.filter((locale) => locale.tier === 1).map((locale) => locale.asc);
}

/** Repo-relative path for display, so dry-run output is copy-pasteable. */
export function displayPath(filePath) {
  const rel = relative(ROOT, filePath);
  return rel.startsWith('..') ? filePath : rel;
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const command = args.find((arg) => !arg.startsWith('--'));
const flagValue = (name) => {
  const inline = args.find((arg) => arg.startsWith(`--${name}=`));
  if (inline) return inline.slice(name.length + 3);
  const index = args.indexOf(`--${name}`);
  return index === -1 ? undefined : args[index + 1];
};

function heading(text) {
  console.log(`\n${text}`);
  console.log('-'.repeat(text.length));
}

/**
 * The version media can be placed on. A released version is closed forever, so
 * placing screenshots needs a version in PREPARE_FOR_SUBMISSION; library-only
 * uploads do not, which is why this reports rather than throws.
 *
 * Exported because grow.mjs needs the same answer before it can assemble a
 * submission, and two different notions of "the editable version" is how a
 * pipeline writes to one version and reports on another.
 */
export async function editableVersionFor(client, appId, versionString) {
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState`,
  );
  const editable = versions.find(
    (version) => version.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION',
  );
  if (!editable) return { versions, version: null };
  if (versionString && editable.attributes.versionString !== versionString) {
    return { versions, version: null, note: `editable version is ${editable.attributes.versionString}, not ${versionString}` };
  }
  return { versions, version: editable };
}

/**
 * Validates one manifest entry against the live catalog.
 *
 * Everything checked here is something Apple rejects later without naming the
 * file: wrong dimensions, an alpha channel, an extension the spec does not
 * list, a size over the cap, or more frames in a group than the group holds.
 */
function validateEntry(catalog, entry, group) {
  const probe = probeImage(entry.filePath);
  const problems = [];

  if (probe.format === 'unknown') problems.push('not a PNG or JPEG (Apple accepts only those)');
  if (probe.width !== null && (probe.width !== entry.width || probe.height !== entry.height)) {
    problems.push(
      `manifest says ${entry.width}x${entry.height} but the file is ${probe.width}x${probe.height}`,
    );
  }
  if (probe.hasAlpha) {
    problems.push(
      `file has an alpha channel (PNG color type ${probe.colorType}); Apple rejects transparency`,
    );
  }
  if (probe.suspiciousAlpha) {
    problems.push('file is an indexed PNG and may carry a tRNS chunk; re-export as RGB24');
  }

  const type = catalog.types.find((row) => row.placementTypeId === PLACEMENT_TYPES[entry.kind]);
  if (type) {
    const specById = new Map(catalog.specs.map((spec) => [spec.specId, spec]));
    const mapping = (type.specMappings ?? []).find((row) => row.placementGroupId === group);
    const spec = (mapping?.specs ?? [])
      .map((id) => specById.get(id))
      .find((row) => row && row.dimensions
        && entry.width >= row.dimensions.minWidth && entry.width <= row.dimensions.maxWidth
        && entry.height >= row.dimensions.minHeight && entry.height <= row.dimensions.maxHeight);
    if (!spec) {
      problems.push(`no image spec in ${group} accepts ${entry.width}x${entry.height}`);
    } else {
      const ext = `.${entry.filePath.split('.').pop().toLowerCase()}`;
      if (!spec.fileExtensions.includes(ext)) {
        problems.push(`${ext} is not in this spec's allowed extensions (${spec.fileExtensions.join(' ')})`);
      }
      const bytes = entry.bytes ?? statSync(entry.filePath).size;
      if (bytes > spec.maxFileSize) {
        problems.push(`${bytes} bytes exceeds the spec cap of ${spec.maxFileSize}`);
      }
    }
  }

  return { problems, probe };
}

/** Every (locale, kind) slot count in a group must stay inside Apple's cap. */
function groupCapProblems(entries, groupFor) {
  const counts = new Map();
  for (const entry of entries) {
    if (entry.kind !== 'frame') continue;
    const group = groupFor(entry);
    if (!group) continue;
    const key = `${entry.locale}:${group}`;
    counts.set(key, (counts.get(key) ?? 0) + 1);
  }
  return [...counts]
    .filter(([, count]) => count > MAX_PER_GROUP)
    .map(([key, count]) => `${key} has ${count} frames; Apple shows at most ${MAX_PER_GROUP}`);
}

/**
 * Builds the full plan: what is already in the library, what would be uploaded,
 * what would be placed and where. Shared by `upload` and `sync` so the two can
 * never disagree about what "already present" means.
 */
async function buildPlan({ client, appId, libraryId, catalog, manifest, entries }) {
  const { byRef, assets } = await libraryImages(client, libraryId);

  const groupFor = (entry) => {
    const placementType = PLACEMENT_TYPES[entry.kind];
    if (!placementType) return null;
    const resolved = resolveGroup(catalog, { ...entry, placementType });
    return resolved.group ?? null;
  };

  const hashed = entries.map((entry) => ({ ...entry, sha256: sha256File(entry.filePath) }));
  const byHash = new Map();
  for (const entry of hashed) if (!byHash.has(entry.sha256)) byHash.set(entry.sha256, entry);

  const toUpload = [...byHash.values()].filter((entry) => !byRef.has(entry.sha256));
  const present = [...byHash.values()].filter((entry) => byRef.has(entry.sha256));

  const { version } = await editableVersionFor(client, appId, readStoreFile('app.json').marketingVersion);
  let targets = new Map();
  if (version) {
    const localizations = await client.getAll(
      `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200`,
    );
    targets = new Map(localizations.map((row) => [row.attributes.locale, row.id]));
  }

  const placeable = hashed
    .filter((entry) => PLACEMENT_TYPES[entry.kind] && targets.has(entry.locale))
    .map((entry) => ({ ...entry, group: groupFor(entry), targetId: targets.get(entry.locale) }))
    .filter((entry) => entry.group);

  const libraryOnly = hashed.filter((entry) => !PLACEMENT_TYPES[entry.kind]);

  const untracked = assets.filter((asset) => !HASH_RE.test(asset.attributes?.referenceName ?? ''));
  const manifestHashes = new Set(hashed.map((entry) => entry.sha256));
  const orphans = assets.filter((asset) => {
    const ref = asset.attributes?.referenceName ?? '';
    return HASH_RE.test(ref) && !manifestHashes.has(ref);
  });

  return {
    hashed, byRef, toUpload, present, placeable, libraryOnly, untracked, orphans, version, targets,
  };
}

function reportPlan(plan, catalog, groupFor) {
  const bytes = plan.toUpload.reduce((sum, entry) => sum + statSync(entry.filePath).size, 0);
  const saved = new Set(plan.placeable.map((entry) => entry.filePath)).size - plan.toUpload.length;

  console.log(`  ${plan.hashed.length} manifest entr${plan.hashed.length === 1 ? 'y' : 'ies'}`
    + `, ${new Set(plan.hashed.map((e) => e.sha256)).size} distinct by content`);
  console.log(`  already in the library   ${plan.present.length}`);
  console.log(`  to upload                ${plan.toUpload.length} (${(bytes / 1024 / 1024).toFixed(1)} MB)`);
  if (saved > 0) console.log(`  duplicate paths avoided  ${saved} (same bytes, two paths)`);
  console.log(`  placements to create     ${plan.placeable.length}`);
  if (plan.libraryOnly.length > 0) {
    console.log(`  library-only             ${plan.libraryOnly.length} (no placement type exists)`);
  }

  if (plan.toUpload.length > 0) {
    console.log('\n  uploads:');
    for (const entry of plan.toUpload.slice(0, 40)) {
      const group = groupFor(entry) ?? '-';
      console.log(
        `    ${entry.locale.padEnd(9)} ${entry.kind.padEnd(13)} frame=${String(entry.frame ?? '-').padStart(2)}`
        + `  ${String(entry.width).padStart(4)}x${String(entry.height).padEnd(4)}  ${group}`
        + `  ${displayPath(entry.filePath)}`,
      );
    }
    if (plan.toUpload.length > 40) console.log(`    … ${plan.toUpload.length - 40} more`);
  }

  if (plan.untracked.length > 0) {
    console.log(`\n  untracked library assets (named by file, not hash — never touched): ${plan.untracked.length}`);
  }
  if (plan.orphans.length > 0) {
    console.log(`\n  orphaned hash assets (in the library, not in this manifest): ${plan.orphans.length}`);
    console.log('    reported only; deleting assets is a human decision:');
    for (const asset of plan.orphans.slice(0, 20)) {
      console.log(`    ${asset.attributes.referenceName.slice(0, 12)}  ${asset.attributes.fileName}`);
    }
  }
}

async function cmdStatus() {
  const { client, appId, app } = await connect();
  const manifest = loadManifest(flagValue('manifest') ?? DEFAULT_MANIFEST);
  const libraryId = await libraryIdFor(client, appId);
  const catalog = await loadCatalog(client);

  heading('Asset library');
  const { assets } = await libraryImages(client, libraryId);
  const hashNamed = assets.filter((asset) => HASH_RE.test(asset.attributes?.referenceName ?? ''));
  console.log(`  library          ${libraryId}`);
  console.log(`  images           ${assets.length} (${hashNamed.length} hash-named, ${assets.length - hashNamed.length} from the web UI)`);
  for (const state of ['APPROVED', 'PREPARE_FOR_SUBMISSION', 'PROCESSING', 'FAILED']) {
    const count = assets.filter((asset) => asset.attributes?.state === state).length;
    if (count > 0) console.log(`    ${state.padEnd(24)} ${count}`);
  }

  heading('Placement catalog');
  console.log(`  placement types  ${catalog.types.map((type) => type.placementTypeId).join(', ')}`);
  console.log(`  groups           ${catalog.groups.length} (${catalog.groups.filter((g) => g.platform === 'IPHONE_APP_STORE').length} iPhone)`);

  heading('Local manifest');
  if (!manifest) {
    console.log(`  none at ${displayPath(DEFAULT_MANIFEST)}`);
    console.log('  the creative pipeline writes it; nothing to upload until then');
  } else {
    const kinds = new Map();
    for (const entry of manifest.entries) kinds.set(entry.kind, (kinds.get(entry.kind) ?? 0) + 1);
    console.log(`  ${manifest.entries.length} entries from ${displayPath(manifest.source)}`);
    for (const [kind, count] of kinds) console.log(`    ${kind.padEnd(14)} ${count}`);
    const locales = new Set(manifest.entries.map((entry) => entry.locale));
    console.log(`  ${locales.size} locale(s), ${new Set(manifest.entries.map((e) => e.displayType ?? '-')).size} display type(s)`);
    if (manifest.problems.length > 0) {
      console.log(`  ${manifest.problems.length} manifest problem(s):`);
      for (const problem of manifest.problems.slice(0, 20)) console.log(`    ${problem}`);
    }
  }

  heading('Version');
  const { version, note } = await editableVersionFor(client, appId, app.marketingVersion);
  console.log(version
    ? `  editable  ${version.attributes.versionString} (${version.id})`
    : `  no editable version${note ? ` (${note})` : ''} — placements need one: node scripts/asc/publish.mjs prepare --apply`);

  console.log('\nRead-only. Nothing was written.');
}

async function cmdUpload() {
  const manifestPath = flagValue('manifest') ?? DEFAULT_MANIFEST;
  const manifest = loadManifest(manifestPath);
  heading('Asset upload');
  if (!manifest) {
    console.log(`  manifest not found: ${displayPath(manifestPath)}`);
    console.log('  nothing to upload. The creative pipeline writes this file; re-run once it exists.');
    return;
  }

  const { client, appId, app } = await connect({ dryRun: !apply, log: apply ? (line) => console.log(line) : () => {} });
  console.log(`  mode      ${apply ? 'APPLY (writes)' : 'dry run (prints the exact requests)'}`);
  console.log(`  manifest  ${displayPath(manifestPath)}  ${manifest.entries.length} entries`);

  if (manifest.problems.length > 0) {
    heading(`Manifest problems (${manifest.problems.length})`);
    for (const problem of manifest.problems.slice(0, 30)) console.log(`  ${problem}`);
    throw new Error('the manifest is not uploadable; fix it before uploading');
  }

  const libraryId = await libraryIdFor(client, appId);
  const catalog = await loadCatalog(client);
  const entries = manifest.entries;

  const groupCache = new Map();
  const groupFor = (entry) => {
    const placementType = PLACEMENT_TYPES[entry.kind];
    if (!placementType) return null;
    const key = `${placementType}:${entry.width}x${entry.height}:${entry.displayType ?? '-'}`;
    if (!groupCache.has(key)) {
      const resolved = resolveGroup(catalog, { ...entry, placementType });
      groupCache.set(key, resolved.group ?? null);
      if (resolved.error) console.log(`  SKIP ${entry.locale}/${entry.kind}: ${resolved.error}`);
    }
    return groupCache.get(key);
  };

  const invalid = [];
  for (const entry of entries) {
    // A kind with `PLACEMENT_TYPES[kind] === null` is deliberately library-only:
    // the preview poster is the thumbnail a preview video attaches later, so it
    // has no placement of its own. Treating that as a hard error rejected all 50
    // posters and therefore the entire 750-asset upload, which is why no
    // screenshot had ever reached App Store Connect. Library-only entries still
    // upload; they just get no placement.
    if (PLACEMENT_TYPES[entry.kind] === null) continue;
    const group = groupFor(entry);
    if (!group) {
      invalid.push(`${entry.locale}/${entry.kind}: no placement group`);
      continue;
    }
    const { problems } = validateEntry(catalog, entry, group);
    for (const problem of problems) invalid.push(`${entry.locale}/${entry.kind} frame=${entry.frame ?? '-'}: ${problem}`);
  }
  for (const problem of groupCapProblems(entries, groupFor)) invalid.push(problem);
  if (invalid.length > 0) {
    heading(`Invalid entries (${invalid.length})`);
    for (const problem of invalid.slice(0, 40)) console.log(`  ${problem}`);
    throw new Error(`${invalid.length} entr${invalid.length === 1 ? 'y is' : 'ies are'} not uploadable`);
  }

  const plan = await buildPlan({ client, appId, libraryId, catalog, manifest, entries });
  heading('Plan');
  reportPlan(plan, catalog, groupFor);

  if (!plan.version && plan.hashed.some((entry) => PLACEMENT_TYPES[entry.kind])) {
    heading('Placements deferred');
    console.log('  no editable version, so these frames will be uploaded to the library but not placed.');
    console.log(`  run: node scripts/asc/publish.mjs prepare --apply   (creates ${app.marketingVersion})`);
  }

  heading('Requests');
  const hashes = [...new Set(plan.toUpload.map((entry) => entry.sha256))];
  if (hashes.length === 0) {
    console.log('  nothing to upload; the library already holds every byte in this manifest');
  } else {
    console.log(`  POST   /v1/appAssetLibraryImages   x${hashes.length}  (reserve, one per distinct hash)`);
    for (const entry of plan.toUpload) {
      console.log(`         ${displayPath(entry.filePath)}  sha256=${entry.sha256.slice(0, 12)}…  category=${CATEGORIES[entry.kind]}`);
    }
    console.log('  PUT    <uploadOperations[].url>    (the bytes, one request per part)');
    console.log('  PATCH  /v1/appAssetLibraryImages/{id}  {"uploaded": true}   x' + hashes.length);
  }
  if (plan.version && plan.placeable.length > 0) {
    console.log(`  POST   /v1/appAssetLibraryPlacements  x${plan.placeable.length}`);
    console.log(`         target: appStoreVersionLocalizations on ${plan.version.attributes.versionString}`);
    console.log('  POST   /v1/appAssetLibraryPlacementOrderingRequests   (frame order per locale+group)');
  }

  if (!apply) {
    console.log('\n  Re-run with --apply to upload. Nothing was written.');
    return;
  }

  // --- apply ---------------------------------------------------------------
  await runUpload({ client, appId, libraryId, catalog, plan, groupFor });
}

/**
 * Executes the plan. Kept separate from `cmdUpload` so the dry run and the real
 * run share one plan object and cannot drift.
 */
async function runUpload({ client, appId, libraryId, catalog, plan, groupFor }) {
  heading('Uploading');
  const assetIdByHash = new Map();
  for (const [hash, asset] of plan.byRef) {
    if (HASH_RE.test(hash)) assetIdByHash.set(hash, asset.id);
  }

  let uploaded = 0;
  let reused = 0;
  /** Assets whose bytes landed but whose processing never settled. */
  const slow = [];

  /**
   * Upload one entry and record its asset id.
   *
   * Split out of the loop so several can be in flight: the run is dominated by
   * transferring 1-2 MB per image plus Apple's own round trips, and serially
   * that is ~45 s per asset, or about eight hours for the 705 in this set. The
   * work is independent per file, so a small pool turns it into a couple of
   * hours without changing what is uploaded or how it is recorded. Kept at four
   * to stay well clear of App Store Connect rate limits and to keep memory flat.
   */
  const uploadOne = async (entry) => {
    if (assetIdByHash.has(entry.sha256)) { reused += 1; return; }
    process.stdout.write(`  ${displayPath(entry.filePath)} … `);
    try {
      const { assetId } = await uploadImage(client, {
        libraryId,
        filePath: entry.filePath,
        category: CATEGORIES[entry.kind],
        referenceName: entry.sha256,
      });
      // Waiting for processing is a courtesy, not a requirement. The bytes are
      // already in the library and a placement can name the asset while it is
      // still processing, so a single asset that Apple leaves in
      // `UPLOAD_COMPLETE` must not abort a 705-asset run — which is exactly what
      // happened: one header PNG stalled and discarded the remaining 654. A
      // timeout now records the asset, skips the wait, and is reported at the
      // end so it can be re-checked instead of silently forgotten.
      //
      // The wait is also deliberately short. Apple's processing time grew as the
      // library filled, reaching minutes per image, which made a full run take
      // longer than a day and therefore never finish. A settled asset is still
      // confirmed immediately; a slow one is placed now and verified by
      // `media.mjs status` after the run.
      try {
        await waitForImage(client, assetId, { timeoutMs: 5_000 });
      } catch (error) {
        if (!/still (UPLOAD_COMPLETE|PROCESSING|unknown) after/.test(String(error.message))) throw error;
        slow.push({ path: displayPath(entry.filePath), assetId });
        console.log('uploaded, still processing — continuing');
      }
      assetIdByHash.set(entry.sha256, assetId);
      uploaded += 1;
      if (!slow.some((row) => row.assetId === assetId)) console.log('done');
    } catch (error) {
      // A 401 means the token expired mid-run, which a large upload can do.
      // A fresh client mints a fresh token; retry the one file, not the run.
      if (error.status === 401) {
        console.log('401 (token expired) — reminting and retrying this file');
        const fresh = await connect({ dryRun: false, log: () => {} });
        const retry = await uploadImage(fresh.client, {
          libraryId,
          filePath: entry.filePath,
          category: CATEGORIES[entry.kind],
          referenceName: entry.sha256,
        });
        assetIdByHash.set(entry.sha256, retry.assetId);
        uploaded += 1;
        console.log('done (after re-auth)');
        return;
      }
      if (error.status === 409) {
        // Someone else (or a previous interrupted run) already has this asset.
        const { byRef } = await libraryImages(client, libraryId);
        const existing = byRef.get(entry.sha256);
        if (existing) {
          assetIdByHash.set(entry.sha256, existing.id);
          reused += 1;
          console.log('already present (409)');
          return;
        }
      }
      console.log('FAILED');
      throw error;
    }
  };

  const workers = Array.from({ length: Math.max(1, Math.min(UPLOAD_CONCURRENCY, plan.toUpload.length)) });
  let cursor = 0;
  await Promise.all(workers.map(async () => {
    for (;;) {
      const index = cursor;
      cursor += 1;
      if (index >= plan.toUpload.length) return;
      await uploadOne(plan.toUpload[index]);
    }
  }));
  console.log(`  uploaded ${uploaded}, reused ${reused}`);
  if (slow.length > 0) {
    console.log(`  ${slow.length} asset(s) uploaded but still processing in App Store Connect:`);
    for (const row of slow) console.log(`    ${row.assetId}  ${row.path}`);
    console.log('  They are placed already; re-run `media.mjs status` in a few minutes to confirm.');
  }

  if (!plan.version) {
    console.log('\n  No editable version, so nothing was placed. Uploads are in the library.');
    return;
  }

  heading('Placing');
  // Group by (placement type, placement group), not by group alone. Apple
  // resolves the header asset and the search-results asset into the same
  // display-time group (`DEFAULT_PROFILE`, because both are creative assets of
  // similar dimensions), and an ordering request refuses mixed types: "All
  // placements in the 'orderedPlacements' relationship must have the same
  // 'placementType'". Keying on the group only packed them into one request and
  // failed the run at the very first locale.
  const byTarget = new Map();
  for (const entry of plan.placeable) {
    if (!byTarget.has(entry.targetId)) byTarget.set(entry.targetId, new Map());
    const groups = byTarget.get(entry.targetId);
    const key = `${PLACEMENT_TYPES[entry.kind]}\u0000${entry.group}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(entry);
  }

  let placed = 0;
  /** Groups whose display order Apple refused. Reported, never fatal. */
  const orderFailures = [];
  for (const [targetId, groups] of byTarget) {
    const existing = await client.getAll(
      `/v1/appStoreVersionLocalizations/${targetId}/placements?limit=200&include=image`,
    );
    for (const [key, list] of groups) {
      const [placementType, group] = key.split('\u0000');
      const ordered = [...list].sort((a, b) => (a.frame ?? 0) - (b.frame ?? 0));
      const placementIds = [];
      for (const entry of ordered) {
        const imageId = assetIdByHash.get(entry.sha256);
        if (!imageId) continue;
        const result = await placeImage(client, {
          imageId,
          placementType,
          placementGroup: group,
          targetKind: 'appStoreVersionLocalization',
          targetId,
          existing,
        });
        if (result.status === 'created') placed += 1;
        else console.log(`    ${entry.locale} ${group} already has a ${placementType}`);
        if (result.id) placementIds.push(result.id);
        existing.push({
          id: result.id,
          attributes: { placementType, placementGroup: group },
          relationships: { image: { data: { type: 'appAssetLibraryImages', id: imageId } } },
        });
      }
      // Ordering is a set relationship, so a repeated id is a hard error from
      // Apple. Dedupe defensively: a manifest entry repeated at the same target
      // resolves to one asset by content hash and would otherwise be submitted
      // twice even after the identity fix above.
      const uniquePlacementIds = [...new Set(placementIds)];
      if (uniquePlacementIds.length > 1) {
        // Ordering is presentation only: the placements already exist and the
        // gallery renders, just possibly not in the intended sequence. Letting a
        // rejection here abort the run is how two ordering bugs discarded 686 of
        // 700 placements. Report it, keep placing, and re-order afterwards.
        try {
          await orderPlacements(client, {
            placementGroup: group,
            orderedPlacementIds: uniquePlacementIds,
            targetKind: 'appStoreVersionLocalization',
            targetId,
          });
        } catch (error) {
          orderFailures.push(
            `${targetId.slice(0, 8)} ${placementType} ${group}: ${String(error.message).split('\n')[0].slice(0, 160)}`,
          );
        }
      }
    }
  }
  console.log(`  ${placed} placement(s) created`);
  if (orderFailures.length > 0) {
    console.log(`  ${orderFailures.length} group(s) could not be ordered (placements are live, sequence may differ):`);
    for (const row of orderFailures.slice(0, 8)) console.log(`    ${row}`);
  }
  console.log('\n  Uploaded. A version in PREPARE_FOR_SUBMISSION still needs a submission to appear.');
}

/**
 * Reconciles the manifest against the library without writing.
 *
 * This is the command to run before an upload: it answers "what changed" by
 * content hash, which is the only identity that survives a re-render. Anything
 * orphaned is reported, never deleted — a wrong deletion blanks a live page.
 */
async function cmdSync() {
  const manifestPath = flagValue('manifest') ?? DEFAULT_MANIFEST;
  const manifest = loadManifest(manifestPath);
  heading('Asset sync');
  if (!manifest) {
    console.log(`  manifest not found: ${displayPath(manifestPath)}`);
    console.log('  nothing to reconcile.');
    return;
  }

  const { client, appId } = await connect();
  console.log(`  mode      read-only (sync never writes; use upload --apply)`);
  console.log(`  manifest  ${displayPath(manifestPath)}  ${manifest.entries.length} entries`);

  const libraryId = await libraryIdFor(client, appId);
  const catalog = await loadCatalog(client);
  const groupFor = (entry) => {
    const placementType = PLACEMENT_TYPES[entry.kind];
    if (!placementType) return null;
    return resolveGroup(catalog, { ...entry, placementType }).group ?? null;
  };

  const plan = await buildPlan({ client, appId, libraryId, catalog, manifest, entries: manifest.entries });

  heading('Diff by content hash');
  console.log(`  in manifest and library   ${plan.present.length}`);
  console.log(`  in manifest, not library  ${plan.toUpload.length}   -> upload`);
  console.log(`  in library, not manifest  ${plan.orphans.length}   -> reported, not deleted`);
  console.log(`  in library, not ours      ${plan.untracked.length}   -> web UI assets, never touched`);

  if (plan.toUpload.length > 0) {
    console.log('\n  would upload:');
    for (const entry of plan.toUpload.slice(0, 30)) {
      console.log(`    ${entry.locale.padEnd(9)} ${entry.kind.padEnd(13)} ${displayPath(entry.filePath)}`);
    }
    if (plan.toUpload.length > 30) console.log(`    … ${plan.toUpload.length - 30} more`);
  }
  if (plan.orphans.length > 0) {
    console.log('\n  would delete (needs your decision; sync never deletes):');
    for (const asset of plan.orphans.slice(0, 30)) {
      console.log(
        `    ${asset.attributes.referenceName.slice(0, 12)}…  ${asset.attributes.fileName}`
        + `  ${asset.attributes.state}`,
      );
    }
    console.log('    DELETE /v1/appAssetLibraryImages/{id}   (one per row above)');
  }

  // Placements that point at bytes no locale-localization still wants are the
  // other half of a sync: an asset can be current while its placement is stale.
  if (plan.version) {
    const localizations = await client.getAll(
      `/v1/appStoreVersions/${plan.version.id}/appStoreVersionLocalizations?limit=200`,
    );
    let placementCount = 0;
    for (const localization of localizations) {
      const placements = await client.getAll(
        `/v1/appStoreVersionLocalizations/${localization.id}/placements?limit=200`,
      );
      placementCount += placements.length;
    }
    heading('Placements');
    console.log(`  ${plan.version.attributes.versionString}: ${placementCount} placement(s) across ${localizations.length} localization(s)`);
    console.log(`  ${plan.placeable.length} would be created by upload --apply`);
  } else {
    heading('Placements');
    console.log('  no editable version; screenshots cannot be placed until one exists');
  }

  console.log('\nRead-only. Nothing was written or deleted.');
}

const COMMANDS = { status: cmdStatus, upload: cmdUpload, sync: cmdSync };

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (!command || !COMMANDS[command]) {
    console.error(`usage: node scripts/asc/media.mjs <${Object.keys(COMMANDS).join('|')}> [--manifest <path>] [--apply]`);
    process.exit(command ? 1 : 0);
  }
  COMMANDS[command]().catch((error) => {
    console.error(`FAILED: ${error.message}`);
    if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1500));
    process.exit(1);
  });
}
