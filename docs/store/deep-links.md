# Deep links and custom product pages

**Last updated:** 2026-10-26

Custom product pages let one App Store listing host several product pages, each with its own
screenshots, promotional text and a distinct **URL**. A campaign that promises "snap your whole
closet at once" should land on the screen that does that, not on the home tab.

This document is the source of truth for the URL scheme, the routes a link may open, and the one
link the app refuses to navigate.

## Scheme

`fitcheck.ai://`

Registered in `flutter/ios/Runner/Info.plist` under `CFBundleURLTypes` →
`CFBundleURLSchemes`. The value is also in `store/asc/app.json` as `deepLinkScheme`, and asserted in
`flutter/lib/core/deeplinks/deep_link_router.dart` as `kDeepLinkScheme`.

Any of these shapes resolve identically:

```
fitcheck.ai://wardrobe          # host form
fitcheck.ai:///wardrobe         # path form
fitcheck.ai://wardrobe/         # trailing slash
```

Query strings and fragments are **ignored**, not interpreted. A campaign has no use for arbitrary
route state, and honouring it would let an external URL put the app into a screen it did not
expect.

## Supported destinations

Every path below is asserted in
`flutter/test/core/deeplinks/deep_link_router_test.dart`. Changing a route without updating that
test fails CI before a campaign can point at a dead destination.

| Deep link | Opens | Suggested campaign |
|---|---|---|
| `fitcheck.ai://home` | Home tab | Brand / generic |
| `fitcheck.ai://wardrobe` | Closet tab | "Your closet, digitised" |
| `fitcheck.ai://wardrobe/add` | Add one item | — |
| `fitcheck.ai://wardrobe/batch-add` | Add the whole rail at once | **Primary trial campaign**: the screen the free month exists for |
| `fitcheck.ai://wardrobe/batch-add-social` | Import from social | Reels / TikTok creative |
| `fitcheck.ai://wardrobe/jobs` | Extraction activity | — |
| `fitcheck.ai://wardrobe/stats` | Closet stats | "What's in your wardrobe" |
| `fitcheck.ai://outfits` | Outfits tab | Styling campaigns |
| `fitcheck.ai://outfits/build` | Outfit builder | — |
| `fitcheck.ai://outfits/collections` | Saved collections | — |
| `fitcheck.ai://outfits/<id>` | One outfit | Share links |
| `fitcheck.ai://wardrobe/<id>` | One item | — |
| `fitcheck.ai://calendar` | Outfit calendar | Planning campaigns |
| `fitcheck.ai://photoshoot` | AI photoshoot | Headshot / LinkedIn creative |
| `fitcheck.ai://try-on` | Virtual try-on | — |
| `fitcheck.ai://recommendations` | Recommendations | — |
| `fitcheck.ai://subscription` | Paywall | Retargeting |
| `fitcheck.ai://referral` | Referral code | Referral campaign |
| `fitcheck.ai://gifts` | Gift vouchers | Gifting campaign (seasonal) |
| `fitcheck.ai://gamification` | Streaks and badges | — |
| `fitcheck.ai://profile` | Profile | — |
| `fitcheck.ai://profile/body-profiles` | Body profiles | — |
| `fitcheck.ai://settings` | Settings | — |
| `fitcheck.ai://settings/language` | Language picker | Localised campaign pages |
| `fitcheck.ai://help` | Help | — |
| `fitcheck.ai://legal` | Terms and privacy | — |
| `fitcheck.ai://feedback` | Feedback | — |
| `fitcheck.ai://more` | More tab | — |
| `fitcheck.ai://shared/<id>` | A shared outfit (public, no sign-in) | Share links, UGC |

**Unknown paths land on `fitcheck.ai://home`**, never a blank screen and never a crash. That is a
deliberate behaviour: a typo in a live campaign costs the campaign, not the app.

## The one link the app does not navigate

`fitcheck.ai://social-import-callback?job_id=…&status=…`

This is OAuth, not navigation. It is owned by
`flutter/lib/features/wardrobe/providers/batch_extraction_provider.dart`
(`_handleSocialOAuthUri`), which reads `job_id` and `status`, adopts the job, refreshes the scraper
status and subscribes to the job's event stream. `resolveDeepLink` returns `null` for it in both
directions:

* the generic router does not resolve it, so it cannot send the app to a route mid-OAuth;
* the generic router does not *block* it, because `app_links` delivers every link to every
  listener. `batch_extraction_provider.dart` keeps its own subscription and sees it exactly as
  before.

Two tests hold this line. `test/core/deeplinks/deep_link_router_test.dart` asserts the callback
resolves to `null`; `test/features/wardrobe/controllers/batch_extraction_controller_test.dart`
drives a real callback through the provider and asserts the job id is adopted and the status
refreshed. Regressing either one breaks the social import flow.

## Where this lives in code

| File | Role |
|---|---|
| `flutter/lib/core/deeplinks/deep_link_router.dart` | Path → `go_router` mapping, `DeepLinkController`, `DeepLinkStarter` |
| `flutter/lib/app/router.dart` | Registers `DeepLinkStarter` as a navigator observer |
| `flutter/ios/Runner/Info.plist` | Registers the `fitcheck.ai` URL scheme |
| `flutter/test/core/deeplinks/deep_link_router_test.dart` | The contract above |

The controller starts from a `NavigatorObserver` on first push rather than in `buildRouter()`, so a
test that only reads the route table (`appRouter.configuration.findMatch`) never constructs the
`app_links` platform plugin.

## Custom product page checklist

When creating a custom product page in App Store Connect:

1. Pick the destination from the table above and paste the full URL
   (`fitcheck.ai://wardrobe/batch-add`, not `/wardrobe/batch-add`).
2. Make the screenshots on that page show the same screen the link opens.
3. After the page is live, tap the URL on a device with the production build installed and confirm
   the destination. A custom page whose link resolves to home is wasted spend.
