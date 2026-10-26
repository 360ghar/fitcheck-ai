import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../core/widgets/app_ui.dart';

/// Photoshoot images per day on the free plan.
///
/// Mirrors the backend's `PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES`
/// (`backend/app/core/config.py`), which is the number that actually enforces
/// the limit. It is not on the `/plans` payload, so it is stated here; keep the
/// two in sync or the paywall promises a limit the API does not honour.
const int kFreeDailyPhotoshootImages = 10;

/// The free month, as the loudest thing on the paywall.
///
/// Rendered only when the App Store has confirmed the user is eligible
/// (`TrialEligibility.eligible`). Every string here is a promise the store
/// will honour; showing it to an ineligible user is how a subscription app
/// earns refund requests and one-star reviews.
///
/// The copy deliberately answers four questions before the user can scroll:
/// what is free, what they can do with it, what it costs afterwards, and how
/// to stop it. Guideline 3.1.2 wants the last two visible on the purchase
/// screen; the [SubscriptionDisclosure] underneath repeats them in full.
///
/// RTL: built from a [Column] with `CrossAxisAlignment.start`, which resolves
/// against the ambient [Directionality]. No icon-before-text rows, because a
/// [Row] keeps its child order under RTL and would put the icon on the wrong
/// side.
class TrialSpotlight extends StatelessWidget {
  const TrialSpotlight({super.key, required this.priceAfterTrial});

  /// The Pro Monthly price that begins when the free month ends, already
  /// formatted for the store's currency, e.g. `$19.99`.
  final String priceAfterTrial;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return PaperSurface(
      color: tokens.stock.tint,
      borderRadius: AppConstants.radius12,
      // Not tappable: a banner that looks like a button and does nothing is
      // worse than plain copy. The CTA below owns the purchase.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // An ink stamp, matching the "Active" marker on the current plan.
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.stock.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: 3,
              ),
              child: Text(
                l10n.paywallTrialBadge,
                style: text.labelMedium?.copyWith(
                  color: tokens.stock.page,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(l10n.paywallTrialTitle, style: text.headlineMedium),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            l10n.paywallTrialBody,
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing12),
          // The post-trial price and the 24-hour cancellation rule, verbatim
          // from `paywallTrialEligibleOnly`. Guideline 3.1.2 requires both on
          // the purchase screen, and this sentence is the already-translated
          // one that says them unambiguously ("After the trial, Pro renews at
          // $19.99..."). A second bare price line above it was rejected: a
          // figure with no verb reads as the price paid today, and inventing a
          // "Then {price}" string would have meant shipping code against an
          // ARB key that does not exist yet.
          Text(
            l10n.paywallTrialEligibleOnly(priceAfterTrial),
            style: text.bodyMedium?.copyWith(
              // textSecondary rather than textMuted: this is required
              // disclosure a reviewer has to be able to read. Both pass AA.
              color: tokens.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The permanent free tier, stated as the retention story rather than fine
/// print: no card, and what the user keeps every month whether or not they
/// ever subscribe.
class FreeForeverCard extends StatelessWidget {
  const FreeForeverCard({
    super.key,
    required this.monthlyUploads,
    required this.monthlyOutfits,
    required this.dailyPhotoshootImages,
  });

  /// AI uploads per month on the free plan (50).
  final int monthlyUploads;

  /// Outfits per month on the free plan (50).
  final int monthlyOutfits;

  /// Photoshoot images per day on the free plan (10). Matches the backend's
  /// `PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES`.
  final int dailyPhotoshootImages;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return PaperSurface(
      lift: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paywallFreeForeverTitle, style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            l10n.paywallFreeForeverBody(
              monthlyUploads,
              monthlyOutfits,
              dailyPhotoshootImages,
            ),
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The honest line for a user who is not eligible for the free month: the
/// App Store's own wording, with no badge and no promise.
class TrialIneligibleNote extends StatelessWidget {
  const TrialIneligibleNote({super.key, required this.price});

  /// The Pro Monthly price, formatted for the store's currency.
  final String price;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return Text(
      context.l10n.paywallTrialEligibleOnly(price),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: tokens.textSecondary,
        height: 1.45,
      ),
    );
  }
}
