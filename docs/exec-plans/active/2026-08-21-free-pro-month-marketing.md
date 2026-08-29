# Plan: Recover signups — market the first-month-free Pro trial

Status: active
Started: 2026-08-21
Owner: agent

## Goal

Signups fell from hundreds/day (campaign-driven) to ~3/day. Make the existing
"first month of Pro free" offer visible across the landing funnel and relaunch
acquisition, using the proven promo-code machinery — no backend changes.

## Diagnosis

- The August spike came from campaigns (Aug 3 Pro grant, Girlfriend Day), not
  evergreen demand; when the campaign ended, traffic collapsed.
- New accounts get a plain `free` subscription
  (`SubscriptionService.create_default_subscription`). The free-Pro-month only
  reached users via manual campaign scripts or promo codes.
- No landing surface mentioned the offer: hero/pricing/CTA all said "Start
  free", register page had no offer copy.
- Funnel was uninstrumented: PostHog wired (`lib/analytics.ts`) but no
  `landing_cta_click` / `register_view` / `signup_success` events existed, so
  traffic-vs-conversion could not be distinguished.

Decision (owner): deliver the offer as marketing over the existing promo-code
mechanics; do not auto-grant trials at signup.

## Changes

| File | Change |
|------|--------|
| `frontend/src/lib/trial-offer.ts` | NEW: `TRIAL_PROMO_CODE` ('TRYPRO') + href builders |
| `frontend/src/components/landing/Hero.tsx` | Offer badge line; primary CTA → `/auth/register?promo=TRYPRO`; `landing_cta_click` |
| `frontend/src/components/landing/Pricing.tsx` | "First month of Pro free" pill; plan CTAs append `&promo=TRYPRO`; `landing_cta_click` |
| `frontend/src/components/landing/CTASection.tsx` | Bottom CTA carries promo param + offer copy; `landing_cta_click` |
| `frontend/src/pages/auth/RegisterPage.tsx` | Offer subheading (promo-aware); `register_view` + `signup_success` events |
| `frontend/src/components/landing/FAQ.tsx` | "How does the first month of Pro free work?" entry |

## Promo code (live)

- Code `TRYPRO`: `pro_monthly`, 1 month, max 2000 uses, expires 2026-10-01,
  id `faf2fd74-fb70-4dad-be5d-1b710b14d463`.
- Created with `backend/scripts/create_promo_code.py`.
- Shareable URL: `https://fitcheckaiapp.com/auth/register?promo=TRYPRO`
- Redemption path is pre-existing: RegisterPage stashes the code (survives
  Google OAuth), plan page validates + redeems it post-signup.

## Campaign checklist (non-code)

1. Share `https://fitcheckaiapp.com/auth/register?promo=TRYPRO` through the
   same channels that drove the August spike (same playbook as the Aug 3 grant
   and Girlfriend Day campaigns).
2. Frame as "free" per owner instruction: "Get your first month of Pro free".
3. Watch PostHog daily: `landing_cta_click` by location, `register_view`
   split by `has_promo`, `signup_success`.

## Verification

```bash
cd frontend && npm run lint && npm test && npm run build
```

Manual: `/` shows the hero badge and pricing pill; every CTA lands on
`/auth/register?promo=TRYPRO`; green promo notice renders on the register page.

## Follow-ups / debt

- If `TRYPRO` is retired or replaced, update `TRIAL_PROMO_CODE` in
  `frontend/src/lib/trial-offer.ts` (single source for all CTAs).
- Traffic recovery itself is off-repo (campaign channels); this plan covers the
  on-site conversion surface + instrumentation only.
