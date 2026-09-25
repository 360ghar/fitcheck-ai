# Onboarding

Status: implemented  
Last updated: 2026-09-25

## Mobile intro (signed out, first launch)

Three swipeable paper sheets before the sign-in entry, one per promise:

1. "Snap your closet once." (moss stock, closet scene)
2. "Get dressed faster." (marigold stock, outfits scene)
3. "See it before you wear it." (clay stock, studio scene)

"Skip" and "Get started" both mark the intro as seen on this device and open
the sign-in entry (`/onboarding`). Code: `flutter/lib/features/onboarding/`.

## First-run setup (signed in, new account)

Web `/welcome` and mobile `/welcome` run the same three steps. Every step can
be skipped, and "Skip setup" leaves at any point.

1. **Who are we styling?** Gender (`male`, `female`, `non_binary`,
   `prefer_not_to_say`), saved with `PUT /users/me`. It sets the model for
   try-on and photoshoots.
2. **What do you wear most?** Styles and occasions, saved with
   `PUT /users/preferences` (`preferred_styles`, `preferred_occasions`).
3. **Add your first pieces.** Opens the item upload, or "Later".

Who sees it: an account younger than 7 days that has not finished or skipped
setup on this device. The web also requires no gender; mobile requires no
preferred styles (TD-118). The done flag is per device (TD-117).

The web dashboard "Getting started" checklist is unchanged and still covers
the first item, first outfit, avatar and try-on.
