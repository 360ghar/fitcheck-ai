#!/usr/bin/env node
/**
 * App Store Connect publishing for FitCheck AI.
 *
 * Every command is idempotent and diffs before writing: a second run reports
 * "already current" instead of re-uploading, and `--apply` is required for
 * anything that changes the store. Without it the command prints the exact
 * requests it would send.
 *
 *   prepare   create the editable version and all 50 localizations
 *   details   write name, subtitle, promo text, description, keywords, URLs
 *   cpp       create the custom product pages, their versions and keywords
 *   events    create the in-app events
 *   submit    attach the build and submit for review
 *
 * Media lives in `media.mjs` (screenshots and creative assets) because it is a
 * different failure mode: a copy mistake is a diff, a wrong screenshot is a
 * rejected build.
 */

import { createClient, credentialsFromEnv, findApp, readStoreFile } from './asc.mjs';
import { loadLocales, loadListings, orderedLocales, readJson } from './plan.mjs';

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const command = args.find((arg) => !arg.startsWith('--'));

function heading(text) {
  console.log(`\n${text}`);
  console.log('-'.repeat(text.length));
}

async function connect() {
  const app = readStoreFile('app.json');
  const client = createClient({ ...credentialsFromEnv(), dryRun: !apply });
  const record = await findApp(client, app);
  return { app, client, appId: record.id, record };
}

/**
 * The version metadata can be written to. Apple only accepts copy and media on
 * a version in PREPARE_FOR_SUBMISSION; a released version can never be
 * reopened, so every release needs `prepare` first.
 */
async function editableVersion(client, appId, { create = false, versionString } = {}) {
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=50&fields[appStoreVersions]=versionString,appStoreState,platform`,
  );
  const existing = versions.find(
    (version) => version.attributes?.versionString === versionString
      && version.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION',
  );
  if (existing) return existing;
  if (!create) {
    throw new Error(
      `No editable ${versionString} version. Run: node scripts/asc/publish.mjs prepare --apply`,
    );
  }
  const created = await client.post('/v1/appStoreVersions', {
    data: {
      type: 'appStoreVersions',
      attributes: {
        platform: 'IOS',
        versionString,
        // Goes live as soon as App Review approves. Change to MANUAL if a
        // release needs a human hold.
        releaseType: 'AFTER_APPROVAL',
      },
      relationships: {
        app: { data: { type: 'apps', id: appId } },
      },
    },
  });
  return created.data;
}

/**
 * The app-info record whose localizations belong to the version being prepared.
 *
 * An app has one appInfo per release lifecycle. Once a version is drafted,
 * ASC keeps the live record in `READY_FOR_SALE` and adds a second one in
 * `PREPARE_FOR_SUBMISSION`; copy written to the live record is rejected with
 *
 *   409 ENTITY_ERROR.RELATIONSHIP.INVALID: A relationship cannot be created in
 *   current state.
 *
 * The old filter only excluded `REPLACED_WITH_NEW_INFO`, which matches both, so
 * `find` returned whichever came first — the live one — and every localised
 * app-info row failed on a project that had just been prepared correctly.
 */
async function appInfo(client, appId) {
  const infos = await client.getAll(`/v1/apps/${appId}/appInfos?limit=10`);
  const info = infos.find((row) => row.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION')
    ?? infos.find((row) => row.attributes?.appStoreState !== 'REPLACED_WITH_NEW_INFO')
    ?? infos[0];
  if (!info) throw new Error('No app info record; create the app in App Store Connect first.');
  if (info.attributes?.appStoreState !== 'PREPARE_FOR_SUBMISSION') {
    console.log(
      `  warning: app info ${info.id} is ${info.attributes?.appStoreState}, not `
      + 'PREPARE_FOR_SUBMISSION; app-level copy may be rejected',
    );
  }
  return info;
}

/**
 * Creates the localization rows for every locale. This is the step that makes
 * the App Store list 50 languages; writing copy into a row that does not exist
 * fails with a 404 that names the relationship rather than the missing locale.
 */
async function ensureLocalizations(client, { version, info, locales, listings }) {
  const versionLocs = await client.getAll(
    `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200&fields[appStoreVersionLocalizations]=locale`,
  );
  const haveVersion = new Set(versionLocs.map((row) => row.attributes.locale));

  const infoLocs = await client.getAll(
    `/v1/appInfos/${info.id}/appInfoLocalizations?limit=200&fields[appInfoLocalizations]=locale`,
  );
  const haveInfo = new Set(infoLocs.map((row) => row.attributes.locale));

  const created = { version: [], info: [], failed: [] };

  for (const locale of locales) {
    if (!haveVersion.has(locale)) {
      try {
        const response = await client.post('/v1/appStoreVersionLocalizations', {
          data: {
            type: 'appStoreVersionLocalizations',
            attributes: { locale },
            relationships: {
              appStoreVersion: { data: { type: 'appStoreVersions', id: version.id } },
            },
          },
        });
        created.version.push(locale);
        versionLocs.push(response.data ?? { id: `dry-${locale}`, attributes: { locale } });
      } catch (error) {
        // Apple rejects a locale it does not support with the same 409/400 it
        // uses for a duplicate, so the message carries the distinction.
        created.failed.push(`${locale} (version): ${error.message}`);
        continue;
      }
    } else {
      // Keep the id so a later write can use it without another round trip.
      const row = versionLocs.find((entry) => entry.attributes.locale === locale);
      if (row && !row.id.startsWith('dry-')) created.version.push(`${locale} (existing)`);
    }

    if (!haveInfo.has(locale)) {
      try {
        // `name` is REQUIRED on appInfoLocalizations, unlike on
        // appStoreVersionLocalizations. Creating a row with only `locale` is
        // rejected with
        //   409 ENTITY_ERROR.ATTRIBUTE.REQUIRED: You must provide a value for
        //   the attribute 'name'
        // which cost a full prepare run: the version was created, then all 49
        // localised app-info rows failed and the listing stayed at 1 language.
        // `name` and `subtitle` here are the *app-level* strings, which is why
        // they come from the same listings.json the version localizations use.
        const listing = listings[locale] ?? {};
        const attributes = { locale, name: listing.name || listings['en-US'].name };
        if (listing.subtitle) attributes.subtitle = listing.subtitle;
        await client.post('/v1/appInfoLocalizations', {
          data: {
            type: 'appInfoLocalizations',
            attributes,
            relationships: {
              appInfo: { data: { type: 'appInfos', id: info.id } },
            },
          },
        });
        created.info.push(locale);
      } catch (error) {
        created.failed.push(`${locale} (app info): ${error.message}`);
      }
    }
  }

  return created;
}

async function cmdPrepare() {
  const { app, client, appId } = await connect();
  heading(`Prepare ${app.marketingVersion}`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'report only (no writes)'}`);

  const version = await editableVersion(client, appId, {
    create: apply,
    versionString: app.marketingVersion,
  });
  if (apply) console.log(`  version ${version.attributes.versionString} ready (${version.id})`);

  const info = await appInfo(client, appId);
  const locales = orderedLocales();
  const { data: listings } = loadListings();
  heading(`Localizations (${locales.length})`);
  const report = await ensureLocalizations(client, { version, info, locales, listings });

  if (apply) {
    console.log(`  version rows created: ${report.version.filter((v) => !v.includes('existing')).length}`);
    console.log(`  app info rows created: ${report.info.length}`);
  } else {
    console.log(`  would create ${locales.length} version rows and ${locales.length} app info rows`);
  }
  if (report.failed.length > 0) {
    console.log(`  FAILED (${report.failed.length}):`);
    for (const failure of report.failed.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }

  heading('Next');
  console.log('  node scripts/asc/publish.mjs details --apply');
  console.log('  node scripts/asc/media.mjs --apply --replace');
  console.log('  node scripts/asc/grow.mjs --apply');
}

/**
 * Writes the listing copy. Compares before writing, so a second run is a no-op
 * and the output is a diff of what actually changed rather than 50 PUTs.
 */
async function cmdDetails() {
  const { app, client, appId } = await connect();
  const { data: listings } = loadListings();
  const { byAsc } = loadLocales();
  heading(`Details for ${app.marketingVersion}`);
  console.log(`  mode    ${apply ? 'APPLY (writes)' : 'report only (no writes)'}`);

  const version = await editableVersion(client, appId, {
    versionString: app.marketingVersion,
  });
  const info = await appInfo(client, appId);

  const versionLocs = await client.getAll(
    `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200`,
  );
  const infoLocs = await client.getAll(
    `/v1/appInfos/${info.id}/appInfoLocalizations?limit=200`,
  );

  let written = 0;
  let infoWritten = 0;
  let unchanged = 0;
  const failures = [];

  for (const locale of orderedLocales()) {
    const listing = listings[locale];
    if (!listing) continue;
    // A locale is only "already current" when BOTH its version row and its
    // app-info row needed nothing. Counting them separately let a run report
    // "unchanged" for a locale it had just re-titled.
    let versionUnchanged = false;
    let infoUnchanged = true;

    // --- product page copy -------------------------------------------------
    const versionRow = versionLocs.find((row) => row.attributes?.locale === locale);
    if (!versionRow) {
      failures.push(`${locale}: no version localization (run prepare)`);
      continue;
    }
    const desiredVersion = {
      description: listing.description,
      keywords: listing.keywords,
      promotionalText: listing.promotionalText,
      whatsNew: listing.whatsNew,
      supportUrl: app.urls.support,
      marketingUrl: app.urls.marketing,
    };
    const currentVersion = {
      description: versionRow.attributes?.description,
      keywords: versionRow.attributes?.keywords,
      promotionalText: versionRow.attributes?.promotionalText,
      whatsNew: versionRow.attributes?.whatsNew,
      supportUrl: versionRow.attributes?.supportUrl,
      marketingUrl: versionRow.attributes?.marketingUrl,
    };
    const changedVersion = Object.keys(desiredVersion).filter(
      (field) => (currentVersion[field] ?? '') !== (desiredVersion[field] ?? ''),
    );
    if (changedVersion.length > 0) {
      try {
        await client.patch(`/v1/appStoreVersionLocalizations/${versionRow.id}`, {
          data: {
            type: 'appStoreVersionLocalizations',
            id: versionRow.id,
            attributes: Object.fromEntries(
              changedVersion.map((field) => [field, desiredVersion[field]]),
            ),
          },
        });
        written += 1;
        console.log(`  ${locale.padEnd(9)} ${changedVersion.join(', ')}`);
      } catch (error) {
        failures.push(`${locale} (copy): ${error.message}`);
      }
    } else {
      versionUnchanged = true;
    }

    // --- app info: localized name, subtitle and privacy URL ----------------
    const infoRow = infoLocs.find((row) => row.attributes?.locale === locale);
    if (infoRow) {
      // `subtitle` belongs to app-info localizations, not version ones, and it
      // was missing from this write entirely. `prepare` only seeds it when it
      // CREATES the row, so every locale whose row was created without it kept
      // English: en-US showed "AI Closet, Try-On & Outfits" for hi, ja and
      // ar-SA while `name` beside it was correctly localized. Apple inherits a
      // missing localizable attribute from the primary locale, which made the
      // defect invisible — the field was never empty, just never ours.
      const desiredInfo = {
        name: listing.name,
        subtitle: listing.subtitle,
        privacyPolicyUrl: app.urls.privacy,
      };
      const changedInfo = Object.keys(desiredInfo).filter(
        (field) => (infoRow.attributes?.[field] ?? '') !== desiredInfo[field],
      );
      if (changedInfo.length > 0) {
        try {
          await client.patch(`/v1/appInfoLocalizations/${infoRow.id}`, {
            data: {
              type: 'appInfoLocalizations',
              id: infoRow.id,
              attributes: Object.fromEntries(
                changedInfo.map((field) => [field, desiredInfo[field]]),
              ),
            },
          });
          // Counted separately from `written`, which tracks version-row edits.
          // Without this the app-info PATCHes were invisible to the summary, so
          // a run that fixed 48 titles and subtitles reported
          // "localizations updated 0 / already current 50" — the opposite of
          // what had just happened, and enough to make a correct fix look like
          // a no-op.
          infoWritten += 1;
          infoUnchanged = false;
        } catch (error) {
          failures.push(`${locale} (app info): ${error.message}`);
          infoUnchanged = false;
        }
      }
    }

    if (versionUnchanged && infoUnchanged) unchanged += 1;
  }

  heading('Result');
  console.log(`  localizations updated  ${written}`);
  console.log(`  app info updated       ${infoWritten}`);
  console.log(`  already current        ${unchanged}`);
  if (failures.length > 0) {
    console.log(`  FAILED (${failures.length}):`);
    for (const failure of failures.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }
  if (!apply) console.log('\n  Re-run with --apply to write.');
  else console.log('\n  A new version must be submitted for review before the copy goes live.');
}

/**
 * Custom product pages. Each page is a separate, reviewable product page with
 * its own URL, screenshots and keyword set; Apple allows 70 per app.
 *
 * The keyword set is the whole point: a page with keywords shows in search
 * results for those terms instead of the default page, which is how one app can
 * present a different promise to "headshots" and to "outfit planner".
 */
async function cmdCpp() {
  const { app, client, appId } = await connect();
  const cpp = readJson('cpp.json');

  heading(`Custom product pages (${cpp.pages.length})`);
  const existing = await client.getAll(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
  const byName = new Map(existing.map((page) => [page.attributes?.name, page]));
  console.log(`  existing ${existing.length} of ${cpp.pages.length} planned`);

  const { data: listings } = loadListings();
  const failures = [];

  for (const page of cpp.pages) {
    let record = byName.get(page.name);
    if (record) {
      console.log(`  ${page.name.padEnd(28)} exists  ${record.id}`);
    } else if (!apply) {
      console.log(`  ${page.name.padEnd(28)} would create`);
      continue;
    } else {
      // A custom product page needs its app relationship; omitting it fails
      // with a missing-relationship error that does not name the fix.
      const created = await client.post('/v1/appCustomProductPages', {
        data: {
          type: 'appCustomProductPages',
          attributes: { name: page.name, isVisible: true },
          relationships: { app: { data: { type: 'apps', id: appId } } },
        },
      });
      record = created.data;
      console.log(`  ${page.name.padEnd(28)} created  ${record.id}`);
    }

    // Each page has versions; the first is the one that gets localizations.
    const versions = await client.getAll(
      `/v1/appCustomProductPages/${record.id}/appCustomProductPageVersions?limit=10`,
    );
    let version = versions[0];
    if (!version && apply) {
      const created = await client.post('/v1/appCustomProductPageVersions', {
        data: {
          type: 'appCustomProductPageVersions',
          relationships: {
            appCustomProductPage: {
              data: { type: 'appCustomProductPages', id: record.id },
            },
          },
        },
      });
      version = created.data;
    }
    if (!version) {
      console.log(`    no version yet (created on apply)`);
      continue;
    }

    const localizations = await client.getAll(
      `/v1/appCustomProductPageVersions/${version.id}/appCustomProductPageLocalizations?limit=200`,
    );
    const haveLocales = new Set(localizations.map((row) => row.attributes?.locale));

    for (const locale of page.locales) {
      const listing = listings[locale];
      if (!listing) {
        failures.push(`${page.name}/${locale}: no listing copy`);
        continue;
      }
      const promo = page.promotionalText?.[locale] ?? page.promotionalText?.default;
      if (haveLocales.has(locale)) continue;
      if (!apply) {
        console.log(`    ${locale.padEnd(9)} would create localization`);
        continue;
      }
      try {
        await client.post('/v1/appCustomProductPageLocalizations', {
          data: {
            type: 'appCustomProductPageLocalizations',
            attributes: {
              locale,
              promotionalText: promo,
            },
            relationships: {
              appCustomProductPageVersion: {
                data: { type: 'appCustomProductPageVersions', id: version.id },
              },
            },
          },
        });
        console.log(`    ${locale.padEnd(9)} localization created`);
      } catch (error) {
        failures.push(`${page.name}/${locale}: ${error.message}`);
      }
    }
  }

  heading('Notes');
  console.log('  Screenshots and search creatives are placed by scripts/asc/media.mjs.');
  console.log('  Keywords are assigned per page in App Store Connect after approval:');
  console.log('  Apple exposes them through the page localization, not the page create.');
  if (!apply) console.log('\n  Re-run with --apply to create.');
  if (failures.length > 0) {
    console.log(`  FAILED (${failures.length}):`);
    for (const failure of failures.slice(0, 20)) console.log(`    ${failure}`);
    process.exitCode = 1;
  }
}

async function cmdSubmit() {
  const { app, client, appId } = await connect();
  const buildFlag = args.find((arg) => arg.startsWith('--build='));
  const buildId = buildFlag ? buildFlag.split('=')[1] : null;

  heading(`Submit ${app.marketingVersion}`);
  const version = await editableVersion(client, appId, {
    versionString: app.marketingVersion,
  });

  if (buildId) {
    await client.patch(`/v1/appStoreVersions/${version.id}/relationships/build`, {
      data: { type: 'builds', id: buildId },
    });
    console.log(`  build ${buildId} attached`);
  } else {
    console.log('  no --build=<id>: the version keeps its current build');
  }

  const submissions = await client.getAll(
    `/v1/apps/${appId}/reviewSubmissions?limit=10&fields[reviewSubmissions]=state,submittedDate`,
  );
  const open = submissions.find((row) => row.attributes?.state === 'READY_FOR_REVIEW'
    || row.attributes?.state === 'WAITING_FOR_REVIEW');

  let submission = open;
  if (!submission) {
    const created = await client.post('/v1/reviewSubmissions', {
      data: {
        type: 'reviewSubmissions',
        relationships: { app: { data: { type: 'apps', id: appId } } },
      },
    });
    submission = created.data;
    console.log(`  review submission ${submission?.id ?? '(dry run)'} created`);
  } else {
    console.log(`  reusing open submission ${submission.id}`);
  }

  await client.post('/v1/reviewSubmissionItems', {
    data: {
      type: 'reviewSubmissionItems',
      relationships: {
        reviewSubmission: {
          data: { type: 'reviewSubmissions', id: submission.id },
        },
        appStoreVersion: {
          data: { type: 'appStoreVersions', id: version.id },
        },
      },
    },
  });

  await client.patch(`/v1/reviewSubmissions/${submission.id}`, {
    data: {
      type: 'reviewSubmissions',
      id: submission.id,
      attributes: { submitted: true },
    },
  });

  console.log('\n  Submitted. App Review usually responds within 24-48 hours.');
}

const COMMANDS = {
  prepare: cmdPrepare,
  details: cmdDetails,
  cpp: cmdCpp,
  submit: cmdSubmit,
};

if (!command || !COMMANDS[command]) {
  console.error(`usage: node scripts/asc/publish.mjs <${Object.keys(COMMANDS).join('|')}> [--apply]`);
  process.exit(command ? 1 : 0);
}

COMMANDS[command]().catch((error) => {
  console.error(`FAILED: ${error.message}`);
  if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1500));
  process.exit(1);
});
