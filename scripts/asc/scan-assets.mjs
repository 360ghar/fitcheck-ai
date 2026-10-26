#!/usr/bin/env node
/**
 * Finds screenshots that will block a submission by never finishing processing.
 *
 *   node scripts/asc/scan-assets.mjs [--locale en-US]
 *
 * App Store Connect reports a stranded asset as
 * `STATE_ERROR.ASSET_UPLOAD_IN_PROGRESS.APP_SCREENSHOT` on the *version*, which
 * names neither the locale nor the screenshot, and every `appScreenshot` in the
 * affected set can claim `COMPLETE` while an asset-library image behind it sits
 * in `AWAITING_UPLOAD` at 0x0. This walks every localization of the editable
 * version and reports the ones that are not `COMPLETE`, because that is the only
 * place the real state is visible.
 *
 * Read-only: it prints and exits non-zero, it never repairs. See
 * docs/store/release-runbook.md for the delete-placement, delete-image,
 * re-upload order, which is the only way out once an asset is stranded.
 */
import {
  createClient,
  credentialsFromEnv,
  findApp,
  redact,
} from './asc.mjs';

const args = process.argv.slice(2);
const only = args.includes('--locale') ? args[args.indexOf('--locale') + 1] : undefined;

async function main() {
  const client = createClient({ ...credentialsFromEnv() });
  const app = await findApp(client, { appId: '6794689012', bundleId: 'com.fitcheckaiapp.fitcheckai' });

  const versions = await client.getAll(`/v1/apps/${app.id}/appStoreVersions?limit=20`);
  const editable = versions.find((v) => v.attributes.appStoreState === 'PREPARE_FOR_SUBMISSION');
  const version = editable ?? versions.find((v) => v.attributes.appStoreState === 'READY_FOR_REVIEW') ?? versions[0];
  if (!version) {
    console.error('no app store version to inspect');
    return 1;
  }
  console.log(`version ${version.attributes.versionString} (${version.attributes.appStoreState})`);

  const localizations = await client.getAll(
    `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=200`,
  );
  const wanted = only ? localizations.filter((l) => l.attributes.locale === only) : localizations;
  if (wanted.length === 0) {
    console.error(`no localization matches ${only}`);
    return 1;
  }

  let checked = 0;
  const stranded = [];
  for (const localization of wanted) {
    const sets = await client.getAll(
      `/v1/appStoreVersionLocalizations/${localization.id}/appScreenshotSets?limit=50`,
    );
    for (const set of sets) {
      const shots = await client.getAll(
        `/v1/appScreenshotSets/${set.id}/appScreenshots?limit=20&fields[appScreenshots]=assetDeliveryState,imageAsset`,
      );
      if (shots.length === 0) {
        console.log(`  EMPTY   ${localization.attributes.locale} ${set.attributes.screenshotDisplayType}`);
      }
      for (const shot of shots) {
        checked += 1;
        const state = shot.attributes?.assetDeliveryState ?? {};
        if (state.state === 'COMPLETE') continue;
        const asset = shot.attributes?.imageAsset ?? {};
        stranded.push({
          locale: localization.attributes.locale,
          displayType: set.attributes.screenshotDisplayType,
          state: state.state,
          size: `${asset.width ?? 0}x${asset.height ?? 0}`,
          errors: (state.errors ?? []).map((e) => e.code).join(','),
        });
      }
    }
  }

  console.log(`\n${checked} screenshot(s) across ${wanted.length} localization(s)`);
  if (stranded.length === 0) {
    console.log('every screenshot is COMPLETE; nothing here blocks a submission');
    return 0;
  }
  console.log(`${stranded.length} not COMPLETE:\n`);
  for (const row of stranded) {
    console.log(`  ${row.locale.padEnd(6)} ${row.displayType.padEnd(24)} ${String(row.state).padEnd(18)} ${row.size} ${row.errors}`);
  }
  console.log('\nEach row blocks the submission with ASSET_UPLOAD_IN_PROGRESS.APP_SCREENSHOT.');
  console.log('Recovery: delete the placement, delete the image, then media.mjs upload --apply.');
  return 1;
}

main()
  .then((code) => process.exit(code))
  .catch((error) => {
    console.error(`FAILED: ${redact(String(error.message))}`);
    if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1200));
    process.exit(1);
  });
