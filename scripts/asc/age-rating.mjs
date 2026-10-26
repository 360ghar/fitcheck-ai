#!/usr/bin/env node
/**
 * Corrects the App Store age rating declaration.
 *
 * The live listing shows 17+ because `unrestrictedWebAccess` is true. FitCheck
 * AI has no browser: it ships no WebView, and every outbound link opens Safari
 * (or the Play equivalent) as a separate app, which Apple does not count as
 * in-app web access. That one flag is the entire reason for the inflated
 * rating, and an inflated rating costs installs on a lifestyle app.
 *
 * Why this does not simply flip the boolean and stop: a rating that is too LOW
 * is an App Review rejection plus a re-review cycle (about a week), while a
 * rating that is too HIGH only costs installs. So this script prints every
 * field, proposes a full honest declaration for a wardrobe app with
 * user-uploaded photos and a share feature, and refuses to run when the Dart
 * source contradicts the "no web access" claim.
 *
 * Usage:
 *   node scripts/asc/age-rating.mjs            # report only, no writes
 *   node scripts/asc/age-rating.mjs --apply    # PATCH the declaration
 *
 * Endpoints (discovered against the live account; `appInfos` has no
 * GET_COLLECTION, so it is reached through the app resource):
 *   GET   /v1/apps/{appId}?include=appInfos
 *   GET   /v1/appInfos/{appInfoId}/ageRatingDeclaration
 *   PATCH /v1/ageRatingDeclarations/{declarationId}
 */

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

import {
  ROOT,
  createClient,
  credentialsFromEnv,
  findApp,
  readStoreFile,
} from './asc.mjs';

const apply = process.argv.includes('--apply');
const FLUTTER = join(ROOT, 'flutter');

function heading(text) {
  console.log(`\n${text}`);
  console.log('-'.repeat(text.length));
}

// ---------------------------------------------------------------------------
// The proposed declaration
// ---------------------------------------------------------------------------

/**
 * Full, honest declaration for this app. Every value carries its reason, and
 * the reason is checked against the source tree below where it can be.
 */
const PROPOSED = {
  // --- Corrected: the reason this script exists. ---
  unrestrictedWebAccess: {
    value: false,
    reason:
      'No WebView, no in-app browser. url_launcher opens Safari / Play as a '
      + 'separate app for legal pages, subscription settings and store '
      + 'checkout, which is external, not in-app web access.',
    assertion: 'noInAppBrowser',
  },

  // --- User content: stay true. The app stores photos the user chooses. ---
  userGeneratedContent: {
    value: true,
    reason:
      'Users upload camera-roll photos of their own clothes and bodies, and a '
      + 'shared outfit link renders another user\'s content on /shared/:id. '
      + 'Guideline 1.2 obligations (report/block, moderation) already apply.',
  },

  // --- Social: false, and this is a judgment call, documented so a reviewer
  //     reading the source can re-check it rather than trust it. ---
  socialMedia: {
    value: false,
    reason:
      'No feed, no follows, no likes, no comments, no user-to-user contact. '
      + 'Sharing is the OS share sheet (share_plus) handing a link or image to '
      + 'another app, and one read-only page at /shared/:id. That is a share '
      + 'feature, not a social network.',
    assertion: 'noSocialGraph',
  },
  socialMediaAgeRestricted: {
    value: false,
    reason: 'Follows from socialMedia: false. Nothing here is age-restricted.',
  },
  messagingAndChat: {
    value: false,
    reason:
      'No chat or direct messaging. The feedback screen posts a message to '
      + 'support, which is developer-bound and not user-to-user.',
    assertion: 'noUserChat',
  },

  // --- Advertising / commerce ---
  advertising: {
    value: false,
    reason: 'No ad SDK in pubspec.yaml, no ad view in the source tree.',
    assertion: 'noAds',
  },
  gambling: {
    value: false,
    reason: 'No wagering anywhere. Subscriptions are the only monetisation.',
  },
  gamblingSimulated: {
    value: 'NONE',
    reason: 'No simulated gambling. Streaks and badges are not chance-based.',
  },
  contests: {
    value: 'NONE',
    reason:
      'No contests or sweepstakes. Referral credit and gift vouchers are paid '
      + 'features, not a prize draw.',
  },
  lootBox: {
    value: false,
    reason: 'No randomised paid rewards.',
  },

  // --- Content advisories: all genuinely absent ---
  alcoholTobaccoOrDrugUseOrReferences: {
    value: 'NONE',
    reason: 'Outfit and wardrobe content only.',
  },
  gunsOrOtherWeapons: { value: 'NONE', reason: 'No weapons content.' },
  horrorOrFearThemes: { value: 'NONE', reason: 'No horror content.' },
  matureOrSuggestiveThemes: {
    value: 'NONE',
    reason:
      'Outfit suggestions and try-on previews of the user\'s own clothed '
      + 'photos. No suggestive editorial content.',
  },
  profanityOrCrudeHumor: { value: 'NONE', reason: 'No such content.' },
  sexualContentOrNudity: {
    value: 'NONE',
    reason:
      'No nudity. Try-on renders the user\'s own photo in clothing; the '
      + 'generation prompt is garment-bound, not body-revealing.',
  },
  sexualContentGraphicAndNudity: {
    value: 'NONE',
    reason: 'Follows from sexualContentOrNudity: NONE.',
  },
  violenceCartoonOrFantasy: { value: 'NONE', reason: 'No violence content.' },
  violenceRealistic: { value: 'NONE', reason: 'No violence content.' },
  violenceRealisticProlongedGraphicOrSadistic: {
    value: 'NONE',
    reason: 'No violence content.',
  },

  // --- Health ---
  healthOrWellnessTopics: {
    value: false,
    reason:
      'Judgment call, stated so it can be overruled: body profiles store '
      + 'height, weight, body shape and skin tone, used only to fit garments '
      + 'on a try-on render. There is no health, fitness, nutrition, medical or '
      + 'wellbeing content, no HealthKit, and no health guidance.',
  },
  medicalOrTreatmentInformation: {
    value: 'NONE',
    reason: 'No medical content of any kind.',
  },

  // --- Platform / regulatory overrides: leave to Apple's computation ---
  parentalControls: {
    value: false,
    reason: 'The app is not a parental-controls tool.',
  },
  ageAssurance: {
    value: false,
    reason:
      'No age verification gate. The app is not age-restricted once the web '
      + 'access flag is corrected.',
  },
  kidsAgeBand: {
    value: null,
    reason: 'Not a Kids Category app.',
  },
  ageRatingOverride: {
    value: 'NONE',
    reason: 'No manual override. Let Apple compute the rating from the answers.',
  },
  ageRatingOverrideV2: {
    // Apple computes FOUR_PLUS from the honest content answers above, because
    // none of its content categories apply: no violence, no sexual content, no
    // drugs, no profanity, no horror. That computation ignores a fact this app
    // does have — user-generated content. Users upload photos of themselves and
    // share outfits, and another user's shared page renders their content with
    // no block or mute control (TD-125), so the audience the app is suitable for
    // is 13+, not 4+. The product decision is 12+/13+, and 13+ is the closest
    // App Store bucket. Over-declaring is the allowed direction: Apple accepts a
    // rating higher than the computed one, never lower.
    value: 'THIRTEEN_PLUS',
    reason:
      'User-generated content is visible to other users via shared outfit links '
      + 'and there is no block/mute control, so 13+ is the honest audience even '
      + 'though no content category scores above NONE.',
  },
  koreaAgeRatingOverride: {
    value: 'NONE',
    reason: 'No Korea-specific override.',
  },
  gracRatingClassificationNumber: {
    value: null,
    reason: 'No GRAC (Korea) classification number on file.',
  },
  developerAgeRatingInfoUrl: {
    value: null,
    reason: 'No developer age-rating info page.',
  },
};

/** Fields the API computes. Never sent, never diffed. */
const COMPUTED = new Set([
  'appStoreAgeRating',
  'brazilAgeRating',
  'brazilAgeRatingV2',
  'koreaAgeRating',
  'franceAgeRating',
  'australiaAgeRating',
]);

// ---------------------------------------------------------------------------
// Source assertions: the declaration must not contradict the code
// ---------------------------------------------------------------------------

/** Every .dart file under flutter/lib. */
function dartFiles(dir = join(FLUTTER, 'lib')) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) out.push(...dartFiles(path));
    else if (entry.endsWith('.dart')) out.push(path);
  }
  return out;
}

/** WebView packages that would make unrestrictedWebAccess true. */
const WEBVIEW_PACKAGES = [
  'webview_flutter',
  'flutter_inappwebview',
  'webview_flutter_android',
  'webview_flutter_wkwebview',
  'flutter_webview_plugin',
  'flutter_html',
];
const WEBVIEW_SYMBOLS = [
  'InAppWebView',
  'WebViewController',
  'WebViewWidget',
  'HeadlessInAppWebView',
  'ChromeSafariBrowser',
];

/** Schemes that leave the app through the OS rather than rendering a page. */
const EXTERNAL_SCHEMES = new Set(['mailto', 'tel', 'sms', 'app-settings']);

function launchSites(files) {
  const sites = [];
  for (const file of files) {
    const lines = readFileSync(file, 'utf8').split('\n');
    lines.forEach((line, index) => {
      if (!/\b(?:launchUrl|canLaunchUrl|launchUrlString)\b/.test(line)) return;
      // The mode may be on this line or the next two (call sites wrap).
      const window = lines.slice(index, index + 3).join(' ');
      const external = /LaunchMode\.externalApplication/.test(window);
      const inApp = /LaunchMode\.(?:inAppBrowserView|inAppWebView|platformDefault)/.test(
        window,
      );
      const schemeMatch = lines
        .slice(Math.max(0, index - 6), index + 1)
        .join(' ')
        .match(/Uri\.parse\(\s*'([a-z-]+):/i)
        ?? lines.slice(Math.max(0, index - 6), index + 1).join(' ').match(
          /scheme:\s*'([a-z-]+)'/i,
        );
      sites.push({
        file: file.slice(ROOT.length + 1),
        line: index + 1,
        external,
        inApp,
        scheme: schemeMatch?.[1]?.toLowerCase() ?? null,
      });
    });
  }
  return sites;
}

function checkAssertions() {
  const files = dartFiles();
  const pubspec = readFileSync(join(FLUTTER, 'pubspec.yaml'), 'utf8');
  const violations = [];
  const evidence = [];

  // 1. No WebView package or symbol anywhere.
  const pubspecHits = WEBVIEW_PACKAGES.filter((name) => pubspec.includes(name));
  if (pubspecHits.length > 0) {
    violations.push(
      `flutter/pubspec.yaml declares ${pubspecHits.join(', ')} — that IS `
        + 'in-app web access.',
    );
  }
  const symbolHits = [];
  for (const file of files) {
    const text = readFileSync(file, 'utf8');
    for (const symbol of WEBVIEW_SYMBOLS) {
      if (text.includes(symbol)) {
        symbolHits.push(`${file.slice(ROOT.length + 1)}: ${symbol}`);
      }
    }
  }
  if (symbolHits.length > 0) {
    violations.push(`WebView symbol in use: ${symbolHits.join('; ')}`);
  }
  evidence.push(
    'no WebView package in pubspec.yaml and no WebView symbol in '
      + `${files.length} Dart files`,
  );

  // 2. Every url_launcher call must leave the app.
  const sites = launchSites(files);
  const ambiguous = sites.filter((s) => s.inApp);
  if (ambiguous.length > 0) {
    violations.push(
      'url_launcher opens an in-app browser or platformDefault at: '
        + ambiguous.map((s) => `${s.file}:${s.line}`).join(', '),
    );
  }
  const notExternal = sites.filter(
    (s) => !s.external && !(s.scheme && EXTERNAL_SCHEMES.has(s.scheme)),
  );
  if (notExternal.length > 0) {
    violations.push(
      'url_launcher call without LaunchMode.externalApplication: '
        + notExternal.map((s) => `${s.file}:${s.line}`).join(', '),
    );
  }
  evidence.push(
    `${sites.length} url_launcher call sites, all externalApplication or an `
      + `OS intent (${[...EXTERNAL_SCHEMES].join('/')})`,
  );

  // 3. No social graph: no follow/like/comment/feed surface.
  // `(?![a-z])` keeps `Feedback` from reading as a `Feed` type.
  const SOCIAL_TYPE_RE =
    /\b(?:class|enum|mixin)\s+(?:Follow|Follower|Following|Like|Likes|Comment|Comments|Feed|Feeds|Post|Posts)(?![a-z])\w*/;
  const socialHits = [];
  for (const file of files) {
    const text = readFileSync(file, 'utf8');
    const match = text.match(SOCIAL_TYPE_RE);
    if (match) socialHits.push(`${file.slice(ROOT.length + 1)}: ${match[0]}`);
  }
  if (socialHits.length > 0) {
    violations.push(
      `possible social-graph types in: ${socialHits.join(', ')} — recheck `
        + 'socialMedia before declaring false.',
    );
  }
  evidence.push('no Follow / Like / Comment / Feed type in the Dart source');

  // 4. No user-to-user chat.
  const chatHits = [];
  for (const file of files) {
    const text = readFileSync(file, 'utf8');
    if (/\bclass\s+\w*Chat\w*/.test(text)) chatHits.push(file.slice(ROOT.length + 1));
  }
  if (chatHits.length > 0) {
    violations.push(
      `possible chat surface in: ${chatHits.join(', ')} — recheck `
        + 'messagingAndChat before declaring false.',
    );
  }
  evidence.push('no chat type in the Dart source');

  // 5. No advertising SDK.
  const adPackages = ['google_mobile_ads', 'admob', 'applovin', 'unity_ads'];
  const adHits = adPackages.filter((name) => pubspec.includes(name));
  if (adHits.length > 0) {
    violations.push(`ad SDK in pubspec.yaml: ${adHits.join(', ')}`);
  }
  evidence.push('no ad SDK in pubspec.yaml');

  return { violations, evidence, sites };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function show(value) {
  if (value === null || value === undefined) return '(null)';
  return String(value);
}

/** The attributes to send: only what the proposal changes. */
function changedAttributes(current) {
  const changed = {};
  const unchanged = [];
  for (const [field, spec] of Object.entries(PROPOSED)) {
    if (COMPUTED.has(field)) continue;
    const now = current[field];
    if (now === spec.value) unchanged.push(field);
    else changed[field] = spec.value;
  }
  return { changed, unchanged };
}

async function main() {
  const app = readStoreFile('app.json');
  const client = createClient({ ...credentialsFromEnv(), dryRun: !apply });

  heading('Target');
  console.log(`  app      ${app.bundleId} (${app.appId})`);
  console.log(`  mode     ${apply ? 'APPLY (writes)' : 'report only (no writes)'}`);
  await findApp(client, app);

  // appInfos has no GET_COLLECTION; it is reachable through the app.
  const withInfos = await client.get(`/v1/apps/${app.appId}?include=appInfos`);
  const infos = (withInfos.included ?? []).filter((i) => i.type === 'appInfos');
  // An app has one appInfo per release lifecycle. Only the DRAFT one carries an
  // editable age rating declaration; the live record answers
  //   409 STATE_ERROR: This age rating declaration is not editable.
  //   Is the corresponding AppInfos editable?
  // Picking whichever came first meant the PATCH always targeted the live
  // record, so the fix could never land once a version had shipped.
  const appInfo = infos.find((i) => i.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION')
    ?? infos.find((i) => i.attributes?.appStoreState !== 'REPLACED_WITH_NEW_INFO')
    ?? infos[0];
  if (!appInfo) {
    throw new Error(
      `No appInfo on app ${app.appId}. Age rating lives on an appInfo; `
        + 'this app has none, which means the app record is not what this '
        + 'script thinks it is.',
    );
  }
  const a = appInfo.attributes ?? {};
  console.log(`  appInfo  ${appInfo.id}`);
  console.log(`  state    ${a.appStoreAgeRating} (store ${a.appStoreState} / ${a.state})`);
  if (a.appStoreState !== 'PREPARE_FOR_SUBMISSION') {
    console.log(
      '  warning: this appInfo is not PREPARE_FOR_SUBMISSION, so the PATCH will '
        + 'be refused. Run `node scripts/asc/publish.mjs prepare --apply` first.',
    );
  }
  const region = [
    ['Brazil', a.brazilAgeRatingV2 ?? a.brazilAgeRating],
    ['France', a.franceAgeRating],
    ['Australia', a.australiaAgeRating],
    ['Korea', a.koreaAgeRating],
  ]
    .filter(([, v]) => v)
    .map(([k, v]) => `${k} ${v}`)
    .join(', ');
  if (region) console.log(`  regions  ${region}`);

  const declaration = await client.get(
    `/v1/appInfos/${appInfo.id}/ageRatingDeclaration`,
  );
  const current = declaration.data?.attributes ?? {};
  const declarationId = declaration.data?.id;
  if (!declarationId) {
    throw new Error('ageRatingDeclaration returned no id — cannot PATCH it.');
  }

  heading('Current declaration (live)');
  for (const field of Object.keys(current).sort()) {
    console.log(`  ${field.padEnd(48)} ${show(current[field])}`);
  }

  heading('Proposal');
  for (const [field, spec] of Object.entries(PROPOSED)) {
    const marker = current[field] === spec.value ? '  ' : '->';
    console.log(
      `  ${marker} ${field.padEnd(44)} ${show(current[field]).padEnd(22)} `
        + `${show(spec.value)}`,
    );
  }

  const { changed, unchanged } = changedAttributes(current);
  const fields = Object.keys(changed);

  heading('Field-by-field diff');
  if (fields.length === 0) {
    console.log('  The live declaration already matches the proposal.');
    console.log(`  ${unchanged.length} fields verified identical.`);
  } else {
    for (const field of fields) {
      const spec = PROPOSED[field];
      console.log(`  ${field}`);
      console.log(`    now       ${show(current[field])}`);
      console.log(`    proposed  ${show(spec.value)}`);
      console.log(`    why       ${spec.reason}`);
    }
  }

  // The declaration is a claim about the code. Check the code.
  heading('Source assertions (does the app back the claim?)');
  const { violations, evidence, sites } = checkAssertions();
  for (const line of evidence) console.log(`  ok    ${line}`);
  for (const site of sites) {
    console.log(
      `        ${site.file}:${site.line}`
        + `  ${site.external ? 'externalApplication' : `scheme=${site.scheme ?? '?'}`}`,
    );
  }
  if (violations.length > 0) {
    console.log('');
    for (const violation of violations) console.log(`  FAIL  ${violation}`);
    console.log(
      '\n  Refusing to declare unrestrictedWebAccess: false. Fix the code or '
      + 'change the proposal; a wrong but lower rating is an App Review '
      + 'rejection, which costs about a week.',
    );
    process.exitCode = 1;
    return;
  }

  if (fields.length === 0) {
    console.log('\n  No PATCH needed. Nothing to do.');
    return;
  }

  // Editing an appInfo is state-gated. Say so before the write, not after.
  const editable = new Set([
    'PREPARE_FOR_SUBMISSION',
    'READY_FOR_SALE',
    'READY_FOR_DISTRIBUTION',
    'WAITING_FOR_REVIEW',
    'IN_REVIEW',
    'PENDING_DEVELOPER_RELEASE',
    'PROCESSING_FOR_APP_STORE',
  ]);
  if (a.appStoreState && !editable.has(a.appStoreState)) {
    console.log(
      `\n  WARNING app state is ${a.appStoreState}; App Store Connect may `
        + 'reject this PATCH until the app becomes editable.',
    );
  }

  const body = {
    data: {
      type: 'ageRatingDeclarations',
      id: declarationId,
      attributes: changed,
    },
  };

  heading(apply ? 'Patching' : 'Would patch');
  console.log(`  PATCH /v1/ageRatingDeclarations/${declarationId}`);
  console.log(`  ${JSON.stringify(body.data.attributes)}`);

  if (!apply) {
    console.log(
      `\n  ${fields.length} field(s) would change. Re-run with --apply.`
        + '\n  Expect the rating to move from 17+ to 12+/13+ once saved.',
    );
    return;
  }

  try {
    await client.patch(`/v1/ageRatingDeclarations/${declarationId}`, body);
  } catch (error) {
    if (error.status === 409) {
      console.log(
        '\n  App Store Connect refused the change as a state conflict:'
          + `\n    ${error.message}`
          + '\n  Create the 1.3.0 version first '
          + '(`node scripts/asc/publish.mjs prepare`) and re-run this.',
      );
      process.exitCode = 1;
      return;
    }
    throw error;
  }

  heading('Resulting declaration (re-read)');
  const after = await client.get(
    `/v1/appInfos/${appInfo.id}/ageRatingDeclaration`,
  );
  const afterAttrs = after.data?.attributes ?? {};
  for (const field of Object.keys(changed).sort()) {
    console.log(
      `  ${field.padEnd(48)} ${show(afterAttrs[field])}`
        + (afterAttrs[field] === changed[field] ? '' : '   UNCHANGED BY APPLE'),
    );
  }
  const afterInfos = await client.get(`/v1/apps/${app.appId}?include=appInfos`);
  // Read back the same record that was patched. Reading "whichever appInfo came
  // first" reports the LIVE rating, which does not move until 1.3.0 ships, so a
  // successful write looked like a failed one.
  const afterCandidates = (afterInfos.included ?? []).filter((i) => i.type === 'appInfos');
  const info = afterCandidates.find((i) => i.attributes?.appStoreState === 'PREPARE_FOR_SUBMISSION')
    ?? afterCandidates[0];
  console.log(`\n  appStoreAgeRating is now ${info?.attributes?.appStoreAgeRating}`);
  console.log(
    '  If the rating did not move, the declaration saved but the listing '
      + 'rating is published on the next version. Check the product page '
      + "after 1.3.0 (or after Apple's propagation, up to a few hours).",
  );
}

main().catch((error) => {
  console.error(`FAILED: ${error.message}`);
  if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1200));
  process.exit(1);
});
