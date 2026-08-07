import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';

/// Auto-renewing subscription disclosure, rendered directly under the plan
/// cards.
///
/// App Store Review Guideline 3.1.2 requires the purchase screen itself to
/// state the subscription title, its length, its price, and that it renews
/// automatically — and to carry functional links to the Terms of Use (EULA)
/// and the Privacy Policy. Links at signup or buried in Settings do not
/// satisfy it; missing this is one of the most common subscription
/// rejections. Play's subscription policy asks for the same disclosure, so
/// this renders on both platforms.
///
/// [priceSummary] is passed in rather than hardcoded so the disclosed prices
/// match the localized store prices the reviewer actually sees on the cards.
/// [isApple] selects the billing account and cancellation path named in the
/// copy: naming the wrong store is worse than naming none.
class SubscriptionDisclosure extends StatelessWidget {
  const SubscriptionDisclosure({
    super.key,
    required this.priceSummary,
    required this.isApple,
    this.planNames = 'Plus and Pro are auto-renewing subscriptions',
  });

  /// e.g. "Plus is $10/month or $100/year; Pro is $20/month or $200/year."
  final String priceSummary;

  /// True on iOS (StoreKit), false on Android (Play Billing).
  final bool isApple;

  /// Opening clause naming what is actually purchasable on this screen — a
  /// Plus subscriber is only offered Pro.
  final String planNames;

  String get _billingSentence => isApple
      ? 'Payment is charged to your Apple ID at confirmation of purchase.'
      : 'Payment is charged to your Google Play account at confirmation of '
          'purchase.';

  String get _manageSentence => isApple
      ? 'Manage or cancel any time in Settings › your Apple ID › '
          'Subscriptions.'
      : 'Manage or cancel any time in Google Play › Payments and '
          'subscriptions.';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static ButtonStyle _linkButtonStyle(TextStyle? textStyle) =>
      TextButton.styleFrom(
        // 44pt is Apple's minimum tap target. Note VisualDensity.compact is
        // deliberately absent: density is subtracted from minimumSize, and
        // with it these links measured 36pt.
        minimumSize: const Size(48, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textStyle,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Deliberately a step more legible than the page's decorative muted text
    // (alpha 0.6): this is required disclosure a reviewer has to be able to
    // read, not a caption.
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.75);
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      height: 1.45,
    );
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$planNames. $priceSummary '
          '$_billingSentence '
          'Your subscription renews automatically for the same period at the '
          'same price unless you turn off auto-renew at least 24 hours before '
          'the current period ends. $_manageSentence',
          style: bodyStyle,
        ),
        const SizedBox(height: AppConstants.spacing4),
        // Both links must be reachable from the purchase screen itself. Zero
        // horizontal padding so "Terms of Use" starts on the same left edge as
        // the paragraph above it; minimumSize still holds the 44pt tap target,
        // and the separator carries the gap between them.
        // Spacing rather than a separator glyph: on a narrow screen the two
        // links wrap onto separate lines, and a middle "·" would be left
        // dangling at the end of the first one.
        Wrap(
          spacing: AppConstants.spacing24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Terms of use',
              child: TextButton(
                onPressed: () => _openUrl(AppConstants.termsOfServiceUrl),
                style: _linkButtonStyle(linkStyle),
                child: const Text('Terms of Use'),
              ),
            ),
            Semantics(
              button: true,
              label: 'Privacy policy',
              child: TextButton(
                onPressed: () => _openUrl(AppConstants.privacyPolicyUrl),
                style: _linkButtonStyle(linkStyle),
                child: const Text('Privacy Policy'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
