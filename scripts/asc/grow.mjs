#!/usr/bin/env node
/**
 * Growth surfaces for FitCheck AI: custom product pages, product page
 * optimization experiments, in-app events, and the submission that carries
 * them all.
 *
 *   node scripts/asc/grow.mjs status     read-only dashboard, live vs local
 *   node scripts/asc/grow.mjs cpp        custom product pages from cpp.json
 *   node scripts/asc/grow.mjs ppo        PPO experiments from ppo.json
 *   node scripts/asc/grow.mjs events     in-app events from events.json
 *   node scripts/asc/grow.mjs submit     what a submission would contain
 *
 * Every command is dry by default and prints the exact method, path and body it
 * would send. `--apply` is the only thing that writes, and every command is
 * idempotent: a second run after a successful apply reports "already present"
 * and sends nothing.
 *
 * ---------------------------------------------------------------------------
 * What separates these four surfaces
 * ---------------------------------------------------------------------------
 * They are not variations on one another; they move different numbers and they
 * are reviewed independently.
 *
 *   Custom product page  a second product page at its own URL, with its own
 *                        screenshots and its own search keywords. It does not
 *                        change the main listing. It earns its keep by
 *                        capturing a search term the main page loses, or by
 *                        matching a promise an ad already made.
 *
 *   PPO experiment       a closed test of one variable of the product page,
 *                        shown to a random slice of live traffic, measured
 *                        against the control. It changes nothing permanently
 *                        until you adopt the winner.
 *
 *   In-app event         a dated card on the product page and in search. It is
 *                        the only surface that can say "now" — and the only one
 *                        that expires, which is why stale handling is a
 *                        first-class path here and not an error.
 *
 * Tables that matter, all read off the live API rather than guessed:
 *
 *   appCustomProductPages       attributes name; relationships app,
 *                               appStoreVersionTemplate (the page to copy)
 *   appCustomProductPageVersions attributes deepLink; state; version
 *   appCustomProductPageLocalizations
 *                               attributes locale, promotionalText;
 *                               relationship searchKeywords
 *   appStoreVersionExperiments attributes name, platform, trafficProportion
 *                               (all required), startDate, state; relationship
 *                               app only — an experiment is not bound to a
 *                               version at create time
 *   appStoreVersionExperimentTreatments
 *                               attributes name, appIconName
 *   appEvents                   attributes referenceName (required), badge,
 *                               primaryLocale, purpose, priority,
 *                               purchaseRequirement, deepLink,
 *                               territorySchedules[{territories, publishStart,
 *                               eventStart, eventEnd}]
 *   appEventLocalizations       attributes locale (required), name,
 *                               shortDescription, longDescription
 *
 * Keywords are the one genuinely surprising part: a custom product page
 * localization has no keyword attribute at all. Keywords are a to-many
 * relationship to `appKeywords`, and an `appKeyword` id is the keyword text
 * itself (the live app returns ids `closet`, `outfit`, `try-on`). So assigning
 * a keyword is a relationship POST whose ids are words, and `appKeywords` has
 * no create operation of its own.
 *
 * Media is not handled here. This command creates the container and the
 * placement target; `media.mjs` owns the bytes. Frame placement reuses
 * media.mjs's upload/placement primitives.
 */

import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { ROOT, readStoreFile } from './asc.mjs';
import { loadLocales, validateListings } from './plan.mjs';
import {
  DEFAULT_MANIFEST,
  HASH_RE,
  MAX_PER_GROUP,
  PLACEMENT_TYPES,
  connect,
  editableVersionFor,
  libraryIdFor,
  libraryImages,
  loadCatalog,
  loadManifest,
  placeImage,
  resolveGroup,
  sha256File,
} from './media.mjs';

// ---------------------------------------------------------------------------
// Argument handling
// ---------------------------------------------------------------------------

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const startExperiment = args.includes('--start');
const command = args.find((arg) => !arg.startsWith('--'));
const flagValue = (name) => {
  const inline = args.find((arg) => arg.startsWith(`--${name}=`));
  if (inline) return inline.slice(name.length + 3);
  const index = args.indexOf(`--${name}`);
  return index === -1 ? undefined : args[index + 1];
};

/**
 * Only mutations are echoed. The client logs every request including GETs, and
 * a dry run whose output is 90 percent read-only lookups is unreadable — which
 * defeats the point of printing the plan.
 */
const requestLogger = (line) => {
  if (apply) return;
  if (!line.includes('[dry-run]') && !/^\s{12}/.test(line)) return;
  console.log(line);
};

/** Prints one mutation the way it will go on the wire. */
function printRequest(method, path, body, indent = '    ') {
  console.log(`${indent}${method} ${path}`);
  if (body === undefined) return;
  console.log(`${indent}  ${typeof body === 'string' ? body : JSON.stringify(body)}`);
}

function heading(text) {
  console.log(`\n${text}`);
  console.log('-'.repeat(text.length));
}

/** Loads one of the growth JSON files, with a path override for tests. */
function loadGrowthFile(name, override) {
  const path = override ?? join(ROOT, 'store', 'asc', name);
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, 'utf8'));
}

const now = () => new Date();
const days = (from, to) => (to - from) / 86_400_000;

// ---------------------------------------------------------------------------
// Shared lookups
// ---------------------------------------------------------------------------

/**
 * The version new custom product pages copy their layout from.
 *
 * Apple needs one: a page created without a template starts blank, which means
 * every fresh CPP would ship with no screenshots and no copy and fail review.
 * Any released version works; a version in PREPARE_FOR_SUBMISSION is preferred
 * so the new page copies the newest design rather than last quarter's.
 */
async function resolveTemplate(client, appId, versionString) {
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState`,
  );
  const byString = versions.find((row) => row.attributes?.versionString === versionString);
  if (byString) {
    return {
      version: byString,
      note: byString.attributes.appStoreState === 'PREPARE_FOR_SUBMISSION'
        ? 'editable, newest'
        : `released (${byString.attributes.appStoreState})`,
    };
  }
  const released = versions.find((row) => row.attributes?.appStoreState === 'READY_FOR_SALE');
  if (released) {
    return { version: released, note: `${versionString} does not exist yet; using released ${released.attributes.versionString}` };
  }
  return { version: null, note: `no usable template version (looked for ${versionString} and any READY_FOR_SALE)` };
}

/** Every app event, which the API only exposes through the app relationship. */
async function listEvents(client, appId) {
  return client.getAll(`/v1/apps/${appId}/appEvents?limit=200`);
}

/** Every CPP, with its versions and localizations folded in. */
async function listCustomProductPages(client, appId, { withDetail = true } = {}) {
  const pages = await client.getAll(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
  if (!withDetail) return pages.map((page) => ({ page, versions: [] }));
  const detailed = [];
  for (const page of pages) {
    const versions = await client.getAll(
      `/v1/appCustomProductPages/${page.id}/appCustomProductPageVersions?limit=10`,
    );
    const withLocales = [];
    for (const version of versions) {
      const localizations = await client.getAll(
        `/v1/appCustomProductPageVersions/${version.id}/appCustomProductPageLocalizations?limit=200`,
      ).catch(() => []);
      const detail = [];
      for (const localization of localizations) {
        const keywords = await client.getAll(
          `/v1/appCustomProductPageLocalizations/${localization.id}/searchKeywords?limit=50`,
        ).catch(() => null);
        detail.push({ localization, keywords });
      }
      withLocales.push({ version, localizations: detail });
    }
    detailed.push({ page, versions: withLocales });
  }
  return detailed;
}

/** Every experiment with its treatments and their localizations.
 *
 *  Experiments belong to a version, not to the app: `GET
 *  /v1/apps/{id}/appStoreVersionExperiments` answers 404 "the relationship
 *  does not exist", which reads as "the API has no such feature" until the
 *  version-scoped path is tried. The version is resolved here so every caller
 *  can keep passing an app id, and the live version is the right one because
 *  product page optimization tests the page customers see today.
 */
async function liveVersionId(client, appId) {
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState`,
  );
  return versions.find((v) => v.attributes.appStoreState === 'READY_FOR_SALE')?.id ?? null;
}

async function listExperiments(client, appId) {
  const versionId = await liveVersionId(client, appId);
  if (!versionId) return [];
  const experiments = await client.getAll(
    `/v1/appStoreVersions/${versionId}/appStoreVersionExperiments?limit=200`,
  );
  const detailed = [];
  for (const experiment of experiments) {
    const treatments = await client.getAll(
      `/v1/appStoreVersionExperiments/${experiment.id}/appStoreVersionExperimentTreatments?limit=50`,
    ).catch(() => []);
    const withLocales = [];
    for (const treatment of treatments) {
      const localizations = await client.getAll(
        `/v1/appStoreVersionExperimentTreatments/${treatment.id}/appStoreVersionExperimentTreatmentLocalizations?limit=200`,
      ).catch(() => []);
      withLocales.push({ treatment, localizations });
    }
    detailed.push({ experiment, treatments: withLocales });
  }
  return detailed;
}

// ---------------------------------------------------------------------------
// cpp
// ---------------------------------------------------------------------------

/** Validation that runs before any request, so a bad page fails by name. */
function validateCpp(cpp) {
  const problems = [];
  const locales = new Set(loadLocales().locales.map((locale) => locale.asc));
  const names = new Set();

  for (const page of cpp.pages ?? []) {
    const label = page.name ?? page.slug ?? '(unnamed)';
    if (!page.name) problems.push(`${label}: missing name (Apple's reference name, max 30 chars)`);
    if (page.name && page.name.length > 30) {
      problems.push(`${label}: name is ${page.name.length} chars, Apple allows 30`);
    }
    if (names.has(page.name)) problems.push(`${label}: duplicate name`);
    names.add(page.name);

    if (!Array.isArray(page.locales) || page.locales.length === 0) {
      problems.push(`${label}: no locales`);
    }
    for (const locale of page.locales ?? []) {
      if (!locales.has(locale)) problems.push(`${label}: unknown locale ${locale}`);
    }

    // The keyword field is a comma-separated string capped at 100 characters.
    // Spaces are not allowed around the commas, and a term with a space inside
    // wastes the budget because Apple indexes words, not phrases.
    const terms = page.keywords ?? [];
    for (const term of terms) {
      if (/\s/.test(term)) {
        problems.push(`${label}: keyword "${term}" contains a space; Apple indexes single terms and a phrase wastes characters`);
      }
    }
    const joined = terms.join(',');
    if (joined.length > 100) {
      problems.push(`${label}: keywords are ${joined.length} chars, Apple allows 100 ("${joined}")`);
    }

    if (!Array.isArray(page.frames) || page.frames.length === 0) {
      problems.push(`${label}: no frames, so the page would copy the template's screenshots unchanged`);
    }
    if ((page.frames ?? []).length > MAX_PER_GROUP) {
      problems.push(`${label}: ${page.frames.length} frames, Apple shows at most ${MAX_PER_GROUP}`);
    }
    if (!page.deeplink) problems.push(`${label}: no deeplink`);
    if (!page.promotionalText?.default) problems.push(`${label}: no promotionalText.default`);
    for (const [locale, text] of Object.entries(page.promotionalText ?? {})) {
      if (locale === '_comment') continue;
      if (typeof text === 'string' && text.length > 170) {
        problems.push(`${label}/${locale}: promotional text is ${text.length} chars, Apple allows 170`);
      }
    }
  }
  return problems;
}

/**
 * Resolves one page's frame reference against the creative manifest.
 *
 * Frames are referenced by the semantic id the render pipeline uses (`closet`,
 * `tryon`, `offer`), not by position, because the position is a rendering
 * detail: `store/creative/copy.json` owns the order and it can change without
 * every page's promise changing with it. A numeric reference still works so an
 * older manifest stays usable, but the id is what the plan files use.
 */
function matchFrame(entries, locale, frameKey) {
  const forLocale = entries.filter((entry) => entry.locale === locale && entry.kind === 'frame');
  const byId = forLocale.filter((entry) => entry.frameId === frameKey);
  if (byId.length > 0) return byId;
  const numeric = typeof frameKey === 'number' ? frameKey : Number(frameKey);
  if (Number.isFinite(numeric)) {
    return forLocale.filter((entry) => entry.frame === numeric);
  }
  return [];
}

/**
 * Assigns search keywords to one CPP localization.
 *
 * There is no keyword attribute on the localization, so this is a relationship
 * write: POST the linkage, then GET the relationship back to prove it landed.
 * Removal is a DELETE on the same relationship, which is the only way to drop a
 * term that no longer matches the page.
 */
async function assignKeywords(client, localizationId, terms, locale) {
  const current = await client.getAll(
    `/v1/appCustomProductPageLocalizations/${localizationId}/searchKeywords?limit=50`,
  ).catch(() => null);
  const have = new Set((current ?? []).map((row) => row.id));
  const missing = terms.filter((term) => !have.has(term));
  const extra = (current ?? []).map((row) => row.id).filter((id) => !terms.includes(id));

  if (missing.length > 0) {
    console.log(`      ${locale} keywords +${missing.length}: ${missing.join(',')}`);
    await client.post(
      `/v1/appCustomProductPageLocalizations/${localizationId}/relationships/searchKeywords`,
      { data: missing.map((term) => ({ type: 'appKeywords', id: term })) },
    );
  }
  if (extra.length > 0) {
    console.log(`      ${locale} keywords -${extra.length} (DELETE): ${extra.join(',')}`);
    await client.delete(
      `/v1/appCustomProductPageLocalizations/${localizationId}/relationships/searchKeywords`
      + `?id=${extra.map(encodeURIComponent).join('&id=')}`,
    );
  }
  if (missing.length === 0 && extra.length === 0) {
    console.log(`      ${locale} keywords already present (${terms.length})`);
  }
  return { added: missing.length, removed: extra.length, unknown: current === null };
}

/**
 * Places one page's assigned frames onto its localization.
 *
 * Needs three things, and reports which is missing rather than silently
 * shipping a page with the template's screenshots: the creative manifest, the
 * bytes in the library, and a resolved placement group.
 */
async function placePageFrames({ client, appId, libraryId, catalog, manifest, localizationId, page, locale }) {
  if (!manifest) return { status: 'no-manifest' };
  const { byRef } = await libraryImages(client, libraryId);

  const wanted = [];
  for (const frame of page.frames ?? []) {
    const candidates = matchFrame(manifest.entries, locale, frame);
    if (candidates.length === 0) return { status: 'missing-frame', frame };
    for (const entry of candidates) wanted.push(entry);
  }

  const existing = await client.getAll(
    `/v1/appCustomProductPageLocalizations/${localizationId}/placements?limit=200&include=image`,
  ).catch(() => []);

  let placed = 0;
  for (const entry of wanted) {
    const resolved = resolveGroup(catalog, { ...entry, placementType: PLACEMENT_TYPES.frame });
    if (resolved.error) return { status: 'bad-group', error: resolved.error };
    const hash = sha256File(entry.filePath);
    const asset = byRef.get(hash);
    if (!asset) return { status: 'not-uploaded', path: entry.filePath };
    const result = await placeImage(client, {
      imageId: asset.id,
      placementType: PLACEMENT_TYPES.frame,
      placementGroup: resolved.group,
      targetKind: 'appCustomProductPageLocalization',
      targetId: localizationId,
      existing,
    });
    if (result.status === 'created') placed += 1;
    if (result.id) existing.push({ id: result.id, attributes: { placementType: PLACEMENT_TYPES.frame, placementGroup: resolved.group } });
  }
  return { status: 'ok', placed };
}

async function cmdCpp() {
  const { app, client, appId } = await connect({ dryRun: !apply, log: requestLogger });
  const cpp = loadGrowthFile('cpp.json', flagValue('cpp'));
  const manifest = loadManifest(flagValue('manifest') ?? DEFAULT_MANIFEST);

  heading(`Custom product pages (${cpp.pages.length})`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'dry run (prints the exact requests)'}`);

  const problems = validateCpp(cpp);
  if (problems.length > 0) {
    heading(`Invalid (${problems.length})`);
    for (const problem of problems.slice(0, 40)) console.log(`  ${problem}`);
    throw new Error('store/asc/cpp.json is not publishable');
  }

  const template = await resolveTemplate(client, appId, cpp.templateVersion ?? app.marketingVersion);
  if (!template.version) throw new Error(`no product page template: ${template.note}`);
  console.log(`  template ${template.version.attributes.versionString} (${template.version.id}) — ${template.note}`);

  const existing = await listCustomProductPages(client, appId, { withDetail: false });
  const byName = new Map(existing.map(({ page }) => [page.attributes?.name, page]));
  console.log(`  existing ${existing.length} of ${cpp.pages.length} planned`);

  let libraryId = null;
  let catalog = null;
  if (manifest) {
    libraryId = await libraryIdFor(client, appId);
    catalog = await loadCatalog(client);

    // Coverage first. A page cannot be reviewed on frames nobody rendered, and
    // the honest state of the creative pass belongs at the top of the report
    // rather than as a failure nineteen lines into page seven.
    heading('Creative coverage');
    const manifestLocales = new Set(manifest.entries.map((entry) => entry.locale));
    const frameIds = [...new Set(cpp.pages.flatMap((page) => page.frames ?? []))];
    for (const frameId of frameIds) {
      const have = cpp.pages
        .flatMap((page) => page.locales)
        .filter((locale, index, all) => all.indexOf(locale) === index)
        .filter((locale) => matchFrame(manifest.entries, locale, frameId).length > 0);
      const wanted = new Set(cpp.pages.flatMap((page) => page.locales));
      console.log(`  ${String(frameId).padEnd(12)} rendered for ${have.length}/${wanted.size} locale(s)`);
    }
    console.log(`  manifest holds ${manifest.entries.length} file(s) across ${manifestLocales.size} locale(s): ${[...manifestLocales].join(', ')}`);
    if (manifestLocales.size < new Set(cpp.pages.flatMap((page) => page.locales)).size) {
      console.log('  pages will be created for every locale, but only rendered locales get frames.');
      console.log('  the rest keep the template screenshots until the creative pipeline catches up.');
    }
  } else {
    console.log('  no creative manifest: pages will be created, frames will not be placed');
  }

  const failures = [];
  const summary = [];
  // Apple requires the compound create to seed the page with a localization, and
  // a localization needs a locale. The app's primary locale is the only one
  // guaranteed to exist.
  const primaryLocale = app.primaryLocale ?? 'en-US';

  for (const page of cpp.pages) {
    console.log(`\n  ${page.name}  (${page.slug})`);
    let record = byName.get(page.name);

    if (!record) {
      // A dry run has no ids, so the whole sequence a new page needs is printed
      // with placeholder ids. Leaving it at "would create" would hide two
      // thirds of the writes — the localizations and the keyword linkages —
      // which are where a page actually differs from the template it copied.
      console.log(`    new page: ${1 + 1 + page.locales.length + (page.keywordsLocales ?? []).length + (manifest ? page.frames.length : 0)} request(s)`);
      printRequest('POST', '/v1/appCustomProductPages', {
        data: {
          type: 'appCustomProductPages',
          attributes: { name: page.name },
          relationships: {
            app: { data: { type: 'apps', id: appId } },
            appStoreVersionTemplate: {
              data: { type: 'appStoreVersions', id: template.version.id },
            },
          },
        },
      });
      printRequest('POST', '/v1/appCustomProductPageVersions', {
        data: {
          type: 'appCustomProductPageVersions',
          attributes: { deepLink: page.deeplink },
          relationships: {
            appCustomProductPage: { data: { type: 'appCustomProductPages', id: '{pageId}' } },
          },
        },
      });
      for (const locale of page.locales) {
        printRequest('POST', '/v1/appCustomProductPageLocalizations', {
          data: {
            type: 'appCustomProductPageLocalizations',
            attributes: {
              locale,
              promotionalText: page.promotionalText?.[locale] ?? page.promotionalText?.default,
            },
            relationships: {
              appCustomProductPageVersion: {
                data: { type: 'appCustomProductPageVersions', id: '{versionId}' },
              },
            },
          },
        });
      }
      for (const locale of page.keywordsLocales ?? []) {
        printRequest(
          'POST',
          '/v1/appCustomProductPageLocalizations/{localizationId}/relationships/searchKeywords',
          { data: (page.keywords ?? []).map((term) => ({ type: 'appKeywords', id: term })) },
        );
      }
      if (manifest) {
        printRequest(
          'POST',
          '/v1/appAssetLibraryPlacements',
          `x${page.frames.length}  frames ${page.frames.join(',')} -> {localizationId}, one per locale (${page.locales.length})`,
        );
      }
      if (!apply) {
        summary.push({ page: page.name, status: 'would create' });
        continue;
      }
      const created = await client.post('/v1/appCustomProductPages', {
        data: {
          type: 'appCustomProductPages',
          attributes: { name: page.name },
          relationships: {
            app: { data: { type: 'apps', id: appId } },
            // Creating a page alone is rejected:
            //   409 ENTITY_ERROR.RELATIONSHIP.REQUIRED: You must provide a
            //   value for the relationship 'appCustomProductPageVersions'
            // and adding an empty array does not satisfy it. Apple's endpoint is
            // a COMPOUND create: the page, its first version and a localization
            // for the app's primary locale all arrive in one request, linked
            // through the `${new-...-id}` placeholders JSON:API uses for
            // not-yet-created resources. Measured against the live API —
            // appStoreVersionTemplate is not a relationship here at all, and
            // appCustomProductPageLocalizations is not a relationship on the
            // page (only on its version).
            appCustomProductPageVersions: {
              data: [{
                type: 'appCustomProductPageVersions',
                id: '${new-appCustomProductPageVersion-id}',
              }],
            },
          },
        },
        included: [
          {
            type: 'appCustomProductPageVersions',
            id: '${new-appCustomProductPageVersion-id}',
            relationships: {
              appCustomProductPageLocalizations: {
                data: [{
                  type: 'appCustomProductPageLocalizations',
                  id: '${new-appCustomProductPageLocalization-id}',
                }],
              },
            },
          },
          {
            type: 'appCustomProductPageLocalizations',
            id: '${new-appCustomProductPageLocalization-id}',
            attributes: { locale: primaryLocale },
          },
        ],
      });
      record = created.data;
      console.log(`    created ${record.id}`);
    } else {
      console.log(`    present ${record.id}`);
    }

    // The version that carries localizations and the 1.3.0 copy of the page.
    const versions = await client.getAll(
      `/v1/appCustomProductPages/${record.id}/appCustomProductPageVersions?limit=10`,
    );
    let version = versions.find((row) => row.attributes?.state === 'PREPARE_FOR_SUBMISSION')
      ?? versions[0];
    if (!version) {
      console.log('    POST /v1/appCustomProductPageVersions  (deepLink=' + page.deeplink + ')');
      if (!apply) {
        console.log('    (dry run: version created on apply)');
        summary.push({ page: page.name, status: 'would create version' });
        continue;
      }
      const created = await client.post('/v1/appCustomProductPageVersions', {
        data: {
          type: 'appCustomProductPageVersions',
          attributes: { deepLink: page.deeplink },
          relationships: {
            appCustomProductPage: { data: { type: 'appCustomProductPages', id: record.id } },
          },
        },
      });
      version = created.data;
    } else if (page.deeplink && version.attributes?.deepLink !== page.deeplink) {
      console.log(`    PATCH /v1/appCustomProductPageVersions/${version.id}  deepLink=${page.deeplink}`);
      if (apply) {
        await client.patch(`/v1/appCustomProductPageVersions/${version.id}`, {
          data: {
            type: 'appCustomProductPageVersions',
            id: version.id,
            attributes: { deepLink: page.deeplink },
          },
        });
      }
    }
    if (!version) continue;

    const localizations = await client.getAll(
      `/v1/appCustomProductPageVersions/${version.id}/appCustomProductPageLocalizations?limit=200`,
    );
    const byLocale = new Map(localizations.map((row) => [row.attributes.locale, row]));

    for (const locale of page.locales) {
      const promo = page.promotionalText?.[locale] ?? page.promotionalText?.default;
      let localization = byLocale.get(locale);

      if (!localization) {
        console.log(`    POST /v1/appCustomProductPageLocalizations  locale=${locale} promo="${(promo ?? '').slice(0, 60)}…"`);
        if (!apply) continue;
        try {
          const created = await client.post('/v1/appCustomProductPageLocalizations', {
            data: {
              type: 'appCustomProductPageLocalizations',
              attributes: { locale, promotionalText: promo },
              relationships: {
                appCustomProductPageVersion: {
                  data: { type: 'appCustomProductPageVersions', id: version.id },
                },
              },
            },
          });
          localization = created.data;
        } catch (error) {
          failures.push(`${page.name}/${locale} localization: ${error.message}`);
          continue;
        }
      } else if (promo && localization.attributes?.promotionalText !== promo) {
        console.log(`    PATCH /v1/appCustomProductPageLocalizations/${localization.id}  locale=${locale} (promo changed)`);
        if (apply) {
          await client.patch(`/v1/appCustomProductPageLocalizations/${localization.id}`, {
            data: {
              type: 'appCustomProductPageLocalizations',
              id: localization.id,
              attributes: { promotionalText: promo },
            },
          });
        }
      }

      if ((page.keywordsLocales ?? ['en-US']).includes(locale) && (page.keywords ?? []).length > 0) {
        if (localization?.id) {
          try {
            await assignKeywords(client, localization.id, page.keywords, locale);
          } catch (error) {
            failures.push(`${page.name}/${locale} keywords: ${error.message}`);
          }
        } else {
          console.log(`      ${locale} keywords deferred until the localization exists`);
        }
      }

      if (manifest && localization?.id && !apply) {
        console.log(`    POST /v1/appAssetLibraryPlacements  x${(page.frames ?? []).length} frames -> ${locale}`);
      }
      if (manifest && localization?.id && apply) {
        try {
          const result = await placePageFrames({
            client, appId, libraryId, catalog, manifest,
            localizationId: localization.id, page, locale,
          });
          if (result.status === 'ok') {
            if (result.placed > 0) console.log(`      ${locale} placed ${result.placed} frame(s)`);
          } else if (result.status === 'missing-frame') {
            failures.push(`${page.name}/${locale}: frame ${result.frame} is not in the creative manifest`);
          } else if (result.status === 'not-uploaded') {
            failures.push(`${page.name}/${locale}: ${result.path} is not in the asset library (run media.mjs upload --apply)`);
          } else if (result.status === 'bad-group') {
            failures.push(`${page.name}/${locale}: ${result.error}`);
          }
        } catch (error) {
          failures.push(`${page.name}/${locale} frames: ${error.message}`);
        }
      }
    }
    summary.push({ page: page.name, status: 'ok' });
  }

  heading('Summary');
  for (const row of summary) console.log(`  ${row.page.padEnd(24)} ${row.status}`);
  if (failures.length > 0) {
    console.log(`  FAILED (${failures.length}):`);
    for (const failure of failures.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }
  console.log(apply
    ? '\n  Custom product pages need their own review submission; grow.mjs submit lists them.'
    : '\n  Re-run with --apply to create. Nothing was written.');
}

// ---------------------------------------------------------------------------
// ppo
// ---------------------------------------------------------------------------

function validatePpo(ppo) {
  const problems = [];
  const locales = new Set(loadLocales().locales.map((locale) => locale.asc));
  const slugs = new Set();

  for (const experiment of ppo.experiments ?? []) {
    const label = experiment.name ?? experiment.slug;
    if (!experiment.name) problems.push(`${label}: missing name`);
    if (slugs.has(experiment.slug)) problems.push(`${label}: duplicate slug`);
    slugs.add(experiment.slug);
    if (!experiment.variable) problems.push(`${label}: no variable — an experiment must change exactly one`);
    if (!experiment.hypothesis) problems.push(`${label}: no hypothesis`);
    if (!experiment.metric) problems.push(`${label}: no metric`);

    const treatments = experiment.treatments ?? [];
    if (treatments.length === 0) problems.push(`${label}: no treatments`);
    if (treatments.length > 3) problems.push(`${label}: ${treatments.length} treatments, Apple allows 3`);

    // Single-variable: every treatment must carry the same shape of change.
    if (experiment.variable === 'appIcon') {
      for (const treatment of treatments) {
        if (!treatment.appIconName) problems.push(`${label}/${treatment.name}: icon treatment without appIconName`);
        if (treatment.frames) problems.push(`${label}/${treatment.name}: an icon test must not also change screenshots`);
      }
    } else {
      for (const treatment of treatments) {
        if (!Array.isArray(treatment.frames) || treatment.frames.length === 0) {
          problems.push(`${label}/${treatment.name}: no frames`);
        }
        if (treatment.appIconName) problems.push(`${label}/${treatment.name}: a screenshot test must not also change the icon`);
        if ((treatment.frames ?? []).length > MAX_PER_GROUP) {
          problems.push(`${label}/${treatment.name}: ${treatment.frames.length} frames, Apple shows at most ${MAX_PER_GROUP}`);
        }
      }
      // Single-variable in the strong sense: either the same frames in a
      // different order, or the same opening sequence truncated to a different
      // depth. Anything else changes two things and the result cannot be
      // attributed to either.
      if (experiment.variable === 'leadFrame') {
        // Sorted as strings: frame references are semantic ids, and only a
        // consistent order across treatments matters for the comparison.
        const sets = treatments.map((treatment) => [...(treatment.frames ?? [])].sort((a, b) => String(a).localeCompare(String(b))).join(','));
        if (new Set(sets).size !== 1) {
          problems.push(`${label}: every treatment must show the same frames — a lead-frame test changes order only (${sets.join(' | ')})`);
        }
        const leads = treatments.map((treatment) => (treatment.frames ?? [])[0]);
        if (new Set(leads).size !== leads.length) {
          problems.push(`${label}: two treatments share the same lead frame, so they are the same page`);
        }
      }
      if (experiment.variable === 'frameCount') {
        const byLength = [...treatments].sort((a, b) => a.frames.length - b.frames.length);
        for (let index = 0; index + 1 < byLength.length; index += 1) {
          const shorter = byLength[index].frames;
          const longer = byLength[index + 1].frames;
          const isPrefix = shorter.every((frame, position) => longer[position] === frame);
          if (!isPrefix) {
            problems.push(`${label}: "${byLength[index].name}" is not a prefix of "${byLength[index + 1].name}", so the test changes order as well as depth`);
          }
        }
        if (new Set(treatments.map((t) => t.frames.length)).size !== treatments.length) {
          problems.push(`${label}: two treatments have the same length, so there is nothing to compare`);
        }
      }
    }

    for (const locale of experiment.locales ?? []) {
      if (!locales.has(locale)) problems.push(`${label}: unknown locale ${locale}`);
    }
    const proportion = experiment.trafficProportion ?? ppo.trafficProportion;
    if (proportion !== undefined && (proportion < 1 || proportion > 100)) {
      problems.push(`${label}: trafficProportion ${proportion} is outside 1..100`);
    }
  }
  return problems;
}

const priorityFrame = (treatment) => (treatment.frames ?? [])[0];

async function cmdPpo() {
  const { client, appId } = await connect({ dryRun: !apply, log: requestLogger });
  const ppo = loadGrowthFile('ppo.json', flagValue('ppo'));
  const manifest = loadManifest(flagValue('manifest') ?? DEFAULT_MANIFEST);

  heading(`Product page optimization (${ppo.experiments.length} experiments)`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'dry run (prints the exact requests)'}`);

  const problems = validatePpo(ppo);
  if (problems.length > 0) {
    heading(`Invalid (${problems.length})`);
    for (const problem of problems.slice(0, 40)) console.log(`  ${problem}`);
    throw new Error('store/asc/ppo.json is not publishable');
  }

  const live = await listExperiments(client, appId);
  const byName = new Map(live.map((row) => [row.experiment.attributes?.name, row]));
  console.log(`  existing ${live.length} on the app`);

  const running = live.filter((row) => row.experiment.attributes?.state === 'IN_REVIEW'
    || row.experiment.attributes?.state === 'RUNNING'
    || row.experiment.attributes?.state === 'WAITING_FOR_REVIEW');
  if (running.length > 0) {
    console.log(`  already active: ${running.map((row) => row.experiment.attributes.name).join(', ')}`);
  }

  const failures = [];

  if (ppo.runPolicy === 'sequential' && startExperiment) {
    const requested = args.filter((arg) => arg === '--start' || arg.startsWith('--experiment='));
    const target = flagValue('experiment');
    if (!target) {
      console.log('\n  --start needs --experiment=<slug>: this file holds several experiments and only one may run.');
      process.exitCode = 1;
      return;
    }
    if (running.length > 0) {
      console.log(`\n  refusing to start ${target}: ${running.length} experiment(s) already active.`);
      console.log('  Concurrent PPO splits the same traffic across cells and neither result is readable.');
      process.exitCode = 1;
      return;
    }
    if (running.length === 0 && requested.length === 0) {
      // fallthrough
    }
  }

  let libraryId = null;
  let catalog = null;
  if (manifest) {
    libraryId = await libraryIdFor(client, appId);
    catalog = await loadCatalog(client);
  }

  // Product page optimization edits the page that is live today, so experiments
  // attach to the READY_FOR_SALE version. The draft has no page for traffic.
  const experimentVersions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState`,
  );
  const liveVersion = experimentVersions.find((v) => v.attributes.appStoreState === 'READY_FOR_SALE');
  if (!liveVersion) {
    console.log('\n  No READY_FOR_SALE version: there is no live product page to optimize.');
    process.exitCode = 1;
    return;
  }
  const targetVersionId = liveVersion.id;
  console.log(`\n  live page: ${liveVersion.attributes.versionString} (${targetVersionId})`);

  // `--experiment` selects one experiment, for `--start` and for creation. Apple
  // permits a single experiment in PREPARE_FOR_SUBMISSION at a time ("Cannot
  // create new experiment because another experiment is in draft state"), so
  // creating the whole file in one run cannot work; it must be one at a time.
  const onlyExperiment = flagValue('experiment');

  for (const experiment of ppo.experiments) {
    if (onlyExperiment && experiment.slug !== onlyExperiment) continue;
    console.log(`\n  ${experiment.name}`);
    console.log(`    variable  ${experiment.variable}`);
    console.log(`    metric    ${experiment.metric}`);

    let row = byName.get(experiment.name);
    if (!row) {
      printRequest('POST', '/v1/appStoreVersionExperiments', {
        data: {
          type: 'appStoreVersionExperiments',
          attributes: {
            name: experiment.name,
            trafficProportion: experiment.trafficProportion ?? ppo.trafficProportion ?? 100,
          },
          relationships: {
            appStoreVersion: { data: { type: 'appStoreVersions', id: targetVersionId } },
          },
        },
      });
      if (!apply) {
        // Print the whole tree, not just the parent: treatments and their
        // localizations are where a PPO experiment actually differs, and a dry
        // run that hides them cannot be approved.
        const locales = experiment.locales ?? ppo.defaultLocales ?? ['en-US'];
        for (const treatment of experiment.treatments) {
          printRequest('POST', '/v1/appStoreVersionExperimentTreatments', {
            data: {
              type: 'appStoreVersionExperimentTreatments',
              attributes: {
                name: treatment.name,
                ...(treatment.appIconName ? { appIconName: treatment.appIconName } : {}),
              },
              relationships: {
                appStoreVersionExperiment: {
                  data: { type: 'appStoreVersionExperiments', id: '{experimentId}' },
                },
              },
            },
          });
          for (const locale of locales) {
            printRequest('POST', '/v1/appStoreVersionExperimentTreatmentLocalizations', {
              data: {
                type: 'appStoreVersionExperimentTreatmentLocalizations',
                attributes: { locale },
                relationships: {
                  appStoreVersionExperimentTreatment: {
                    data: { type: 'appStoreVersionExperimentTreatments', id: '{treatmentId}' },
                  },
                },
              },
            });
          }
          if (treatment.frames) {
            printRequest(
              'POST',
              '/v1/appAssetLibraryPlacements',
              `x${treatment.frames.length}  frames ${treatment.frames.join(',')} -> {treatmentLocalizationId}, one per locale (${locales.length})`,
            );
          }
        }
        console.log('    then: PATCH {experimentId} {"started": true}   (only with --start --experiment=' + experiment.slug + ')');
        continue;
      }
      const created = await client.post('/v1/appStoreVersionExperiments', {
        data: {
          type: 'appStoreVersionExperiments',
          attributes: {
            name: experiment.name,
            trafficProportion: experiment.trafficProportion ?? ppo.trafficProportion ?? 100,
          },
          // An experiment hangs off a version, not off the app. Product page
          // optimization tests the page that is currently live, so this is the
          // READY_FOR_SALE version; a draft has no page for traffic to land on.
          relationships: {
            appStoreVersion: { data: { type: 'appStoreVersions', id: targetVersionId } },
          },
        },
      });
      row = { experiment: created.data, treatments: [] };
      console.log(`    created ${created.data.id}`);
    } else {
      console.log(`    present ${row.experiment.id}  state=${row.experiment.attributes?.state}`);
    }

    const haveTreatments = new Map(
      row.treatments.map(({ treatment }) => [treatment.attributes?.name, treatment]),
    );

    for (const treatment of experiment.treatments) {
      let record = haveTreatments.get(treatment.name);
      if (!record) {
        console.log(`    POST /v1/appStoreVersionExperimentTreatments  name="${treatment.name}"`
          + `${treatment.appIconName ? ` appIconName=${treatment.appIconName}` : ''}`);
        if (!apply) continue;
        try {
          const created = await client.post('/v1/appStoreVersionExperimentTreatments', {
            data: {
              type: 'appStoreVersionExperimentTreatments',
              attributes: {
                name: treatment.name,
                ...(treatment.appIconName ? { appIconName: treatment.appIconName } : {}),
              },
              relationships: {
                appStoreVersionExperiment: {
                  data: { type: 'appStoreVersionExperiments', id: row.experiment.id },
                },
              },
            },
          });
          record = created.data;
        } catch (error) {
          failures.push(`${experiment.slug}/${treatment.name}: ${error.message}`);
          continue;
        }
      } else {
        console.log(`    treatment ${treatment.name} present`);
      }
      if (!record?.id) continue;

      // Localizations, then the frames for the treatment's own page. Ascend
      // the treatment's relationship path: the filtered collection
      // (`?filter[appStoreVersionExperimentTreatment]=`) silently returns
      // nothing, so every re-run tried to recreate localizations that already
      // existed and reported the 409 duplicates as failures.
      const localizations = await client.getAll(
        `/v1/appStoreVersionExperimentTreatments/${record.id}/appStoreVersionExperimentTreatmentLocalizations?limit=200`,
      ).catch(() => []);
      const haveLocales = new Map(localizations.map((l) => [l.attributes?.locale, l]));

      for (const locale of experiment.locales ?? ppo.defaultLocales ?? ['en-US']) {
        let localization = haveLocales.get(locale);
        if (!localization) {
          console.log(`      POST /v1/appStoreVersionExperimentTreatmentLocalizations  locale=${locale}`);
          if (!apply) continue;
          try {
            const created = await client.post('/v1/appStoreVersionExperimentTreatmentLocalizations', {
              data: {
                type: 'appStoreVersionExperimentTreatmentLocalizations',
                attributes: { locale },
                relationships: {
                  appStoreVersionExperimentTreatment: {
                    data: { type: 'appStoreVersionExperimentTreatments', id: record.id },
                  },
                },
              },
            });
            localization = created.data;
          } catch (error) {
            // A duplicate means it is already there, which is what the call is
            // for. Anything else is a real failure.
            if (String(error.message).includes('DUPLICATE')) {
              const rows = await client.getAll(
                `/v1/appStoreVersionExperimentTreatments/${record.id}/appStoreVersionExperimentTreatmentLocalizations?limit=200`,
              ).catch(() => []);
              localization = rows.find((l) => l.attributes?.locale === locale);
              if (localization) console.log(`      ${locale} localization already present`);
            }
            if (!localization) {
              failures.push(`${experiment.slug}/${treatment.name}/${locale}: ${error.message}`);
              continue;
            }
          }
        }
        if (!localization?.id) continue;

        if (!manifest) {
          console.log(`      ${locale} frames: no creative manifest, skipped`);
          continue;
        }
        const wanted = [];
        for (const frame of treatment.frames ?? []) {
          const candidates = matchFrame(manifest.entries, locale, frame);
          if (candidates.length === 0) {
            failures.push(`${experiment.slug}/${treatment.name}/${locale}: frame ${frame} not in the creative manifest`);
          }
          wanted.push(...candidates);
        }
        if (!apply) {
          if (wanted.length > 0) {
            console.log(`      POST /v1/appAssetLibraryPlacements  x${wanted.length} frames -> treatment ${locale}`);
          }
          continue;
        }
        const { byRef } = await libraryImages(client, libraryId);
        const existingPlacements = await client.getAll(
          `/v1/appStoreVersionExperimentTreatmentLocalizations/${localization.id}/placements?limit=200&include=image`,
        ).catch(() => []);
        for (const entry of wanted) {
          const resolved = resolveGroup(catalog, { ...entry, placementType: PLACEMENT_TYPES.frame });
          if (resolved.error) { failures.push(`${experiment.slug}: ${resolved.error}`); continue; }
          const asset = byRef.get(sha256File(entry.filePath));
          if (!asset) {
            failures.push(`${experiment.slug}: ${entry.path} is not in the asset library`);
            continue;
          }
          await placeImage(client, {
            imageId: asset.id,
            placementType: PLACEMENT_TYPES.frame,
            placementGroup: resolved.group,
            targetKind: 'appStoreVersionExperimentTreatmentLocalization',
            targetId: localization.id,
            existing: existingPlacements,
          });
        }
      }
    }

    // Starting is the irreversible step: it begins spending live traffic.
    if (startExperiment && flagValue('experiment') === experiment.slug) {
      console.log(`    PATCH /v1/appStoreVersionExperiments/${row.experiment.id}  {"started": true}`);
      if (apply) {
        await client.patch(`/v1/appStoreVersionExperiments/${row.experiment.id}`, {
          data: {
            type: 'appStoreVersionExperiments',
            id: row.experiment.id,
            attributes: { started: true },
          },
        });
        console.log('    started. Traffic is now being split; results are in App Analytics.');
      }
    } else {
      console.log('    not started (pass --start --experiment=' + experiment.slug + ' to launch)');
    }
  }

  heading('Notes');
  console.log('  An experiment is created and then started; creating it costs nothing and shows to nobody.');
  console.log('  Starting spends live traffic, so it needs --start and a single --experiment.');
  if (ppo.experiments.some((experiment) => experiment.variable === 'appIcon')) {
    console.log('  Icon treatments reference icons by name. Apple exposes no endpoint that lists or uploads');
    console.log('  app icons, so those names must already exist in App Store Connect before --apply.');
  }
  if (failures.length > 0) {
    console.log(`  FAILED (${failures.length}):`);
    for (const failure of failures.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }
  if (!apply) console.log('\n  Re-run with --apply to create. Nothing was written.');
}

// ---------------------------------------------------------------------------
// events
// ---------------------------------------------------------------------------

function validateEvents(events, limits) {
  const problems = [];
  const locales = new Set(loadLocales().locales.map((locale) => locale.asc));
  const references = new Set();

  for (const event of events) {
    const label = event.referenceName ?? event.slug ?? '(unnamed)';
    if (!event.referenceName) problems.push(`${label}: missing referenceName`);
    if (references.has(event.referenceName)) problems.push(`${label}: duplicate referenceName`);
    references.add(event.referenceName);
    if (!event.badge) problems.push(`${label}: no badge`);
    if (!event.purpose) problems.push(`${label}: no purpose`);
    if (!event.deeplink) problems.push(`${label}: no deeplink`);
    if (!event.start || !event.end) problems.push(`${label}: missing start or end`);

    if (event.start && event.end) {
      const start = new Date(event.start);
      const end = new Date(event.end);
      if (end <= start) problems.push(`${label}: end ${event.end} is not after start ${event.start}`);
      const duration = days(start, end);
      if (limits?.maxDurationDays && duration > limits.maxDurationDays + 1) {
        problems.push(`${label}: runs ${duration.toFixed(1)} days, Apple allows ${limits.maxDurationDays}`);
      }
      if (event.publishStart) {
        const lead = days(new Date(event.publishStart), start);
        if (limits?.maxLeadDaysBeforeStart && lead > limits.maxLeadDaysBeforeStart) {
          problems.push(`${label}: publishStart is ${lead.toFixed(1)} days before start, Apple allows ${limits.maxLeadDaysBeforeStart}`);
        }
      }
    }

    for (const [locale, copy] of Object.entries(event.localizations ?? {})) {
      if (!locales.has(locale)) problems.push(`${label}: unknown locale ${locale}`);
      for (const [field, cap] of Object.entries(limits ?? {})) {
        if (typeof cap !== 'number' || !field.endsWith('Description') && field !== 'name') continue;
        const value = copy[field];
        if (typeof value === 'string' && value.length > cap) {
          problems.push(`${label}/${locale}: ${field} is ${value.length} chars, Apple allows ${cap}`);
        }
      }
      if (!copy.name) problems.push(`${label}/${locale}: no name`);
    }
  }
  return problems;
}

/** Whether an event's window has already closed. Stale is not an error. */
function eventWindow(event) {
  const nowDate = now();
  const start = event.start ? new Date(event.start) : null;
  const end = event.end ? new Date(event.end) : null;
  if (!start || !end) return 'unknown';
  if (end < nowDate) return 'expired';
  if (start > nowDate) return 'scheduled';
  return 'live';
}

async function cmdEvents() {
  const { client, appId } = await connect({ dryRun: !apply, log: requestLogger });
  const file = loadGrowthFile('events.json', flagValue('events'));
  const events = file.events ?? [];
  const limits = file.limits ?? {};

  heading(`In-app events (${events.length})`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'dry run (prints the exact requests)'}`);

  const problems = validateEvents(events, limits);
  if (problems.length > 0) {
    heading(`Invalid (${problems.length})`);
    for (const problem of problems.slice(0, 40)) console.log(`  ${problem}`);
    throw new Error('store/asc/events.json is not publishable');
  }

  const live = await listEvents(client, appId);
  const byReference = new Map(live.map((row) => [row.attributes?.referenceName, row]));
  console.log(`  existing ${live.length} on the app`);

  const failures = [];
  let stale = 0;

  for (const event of events) {
    const window = eventWindow(event);
    console.log(`\n  ${event.referenceName}  (${window}, ${event.start.slice(0, 10)} to ${event.end.slice(0, 10)})`);

    // An event past its window is reported and skipped. Erroring here would
    // make an old data file block every later event, which is how a tool gets
    // abandoned.
    if (window === 'expired') {
      stale += 1;
      console.log('    expired: window closed, skipped. Prune it from events.json or move its dates.');
      continue;
    }

    let record = byReference.get(event.referenceName);
    if (!record) {
      const territories = event.territories ?? file.defaultTerritories ?? [];
      const schedule = {
        territories,
        publishStart: event.publishStart,
        eventStart: event.start,
        eventEnd: event.end,
      };
      printRequest('POST', '/v1/appEvents', {
        data: {
          type: 'appEvents',
          attributes: {
            referenceName: event.referenceName,
            badge: event.badge,
            purpose: event.purpose,
            priority: event.priority ?? 'HIGH',
            // No `purchaseRequirement` here: Apple rejects the whole create
            // with "'NO_PURCHASE_REQUIRED' is not a valid purchaseRequirement
            // value" and does not list a valid enum, so the attribute is not
            // settable on an AppEvent. Sending an unknown value is worse than
            // omitting it, because it fails the create instead of being ignored.
            primaryLocale: event.primaryLocale ?? file.primaryLocale,
            deepLink: event.deeplink,
            territorySchedules: [schedule],
          },
          relationships: { app: { data: { type: 'apps', id: appId } } },
        },
      });
      if (!apply) {
        for (const [locale, copy] of Object.entries(event.localizations ?? {})) {
          printRequest('POST', '/v1/appEventLocalizations', {
            data: {
              type: 'appEventLocalizations',
              attributes: {
                locale,
                name: copy.name,
                shortDescription: copy.shortDescription,
                longDescription: copy.longDescription,
              },
              relationships: {
                appEvent: { data: { type: 'appEvents', id: '{eventId}' } },
              },
            },
          });
        }
        continue;
      }
      try {
        const created = await client.post('/v1/appEvents', {
          data: {
            type: 'appEvents',
            attributes: {
              referenceName: event.referenceName,
              badge: event.badge,
              purpose: event.purpose,
              priority: event.priority ?? 'HIGH',
              // No `purchaseRequirement` here: Apple rejects the whole create
            // with "'NO_PURCHASE_REQUIRED' is not a valid purchaseRequirement
            // value" and does not list a valid enum, so the attribute is not
            // settable on an AppEvent. Sending an unknown value is worse than
            // omitting it, because it fails the create instead of being ignored.
              primaryLocale: event.primaryLocale ?? file.primaryLocale,
              deepLink: event.deeplink,
              territorySchedules: [schedule],
            },
            relationships: { app: { data: { type: 'apps', id: appId } } },
          },
        });
        record = created.data;
        console.log(`    created ${record.id}`);
      } catch (error) {
        failures.push(`${event.referenceName}: ${error.message}`);
        continue;
      }
    } else {
      console.log(`    present ${record.id}  state=${record.attributes?.eventState}`);
    }
    if (!record?.id) continue;

    const localizations = await client.getAll(
      `/v1/appEvents/${record.id}/localizations?limit=200`,
    ).catch(() => []);
    const byLocale = new Map(localizations.map((row) => [row.attributes?.locale, row]));

    for (const [locale, copy] of Object.entries(event.localizations ?? {})) {
      const existing = byLocale.get(locale);
      if (!existing) {
        if (!apply) {
          printRequest('POST', '/v1/appEventLocalizations', {
            data: {
              type: 'appEventLocalizations',
              attributes: {
                locale,
                name: copy.name,
                shortDescription: copy.shortDescription,
                longDescription: copy.longDescription,
              },
              relationships: {
                appEvent: { data: { type: 'appEvents', id: record.id } },
              },
            },
          });
          continue;
        }
        console.log(`    POST /v1/appEventLocalizations  locale=${locale} name="${copy.name}"`);
        try {
          await client.post('/v1/appEventLocalizations', {
            data: {
              type: 'appEventLocalizations',
              attributes: {
                locale,
                name: copy.name,
                shortDescription: copy.shortDescription,
                longDescription: copy.longDescription,
              },
              relationships: {
                appEvent: { data: { type: 'appEvents', id: record.id } },
              },
            },
          });
        } catch (error) {
          failures.push(`${event.referenceName}/${locale}: ${error.message}`);
        }
        continue;
      }
      const changed = ['name', 'shortDescription', 'longDescription']
        .filter((field) => (existing.attributes?.[field] ?? '') !== (copy[field] ?? ''));
      if (changed.length > 0) {
        console.log(`    PATCH /v1/appEventLocalizations/${existing.id}  locale=${locale}  ${changed.join(', ')}`);
        if (apply) {
          await client.patch(`/v1/appEventLocalizations/${existing.id}`, {
            data: {
              type: 'appEventLocalizations',
              id: existing.id,
              attributes: Object.fromEntries(changed.map((field) => [field, copy[field]])),
            },
          });
        }
      } else {
        console.log(`    ${locale} already current`);
      }
    }
  }

  heading('Summary');
  console.log(`  ${events.length - stale} publishable, ${stale} expired and skipped`);
  console.log('  Event media (card 16:9, details 9:16) is placed by media.mjs once the manifest has it.');
  if (failures.length > 0) {
    console.log(`  FAILED (${failures.length}):`);
    for (const failure of failures.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }
  if (!apply) console.log('\n  Re-run with --apply to create. Nothing was written.');
}

// ---------------------------------------------------------------------------
// submit
// ---------------------------------------------------------------------------

/**
 * Assembles a submission and refuses when anything is missing.
 *
 * A review submission can carry several item types at once — the app version,
 * each custom product page version, each in-app event and each experiment.
 * Apple reviews them together, so a page whose frames are missing blocks the
 * whole release rather than just itself. That is why this check is exhaustive
 * and reports every gap, not the first.
 */
async function cmdSubmit() {
  const { app, client, appId } = await connect({ dryRun: !apply, log: requestLogger });
  const versionString = app.marketingVersion;
  const buildId = flagValue('build');

  heading(`Submission for ${versionString}`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'dry run (prints the exact requests)'}`);

  const checks = [];
  const record = (ok, name, detail) => checks.push({ ok, name, detail });

  // `--audit` runs every read-only check against the version that is actually
  // live. Without it a pipeline can only answer "is my draft complete", never
  // "what does the page customers see right now look like" — and the second
  // question is the one that explains a 0-rating, low-conversion listing.
  const audit = args.includes('--audit');
  const resolved = await editableVersionFor(client, appId, versionString);
  const editable = resolved.version;
  const version = editable
    ?? (audit
      ? (resolved.versions.find((row) => row.attributes?.appStoreState === 'READY_FOR_SALE')
        ?? resolved.versions[0])
      : null);
  record(Boolean(editable), 'editable version', editable
    ? `${versionString} in PREPARE_FOR_SUBMISSION (${editable.id})`
    : audit
      ? `auditing live ${version?.attributes?.versionString ?? '(none)'} — a submission needs ${versionString} in PREPARE_FOR_SUBMISSION (publish.mjs prepare --apply)`
      : `no ${versionString} in PREPARE_FOR_SUBMISSION; live: ${resolved.versions.map((v) => v.attributes.versionString).join(', ')} — run publish.mjs prepare --apply`);

  if (version) {
    // --- copy -------------------------------------------------------------
    const localizations = await client.getAll(
      `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200`,
    );
    const wanted = loadLocales().locales.length;
    const present = new Set(localizations.map((row) => row.attributes.locale));
    record(present.size >= wanted, 'listing localizations',
      `${present.size}/${wanted}${present.size >= wanted ? '' : ' — run publish.mjs prepare --apply then details --apply'}`);

    const validation = validateListings();
    record(validation.errors.length === 0, 'listing copy validates',
      `${validation.errors.length} error(s), ${validation.warnings.length} warning(s)${validation.errors.length ? `: ${validation.errors[0]}` : ''}`);

    // Half-translated fields are the failure this catches: a locale row that
    // exists with an empty description submits and gets rejected.
    const empty = localizations.filter((row) => {
      const a = row.attributes ?? {};
      return !a.description || !a.keywords || !a.whatsNew;
    });
    record(empty.length === 0, 'every localization has copy',
      empty.length === 0 ? 'description, keywords and what\'s new present in all locales' : `empty in: ${empty.map((row) => row.attributes.locale).join(', ')}`);

    // --- media ------------------------------------------------------------
    const groupsByLocale = new Map();
    for (const localization of localizations) {
      const placements = await client.getAll(
        `/v1/appStoreVersionLocalizations/${localization.id}/placements?limit=200&include=image`,
      );
      const counts = new Map();
      for (const placement of placements) {
        if (placement.attributes?.placementType !== 'APP_SCREENSHOT') continue;
        const group = placement.attributes.placementGroup;
        counts.set(group, (counts.get(group) ?? 0) + 1);
      }
      groupsByLocale.set(localization.attributes.locale, counts);
    }
    const primary = groupsByLocale.get(app.primaryLocale) ?? new Map();
    const iphoneGroups = [...primary.keys()].filter((group) => group.startsWith('IPHONE_'));
    record(primary.size > 0, 'screenshots on the primary locale',
      primary.size === 0
        ? `no APP_SCREENSHOT placements on ${app.primaryLocale}; run media.mjs upload --apply`
        : [...primary].map(([group, count]) => `${group}=${count}`).join(' '));
    record(iphoneGroups.includes('IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE'), '6.9-inch iPhone set',
      iphoneGroups.includes('IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE')
        ? 'present (1320x2868)'
        : `missing; present: ${iphoneGroups.join(', ') || 'none'}. Apple's featured shelf is the 6.9-inch set.`);
    record(primary.has('IPAD_13_PROFILE') || primary.has('IPAD_129_PROFILE'), 'iPad set',
      primary.has('IPAD_13_PROFILE') || primary.has('IPAD_129_PROFILE')
        ? 'present'
        : 'missing. An iPhone-only gallery looks broken on iPad, which is a supported device in this build.');
    const overCap = [...primary].filter(([, count]) => count > MAX_PER_GROUP);
    record(overCap.length === 0, 'within the 10-per-group cap',
      overCap.length === 0 ? 'ok' : overCap.map(([group, count]) => `${group}=${count}`).join(' '));

    // --- build ------------------------------------------------------------
    let attachedBuild = null;
    try {
      const build = await client.get(`/v1/appStoreVersions/${version.id}/build`);
      attachedBuild = build?.data ?? null;
    } catch {
      attachedBuild = null;
    }
    if (buildId) {
      record(true, 'build to attach', `--build=${buildId} (PATCH overrides whatever is attached)`);
    } else {
      record(Boolean(attachedBuild), 'build attached',
        attachedBuild
          ? `${attachedBuild.id} build ${buildId ?? ''}`.trim()
          : 'no build; upload one and pass --build=<id>');
    }

    // --- growth surfaces --------------------------------------------------
    const cpp = await client.getAll(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
    const local = readStoreFile('cpp.json');
    record(cpp.length >= (local.pages?.length ?? 0), 'custom product pages',
      `${cpp.length} live of ${local.pages?.length ?? 0} planned — run grow.mjs cpp --apply`);

    const cppVersions = [];
    for (const page of cpp) {
      const pageVersions = await client.getAll(
        `/v1/appCustomProductPages/${page.id}/appCustomProductPageVersions?limit=10`,
      );
      for (const pageVersion of pageVersions) cppVersions.push({ page, pageVersion });
    }

    const events = await listEvents(client, appId);
    const localEvents = readStoreFile('events.json');
    const publishable = (localEvents.events ?? []).filter((event) => eventWindow(event) !== 'expired');
    record(events.length >= publishable.length, 'in-app events',
      `${events.length} live of ${publishable.length} publishable — run grow.mjs events --apply`);

    const experiments = await listExperiments(client, appId);
    const localPpo = readStoreFile('ppo.json');
    // A planned-but-absent experiment is a backlog item, not a submission
    // blocker. Apple reviews the version; an experiment that is not in the
    // submission is simply not reviewed, and the version converts on the page
    // that is live either way. What must hold is that the experiment that does
    // exist has its treatments placed. The rest are created as the running one
    // concludes, because Apple splits live traffic across one experiment at a
    // time; PPO 1 additionally needs app-icon variants, which no API can upload.
    const plannedCount = localPpo.experiments?.length ?? 0;
    record(experiments.length > 0, 'PPO experiments',
      experiments.length > 0
        ? `${experiments.length} live of ${plannedCount} planned (the rest are created as the running one concludes) — status: grow.mjs status`
        : `none live of ${plannedCount} planned — run grow.mjs ppo --apply`);

    // --- report -----------------------------------------------------------
    heading('Checks');
    for (const check of checks) {
      console.log(`  ${check.ok ? 'PASS' : 'FAIL'}  ${check.name.padEnd(32)} ${check.detail}`);
    }
    const failed = checks.filter((check) => !check.ok);

    heading('What this submission would carry');
    console.log(`  appStoreVersion                      ${versionString} (${version.id})`);
    for (const { page, pageVersion } of cppVersions) {
      console.log(`  appCustomProductPageVersion          ${page.attributes?.name} v${pageVersion.attributes?.version ?? '?'} (${pageVersion.id})`);
    }
    for (const event of events) {
      console.log(`  appEvent                             ${event.attributes?.referenceName} (${event.id})`);
    }
    for (const row of experiments) {
      console.log(`  appStoreVersionExperiment          ${row.experiment.attributes?.name} (${row.experiment.id})`);
    }

    heading('Requests');
    if (buildId) {
      console.log(`  PATCH /v1/appStoreVersions/${version.id}/relationships/build`);
      console.log(`        {"data":{"type":"builds","id":"${buildId}"}}`);
    }
    console.log('  POST  /v1/reviewSubmissions');
    console.log(`        {"data":{"type":"reviewSubmissions","relationships":{"app":{"data":{"type":"apps","id":"${appId}"}}}}}`);
    console.log('  POST  /v1/reviewSubmissionItems   (one per row above)');
    console.log('  PATCH /v1/reviewSubmissions/{id}');
    console.log('        {"data":{"type":"reviewSubmissions","id":"...","attributes":{"submitted":true}}}');

    if (failed.length > 0) {
      heading(`Refusing to submit: ${failed.length} check(s) failed`);
      for (const check of failed) console.log(`  ${check.name}: ${check.detail}`);
      process.exitCode = 1;
      return;
    }

    if (!editable) {
      heading('Refusing to submit');
      console.log(`  auditing ${version.attributes?.versionString}, which is live and closed to edits.`);
      console.log(`  run: node scripts/asc/publish.mjs prepare --apply   (creates ${versionString})`);
      process.exitCode = 1;
      return;
    }

    if (!apply) {
      console.log('\n  All required checks pass. Re-run with --apply to create and submit. Nothing was written.');
      return;
    }

    if (buildId) {
      await client.patch(`/v1/appStoreVersions/${version.id}/relationships/build`, {
        data: { type: 'builds', id: buildId },
      });
    }
    const submissions = await client.getAll(
      `/v1/apps/${appId}/reviewSubmissions?limit=10&fields[reviewSubmissions]=state,submittedDate`,
    );
    let submission = submissions.find((row) => row.attributes?.state === 'READY_FOR_REVIEW'
      || row.attributes?.state === 'WAITING_FOR_REVIEW');
    if (!submission) {
      const created = await client.post('/v1/reviewSubmissions', {
        data: {
          type: 'reviewSubmissions',
          relationships: { app: { data: { type: 'apps', id: appId } } },
        },
      });
      submission = created.data;
    }
    const items = [
      { kind: 'appStoreVersion', id: version.id, type: 'appStoreVersions' },
      ...cppVersions.map(({ pageVersion }) => ({
        kind: 'appCustomProductPageVersion', id: pageVersion.id, type: 'appCustomProductPageVersions',
      })),
      ...events.map((event) => ({ kind: 'appEvent', id: event.id, type: 'appEvents' })),
      ...experiments.map((row) => ({
        kind: 'appStoreVersionExperiment', id: row.experiment.id, type: 'appStoreVersionExperiments',
      })),
    ];
    for (const item of items) {
      await client.post('/v1/reviewSubmissionItems', {
        data: {
          type: 'reviewSubmissionItems',
          relationships: {
            reviewSubmission: { data: { type: 'reviewSubmissions', id: submission.id } },
            [item.kind]: { data: { type: item.type, id: item.id } },
          },
        },
      });
    }
    await client.patch(`/v1/reviewSubmissions/${submission.id}`, {
      data: {
        type: 'reviewSubmissions',
        id: submission.id,
        attributes: { submitted: true },
      },
    });
    console.log(`\n  Submitted ${items.length} item(s). App Review usually responds in 24-48 hours.`);
    return;
  }

  heading('Checks');
  for (const check of checks) {
    console.log(`  ${check.ok ? 'PASS' : 'FAIL'}  ${check.name.padEnd(32)} ${check.detail}`);
  }

  // A blocked version must not hide the rest of the picture: the growth
  // surfaces can all be created and reviewed only after the version exists, so
  // the report says how much is already in place and how much is not.
  heading('Growth surfaces (independent of the version)');
  const cpp = await client.getAll(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
  const events = await listEvents(client, appId);
  const experiments = await listExperiments(client, appId);
  const localCppCount = readStoreFile('cpp.json').pages?.length ?? 0;
  const localEventCount = (readStoreFile('events.json').events ?? [])
    .filter((event) => eventWindow(event) !== 'expired').length;
  const localExperimentCount = readStoreFile('ppo.json').experiments?.length ?? 0;
  console.log(`  custom product pages   ${cpp.length} live of ${localCppCount} planned`);
  console.log(`  in-app events          ${events.length} live of ${localEventCount} publishable`);
  console.log(`  PPO experiments        ${experiments.length} live of ${localExperimentCount} planned`);

  heading('Requests once the version exists');
  console.log(`  PATCH /v1/appStoreVersions/{versionId}/relationships/build   {"data":{"type":"builds","id":"<build>"}}`);
  console.log('  POST  /v1/reviewSubmissions');
  console.log(`        {"data":{"type":"reviewSubmissions","relationships":{"app":{"data":{"type":"apps","id":"${appId}"}}}}}`);
  console.log('  POST  /v1/reviewSubmissionItems   one per: appStoreVersion, each appCustomProductPageVersion,');
  console.log('                                    each appEvent, each appStoreVersionExperiment');
  console.log('  PATCH /v1/reviewSubmissions/{id}  {"data":{"type":"reviewSubmissions","id":"...","attributes":{"submitted":true}}}');

  process.exitCode = 1;
}

// ---------------------------------------------------------------------------
// status
// ---------------------------------------------------------------------------

async function cmdStatus() {
  const { app, client, appId } = await connect({ dryRun: true, log: () => {} });

  heading('App');
  console.log(`  ${appId}  ${app.bundleId}  target version ${app.marketingVersion}`);

  heading('Versions');
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState`,
  );
  for (const version of versions) {
    console.log(`  ${String(version.attributes.versionString).padEnd(8)} ${version.attributes.appStoreState}`);
  }
  const editable = versions.find((v) => v.attributes.appStoreState === 'PREPARE_FOR_SUBMISSION');
  console.log(editable ? `  editable: ${editable.attributes.versionString}` : '  no editable version (publish.mjs prepare)');

  heading('Custom product pages');
  const cpp = await listCustomProductPages(client, appId);
  if (cpp.length === 0) {
    console.log('  none live');
  } else {
    for (const { page, versions: pageVersions } of cpp) {
      console.log(`  ${page.attributes?.name}  visible=${page.attributes?.visible}  ${page.id}`);
      for (const { version, localizations } of pageVersions) {
        console.log(`    v${version.attributes?.version ?? '?'}  ${version.attributes?.state ?? ''}  deepLink=${version.attributes?.deepLink ?? '(none)'}`);
        for (const { localization, keywords } of localizations) {
          const kw = keywords === null ? 'kw=?' : `kw=${keywords.length}`;
          console.log(`      ${localization.attributes.locale.padEnd(9)} promo=${String(localization.attributes.promotionalText?.length ?? 0).padStart(3)}  ${kw}`);
        }
      }
    }
  }
  const localCpp = readStoreFile('cpp.json');
  const liveCppNames = new Set(cpp.map((row) => row.page.attributes?.name));
  const missingCpp = (localCpp.pages ?? []).filter((page) => !liveCppNames.has(page.name));
  console.log(`  ${cpp.length} live of ${localCpp.pages?.length ?? 0} planned`);
  for (const page of missingCpp) console.log(`    missing: ${page.name}`);

  heading('In-app events');
  const events = await listEvents(client, appId);
  if (events.length === 0) console.log('  none live');
  for (const event of events) {
    const schedules = event.attributes?.territorySchedules ?? [];
    const window = schedules[0]
      ? `${(schedules[0].eventStart ?? '').slice(0, 10)} to ${(schedules[0].eventEnd ?? '').slice(0, 10)}`
      : '(no schedule)';
    console.log(`  ${String(event.attributes?.referenceName).padEnd(28)} ${String(event.attributes?.eventState).padEnd(22)} ${window}`);
  }
  const localEvents = readStoreFile('events.json');
  console.log(`  ${events.length} live of ${(localEvents.events ?? []).length} planned`);
  for (const event of localEvents.events ?? []) {
    const window = eventWindow(event);
    const live = events.find((row) => row.attributes?.referenceName === event.referenceName);
    console.log(`    ${event.referenceName.padEnd(28)} local=${window.padEnd(9)} remote=${live ? live.attributes.eventState : 'absent'}`);
  }

  heading('PPO experiments');
  const experiments = await listExperiments(client, appId);
  if (experiments.length === 0) console.log('  none live');
  for (const { experiment, treatments } of experiments) {
    console.log(`  ${String(experiment.attributes?.state).padEnd(22)} ${experiment.attributes?.name}  traffic=${experiment.attributes?.trafficProportion}%`);
    for (const { treatment, localizations } of treatments) {
      console.log(`    ${String(treatment.attributes?.name).padEnd(34)} locales=${localizations.length}  icon=${treatment.attributes?.appIconName ?? '(page)'}`);
    }
  }
  const localPpo = readStoreFile('ppo.json');
  console.log(`  ${experiments.length} live of ${(localPpo.experiments ?? []).length} planned`);

  heading('Asset library');
  const libraryId = await libraryIdFor(client, appId);
  const { assets } = await libraryImages(client, libraryId);
  const hashNamed = assets.filter((asset) => HASH_RE.test(asset.attributes?.referenceName ?? ''));
  console.log(`  ${assets.length} image(s): ${hashNamed.length} hash-named from media.mjs, ${assets.length - hashNamed.length} from the web UI`);
  const manifest = loadManifest(flagValue('manifest') ?? DEFAULT_MANIFEST);
  console.log(manifest
    ? `  manifest: ${manifest.entries.length} entries at ${manifest.source}`
    : '  manifest: none at store/creative/manifest.json (creative pipeline has not written it yet)');

  heading('Local plan');
  const validation = validateListings();
  console.log(`  listings ${validation.coverage.present}/${validation.coverage.wanted}, ${validation.errors.length} error(s), ${validation.warnings.length} warning(s)`);
  console.log('  cpp.json / ppo.json / events.json all present and validated by their own commands');

  console.log('\nRead-only. Nothing was written.');
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

const COMMANDS = {
  status: cmdStatus,
  cpp: cmdCpp,
  ppo: cmdPpo,
  events: cmdEvents,
  submit: cmdSubmit,
};

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (!command || !COMMANDS[command]) {
    console.error(`usage: node scripts/asc/grow.mjs <${Object.keys(COMMANDS).join('|')}> [--apply] [--start --experiment=<slug>]`);
    process.exit(command ? 1 : 0);
  }
  COMMANDS[command]().catch((error) => {
    console.error(`FAILED: ${error.message}`);
    if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1500));
    process.exit(1);
  });
}
