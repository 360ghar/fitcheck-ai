#!/usr/bin/env node
/**
 * Creates the free month on Pro Monthly.
 *
 * The offer is an App Store **introductory offer** with `offerMode: FREE_TRIAL`
 * and `duration: ONE_MONTH`. That choice, rather than an in-app grant, is what
 * makes "1 month free" true in the way the App Store can verify and the way
 * Apple's own subscription management displays: the user sees the trial on the
 * product page, cancels in Settings, and the trial can only be used once per
 * subscription group.
 *
 * What this deliberately does not do:
 *   - touch Plus or the yearly plans (the trial is on Pro Monthly only),
 *   - set a territory list (omitting it applies the offer in every storefront,
 *     which is what "all countries" means here),
 *   - create a second offer when one already exists (Apple allows one
 *     introductory offer per subscription; a duplicate is a hard 409).
 *
 * Two fields people expect and this payload correctly omits:
 *   - **eligibility**: there is no eligibility field on an introductory offer.
 *     The App Store computes it. A new subscriber is eligible; a subscriber who
 *     has already taken an introductory offer **in this subscription group**
 *     is not. That is why [reportGroupOffers] prints the whole group.
 *   - **offerCode**: offer codes are a different resource
 *     (`subscriptionOfferCodes`, redeemed with a code). An introductory offer
 *     is automatic and needs no code.
 *
 * Usage:
 *   node scripts/asc/offers.mjs            # report only, no writes
 *   node scripts/asc/offers.mjs --verify   # report whether the trial is live
 *   node scripts/asc/offers.mjs --simulate # run the whole apply path; send nothing
 *   node scripts/asc/offers.mjs --apply    # create the offer if missing
 */

import { createClient, credentialsFromEnv, findApp, readStoreFile } from './asc.mjs';

const sends = process.argv.includes('--apply');
const simulate = process.argv.includes('--simulate');
const apply = sends || simulate;
const verifyOnly = process.argv.includes('--verify');
if ([sends, simulate, verifyOnly].filter(Boolean).length > 1) {
  console.error('--apply, --simulate and --verify are mutually exclusive.');
  process.exit(1);
}
const dryRun = !sends;

function heading(text) {
  console.log(`\n${text}`);
  console.log('-'.repeat(text.length));
}

/** Values App Store Connect accepts. Anything else is a hard 409/400. */
const OFFER_MODES = new Set(['FREE_TRIAL', 'PAY_AS_YOU_GO', 'PAY_UP_FRONT']);
const DURATIONS = new Set([
  'THREE_DAYS',
  'ONE_WEEK',
  'TWO_WEEKS',
  'ONE_MONTH',
  'TWO_MONTHS',
  'THREE_MONTHS',
  'SIX_MONTHS',
  'ONE_YEAR',
]);

async function findSubscription(client, groupId, productId) {
  const subs = await client.getAll(`/v1/subscriptionGroups/${groupId}/subscriptions?limit=50`);
  return subs.find((sub) => sub.attributes?.productId === productId) ?? null;
}

function summarize(offer) {
  const a = offer.attributes ?? {};
  return `${String(a.offerMode).padEnd(13)} ${String(a.duration).padEnd(11)}`
    + ` x${a.numberOfPeriods ?? 1}`
    + `  start=${a.startDate ?? 'immediately'}`
    + `  end=${a.endDate ?? 'no end'}`
    + `  territory=${a.territory ?? 'all'}`;
}

/**
 * Apple grants one introductory offer per customer **per subscription group**,
 * not per subscription. A user who already took the Plus trial cannot take
 * this one, and the paywall has to say so — which is exactly the
 * `isEligibleForIntroOffer` check the app runs natively. Reporting the group
 * makes that visible before anyone is surprised by it in sandbox.
 */
async function reportGroupOffers(client, groupId) {
  const subs = await client.getAll(`/v1/subscriptionGroups/${groupId}/subscriptions?limit=50`);
  for (const sub of subs) {
    const productId = sub.attributes?.productId;
    const level = sub.attributes?.groupLevel;
    const offers = await client.getAll(
      `/v1/subscriptions/${sub.id}/introductoryOffers?limit=200`,
    );
    const label = offers.length === 0
      ? '(no introductory offer)'
      : offers.map(summarize).join(' | ');
    console.log(
      `  level ${String(level).padEnd(3)} ${String(productId).padEnd(46)} ${label}`,
    );
  }
}

/** Whether `offer` is the configured trial, field for field. */
function matchesTrial(offer, trial) {
  const a = offer.attributes ?? {};
  return a.offerMode === trial.offerMode
    && a.duration === trial.duration
    && (a.numberOfPeriods ?? 1) === trial.numberOfPeriods;
}

async function main() {
  const app = readStoreFile('app.json');
  const trial = app.trial;
  const client = createClient({ ...credentialsFromEnv(), dryRun });
  await findApp(client, app);

  const mode = sends
    ? 'APPLY (writes)'
    : simulate
      ? 'simulate (full apply path, no write)'
      : verifyOnly
        ? 'verify only'
        : 'report only (no writes)';

  heading('Target');
  console.log(`  product   ${trial.productId}`);
  console.log(`  offer     ${trial.offerMode} / ${trial.duration} x ${trial.numberOfPeriods}`);
  console.log(`  mode      ${mode}`);

  // --- Config validation, before anything is sent --------------------------
  const problems = [];
  if (!OFFER_MODES.has(trial.offerMode)) {
    problems.push(`offerMode ${trial.offerMode} is not one of ${[...OFFER_MODES].join(', ')}`);
  }
  if (!DURATIONS.has(trial.duration)) {
    problems.push(`duration ${trial.duration} is not one of ${[...DURATIONS].join(', ')}`);
  }
  // Apple requires exactly one period for a free trial. More than one would
  // mean two free months, which no field here can express.
  if (trial.offerMode === 'FREE_TRIAL' && trial.numberOfPeriods !== 1) {
    problems.push(
      `FREE_TRIAL requires numberOfPeriods: 1, got ${trial.numberOfPeriods}`,
    );
  }
  if (problems.length > 0) {
    for (const problem of problems) console.log(`\n  INVALID ${problem}`);
    process.exitCode = 1;
    return;
  }

  const subscription = await findSubscription(
    client,
    app.subscriptionGroupId,
    trial.productId,
  );
  if (!subscription) {
    throw new Error(
      `${trial.productId} is not in subscription group ${app.subscriptionGroupId}. `
      + 'Check store/asc/app.json against App Store Connect.',
    );
  }
  const subAttrs = subscription.attributes ?? {};
  console.log(`  state     ${subAttrs.state}`);
  console.log(`  id        ${subscription.id}`);
  console.log(`  period    ${subAttrs.subscriptionPeriod} (trial ${trial.duration})`);

  // A trial longer than the billing period still works (one free month on a
  // monthly plan is exactly one period), but a trial far longer than the plan
  // is a price-model mistake, not a technical one.
  const PERIOD_DAYS = {
    THREE_DAYS: 3, ONE_WEEK: 7, TWO_WEEKS: 14, ONE_MONTH: 30,
    TWO_MONTHS: 60, THREE_MONTHS: 90, SIX_MONTHS: 180, ONE_YEAR: 365,
  };
  const subDays = PERIOD_DAYS[subAttrs.subscriptionPeriod] ?? 30;
  const trialDays = PERIOD_DAYS[trial.duration] ?? 30;
  if (trialDays > subDays * 3) {
    console.log(
      `\n  WARNING trial (${trial.duration}) is more than 3x the billing `
        + `period (${subAttrs.subscriptionPeriod}). Confirm that is intended.`,
    );
  }

  // --- Live offers ---------------------------------------------------------
  heading('Existing introductory offers (target subscription)');
  const offers = await client.getAll(
    `/v1/subscriptions/${subscription.id}/introductoryOffers?limit=200`,
  );
  if (offers.length === 0) {
    console.log('  (none)');
  }
  for (const offer of offers) {
    console.log(`  ${offer.id}  ${summarize(offer)}`);
  }

  heading('Whole subscription group (eligibility is once per group)');
  console.log(`  group ${app.subscriptionGroupId}`);
  await reportGroupOffers(client, app.subscriptionGroupId);

  const matching = offers.filter((offer) => matchesTrial(offer, trial));
  const present = matching.length > 0;

  // --- Verdict -------------------------------------------------------------
  heading('Verdict');
  if (present) {
    console.log(`  TRIAL PRESENT — ${matching.map((o) => o.id).join(', ')}`);
    console.log('  Nothing to do. No write is needed or offered.');
    if (verifyOnly) return;
    return;
  }
  console.log(`  TRIAL MISSING — ${trial.offerMode} / ${trial.duration} is not live`);

  if (offers.length > 0) {
    // Apple permits exactly one introductory offer per subscription. Replacing
    // an existing one is a product decision (it drops the trial every current
    // non-subscriber would have seen), so this refuses rather than overwrites.
    console.log(
      '\n  This subscription already has a DIFFERENT introductory offer:'
        + offers.map((o) => `\n    ${o.id}  ${summarize(o)}`).join('')
        + '\n  Apple allows one per subscription. Remove it in App Store Connect'
        + '\n  first, or change store/asc/app.json to match what is live.'
        + '\n  Refusing to overwrite.',
    );
    process.exitCode = 1;
    return;
  }

  if (verifyOnly) {
    console.log('\n  Run `node scripts/asc/offers.mjs --apply` to create it.');
    process.exitCode = 1;
    return;
  }

  // --- The exact mutation --------------------------------------------------
  // Built once, printed whole, then either sent or not. `offerMode`,
  // `duration` and `numberOfPeriods` are the only attributes App Store
  // `territory` is REQUIRED. An earlier version of this script omitted it on
  // the theory that "no relationship" means "every storefront"; the live API
  // rejects that outright with
  //   409 ENTITY_ERROR.RELATIONSHIP.REQUIRED: You must provide a value for the
  //   relationship 'territory'
  // so a dry run proved nothing. An introductory offer is scoped to exactly one
  // territory, and "everywhere" means one offer per territory — 175 of them.
  // Still no `pricePoint`: a free trial has none. Still no `eligibility`: the
  // App Store grants that to new subscribers only, once per subscription group.
  const path = '/v1/subscriptionIntroductoryOffers';
  const bodyFor = (territoryId) => ({
    data: {
      type: 'subscriptionIntroductoryOffers',
      attributes: {
        offerMode: trial.offerMode,
        duration: trial.duration,
        numberOfPeriods: trial.numberOfPeriods,
      },
      relationships: {
        subscription: {
          data: { type: 'subscriptions', id: subscription.id },
        },
        territory: {
          data: { type: 'territories', id: territoryId },
        },
      },
    },
  });

  // Resume rather than restart: a second run must not try to add 175 offers
  // that already exist, and must not stop at the first territory that does.
  const existingOffers = await client.getAll(
    `/v1/subscriptions/${subscription.id}/introductoryOffers?limit=200&include=territory`,
  );
  const already = new Set(
    existingOffers
      .filter((offer) => matchesTrial(offer, trial))
      .map((offer) => offer.relationships?.territory?.data?.id)
      .filter(Boolean),
  );

  const territories = await client.getAll('/v1/territories?limit=200');
  const todo = territories.map((row) => row.id).filter((id) => !already.has(id));

  heading(apply ? 'Creating' : 'Would create');
  console.log(`  ${territories.length} territory/territories, ${already.size} already covered`);
  if (already.size === 0) {
    console.log('\n  body (one per territory):');
    console.log(
      JSON.stringify(bodyFor('USA'), null, 2)
        .split('\n')
        .map((line) => `    ${line}`)
        .join('\n'),
    );
  }

  if (!apply) {
    console.log(`\n  ${todo.length} territory/territories would be written.`);
    console.log('  Re-run with --apply to create them.');
    return;
  }

  let createdCount = 0;
  const failures = [];
  for (const [index, territoryId] of todo.entries()) {
    try {
      await client.post(path, bodyFor(territoryId));
      createdCount += 1;
    } catch (error) {
      // A duplicate here means another run won the race; that is success.
      if (/DUPLICATE|already/i.test(error.message)) {
        createdCount += 1;
        continue;
      }
      failures.push(`${territoryId}: ${error.message.slice(0, 110)}`);
    }
    if ((index + 1) % 25 === 0) {
      console.log(`  ${index + 1}/${todo.length} …`);
    }
  }
  console.log(`\n  created ${createdCount} of ${todo.length}`);
  for (const failure of failures.slice(0, 8)) console.log(`    ${failure}`);
  if (failures.length > 8) console.log(`    … and ${failures.length - 8} more`);

  heading('Verify (re-read from the API)');
  const after = await client.getAll(
    `/v1/subscriptions/${subscription.id}/introductoryOffers?limit=200&include=territory`,
  );
  const covered = new Set(
    after
      .filter((offer) => matchesTrial(offer, trial))
      .map((offer) => offer.relationships?.territory?.data?.id)
      .filter(Boolean),
  );
  console.log(`  trial offer present in ${covered.size}/${territories.length} territories`);
  if (covered.size === 0) {
    console.log('\n  FAILED the offer is not present after the write. Check the');
    console.log('  App Store Connect UI for a partially-created offer.');
    process.exitCode = 1;
    return;
  }
  if (covered.size < territories.length) {
    console.log(
      `\n  INCOMPLETE ${territories.length - covered.size} territory/territories have no `
        + 'trial. Re-run --apply; it resumes.',
    );
    process.exitCode = 1;
    return;
  }
  console.log(
    '\n  The trial is live on Pro Monthly in every storefront.'
    + '\n  New subscribers only (once per subscription group), card required,'
    + '\n  renews at the Pro Monthly price when the free month ends.'
    + '\n  Regenerate the paywall screenshot set if it shows the old CTA.',
  );
}

main().catch((error) => {
  console.error(`FAILED: ${error.message}`);
  if (error.payload) console.error(JSON.stringify(error.payload, null, 2).slice(0, 1200));
  process.exit(1);
});
