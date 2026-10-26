import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../core/widgets/app_ui.dart';

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
    required this.planNames,
  });

  /// e.g. "Plus is $10/month or $100/year; Pro is $20/month or $200/year."
  final String priceSummary;

  /// True on iOS (StoreKit), false on Android (Play Billing).
  final bool isApple;

  /// Opening clause naming what is actually purchasable on this screen — a
  /// Plus subscriber is only offered Pro.
  final String planNames;

  String _billingSentence(AppLocalizations l10n) => isApple
      ? l10n.billingDisclosureAppleBilling
      : l10n.billingDisclosureGoogleBilling;

  String _manageSentence(AppLocalizations l10n) => isApple
      ? l10n.billingDisclosureAppleManage
      : l10n.billingDisclosureGoogleManage;

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
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    // textSecondary rather than the muted caption tone: this is required
    // disclosure a reviewer has to be able to read. Both pass WCAG AA.
    final bodyStyle = text.bodySmall?.copyWith(
      color: tokens.textSecondary,
      height: 1.45,
    );
    final linkStyle = text.bodySmall?.copyWith(
      color: tokens.stock.accent,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$planNames. $priceSummary '
          '${_billingSentence(l10n)} '
          '${l10n.billingDisclosureRenewalTerms} '
          '${_manageSentence(l10n)}',
          style: bodyStyle,
        ),
        const SizedBox(height: AppConstants.spacing4),
        // Both links must be reachable from the purchase screen itself. Zero
        // horizontal padding so "Terms of use" starts on the same left edge as
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
              label: l10n.paywallTerms,
              child: TextButton(
                onPressed: () => _openUrl(AppConstants.termsOfServiceUrl),
                style: _linkButtonStyle(linkStyle),
                child: Text(l10n.paywallTerms),
              ),
            ),
            Semantics(
              button: true,
              label: l10n.paywallPrivacy,
              child: TextButton(
                onPressed: () => _openUrl(AppConstants.privacyPolicyUrl),
                style: _linkButtonStyle(linkStyle),
                child: Text(l10n.paywallPrivacy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
