#!/usr/bin/env node
/**
 * Read-only report on what App Store Connect currently holds for FitCheck AI.
 *
 * Nothing here writes. Run it before any other command: it names the editable
 * version, counts the localizations, and shows which growth surfaces exist, so
 * a write command can be trusted not to guess.
 *
 * Usage:
 *   node scripts/asc/verify.mjs
 *   node scripts/asc/verify.mjs --json     # machine-readable, for CI
 */

import { createClient, credentialsFromEnv, findApp, readStoreFile } from './asc.mjs';
import { loadLocales, validateListings } from './plan.mjs';

const args = new Set(process.argv.slice(2));
const asJson = args.has('--json');

const lines = [];
function say(text = '') {
  lines.push(text);
  if (!asJson) console.log(text);
}
function heading(text) {
  say();
  say(text);
  say('-'.repeat(text.length));
}

async function main() {
  const app = readStoreFile('app.json');
  const creds = credentialsFromEnv();
  const client = createClient({ ...creds, log: () => {} });
  const record = await findApp(client, app);
  const appId = record.id;

  heading('Credentials');
  say(`  key id     ${creds.keyId.slice(0, 4)}… (${creds.source})`);
  say(`  issuer     ${creds.issuerId.slice(0, 8)}…`);
  say('  key file   present, parses, signs an accepted token');

  heading('App record');
  say(`  id             ${appId}`);
  say(`  name           ${record.attributes?.name}`);
  say(`  bundleId       ${record.attributes?.bundleId}`);
  say(`  primaryLocale  ${record.attributes?.primaryLocale}`);

  heading('Versions');
  const versions = await client.getAll(
    `/v1/apps/${appId}/appStoreVersions?limit=20`
    + '&fields[appStoreVersions]=versionString,appStoreState,platform,createdDate',
  );
  for (const version of versions) {
    const a = version.attributes ?? {};
    say(
      `  ${String(a.versionString).padEnd(8)} ${String(a.appStoreState).padEnd(26)}`
      + ` ${a.platform}  ${a.createdDate?.slice(0, 10) ?? ''}  ${version.id}`,
    );
  }
  const editable = versions.filter((v) => v.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION');
  say(
    editable.length === 0
      ? '  no editable version: copy and media changes need one (run prepare)'
      : `  editable: ${editable.map((v) => v.attributes.versionString).join(', ')}`,
  );

  // Report localizations for *both* the shipped version and the editable one.
  //
  // This used to report only the live version, on the theory that verify should
  // describe what customers see. That is the wrong question in the one moment
  // this tool matters: before submitting, the question is "is my draft
  // complete?", and answering it with the shipped version printed
  // "1 present of 50 … missing locales (49)" while the draft was actually
  // complete. A report that reads like a blocker when there is none is worse
  // than no report.
  const describe = async (version, label) => {
    heading(`Localizations on ${version.attributes.versionString} (${label})`);
    const localizations = await client.getAll(
      `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200`,
    );
    const have = new Map(localizations.map((l) => [l.attributes.locale, l]));
    say(`  ${localizations.length} present of ${loadLocales().locales.length} the app ships`);
    for (const locale of loadLocales().locales) {
      const row = have.get(locale.asc);
      if (!row) continue;
      const a = row.attributes ?? {};
      say(
        `    ${locale.asc.padEnd(9)}`
        + ` desc=${String(a.description?.length ?? 0).padStart(4)}`
        + ` kw=${String(a.keywords?.length ?? 0).padStart(3)}`
        + ` promo=${String(a.promotionalText?.length ?? 0).padStart(3)}`,
      );
    }
    const missing = loadLocales().locales.filter((locale) => !have.has(locale.asc));
    if (missing.length > 0) {
      const note = label === 'live'
        ? 'expected until the localized version ships'
        : 'BLOCKER — the draft is not complete';
      say(`  missing locales (${missing.length}): ${missing.map((l) => l.asc).join(', ')}`);
      say(`    ${note}`);
    }
  };

  if (editable.length > 0) await describe(editable[0], 'draft, next submission');

  const live = versions.find((v) => v.attributes?.appStoreState === 'READY_FOR_SALE') ?? versions[0];
  if (live && !editable.some((v) => v.id === live.id)) {
    await describe(live, 'live');
  }

  heading('Subscriptions');
  const groups = await client.getAll(`/v1/apps/${appId}/subscriptionGroups?limit=20`);
  for (const group of groups) {
    say(`  group ${group.id}  ${group.attributes?.referenceName}`);
    const subs = await client.getAll(
      `/v1/subscriptionGroups/${group.id}/subscriptions?limit=50`,
      { query: { 'fields[subscriptions]': 'name,productId,state,subscriptionPeriod' } },
    ).catch(() => []);
    for (const sub of subs) {
      say(`    ${String(sub.attributes?.productId).padEnd(46)} ${sub.attributes?.state ?? ''}`);
    }
  }

  heading('Growth surfaces');
  const cpp = await client.getAll(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
  say(`  custom product pages   ${cpp.length}`);
  for (const page of cpp) {
    say(`    ${page.attributes?.name}  visible=${page.attributes?.isVisible}  ${page.id}`);
  }
  const events = await client.getAll(`/v1/apps/${appId}/appEvents?limit=200`);
  say(`  in-app events          ${events.length}`);
  const experiments = await client.getAll(
    `/v1/apps/${appId}/appStoreVersionExperimentsV2?limit=200`,
  ).catch(() => []);
  say(`  PPO experiments        ${experiments.length}`);
  for (const experiment of experiments) {
    say(`    ${experiment.attributes?.state}  ${experiment.attributes?.name}`);
  }

  heading('Local plan');
  const validation = validateListings();
  say(
    `  listings    ${validation.coverage.present}/${validation.coverage.wanted} locales`
    + `, ${validation.errors.length} error(s), ${validation.warnings.length} warning(s)`,
  );
  for (const error of validation.errors.slice(0, 12)) say(`    ERROR ${error}`);
  if (validation.errors.length > 12) say(`    … ${validation.errors.length - 12} more`);

  if (asJson) {
    console.log(JSON.stringify({
      appId,
      versions: versions.map((v) => v.attributes),
      customProductPages: cpp.length,
      events: events.length,
      experiments: experiments.length,
      listings: validation.coverage,
      listingErrors: validation.errors,
    }, null, 2));
  } else {
    say();
    say('Read-only report complete. Nothing was written.');
  }
}

main().catch((error) => {
  console.error(`FAILED: ${error.message}`);
  process.exit(1);
});
