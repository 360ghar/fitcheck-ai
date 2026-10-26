import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The subscription the free month is attached to.
///
/// Fallback only: the live product id comes from `/plans`
/// (`StoreProductsModel.apple['pro_monthly']`), because product ids are never
/// hardcoded on the purchase path. This constant exists so the eligibility
/// probe still has something to ask about before `/plans` has answered — the
/// probe must never be blocked on a network call, or the headline flickers.
const String kProMonthlyProductId =
    'com.fitcheckaiapp.fitcheckai.pro.monthly';

/// What the App Store says about the user's right to the free month.
///
/// Three states, not two. `unknown` is not a synonym for `ineligible`: it means
/// the question could not be answered (Android, no StoreKit 2, an offline
/// store, a product that does not resolve). Both `ineligible` and `unknown`
/// render the honest non-trial copy, because promising a free month to someone
/// who will be charged immediately is a refund request and a one-star review.
enum TrialEligibility {
  /// `Product.SubscriptionInfo.isEligibleForIntroOffer` answered true.
  eligible,

  /// Answered false: the free month has already been used in this
  /// subscription group, or the user is not a new subscriber.
  ineligible,

  /// No answer, or the answer is not trustworthy on this platform.
  unknown;

  /// Only [eligible] may show trial copy.
  bool get canPromiseFreeMonth => this == TrialEligibility.eligible;
}

/// Reads introductory-offer eligibility from the native side.
///
/// The channel is registered in `ios/Runner/TrialEligibilityChannel.swift`
/// (iOS 15+, StoreKit 2). Every other platform, and every failure, resolves to
/// [TrialEligibility.unknown] rather than throwing: a paywall must never fail
/// to render because an eligibility probe did.
class TrialEligibilityService {
  const TrialEligibilityService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'fitcheck.ai/trial_eligibility';

  /// StoreKit 2 `Product.SubscriptionInfo.isEligibleForIntroOffer` lives here.
  /// Kept identical to the Swift `FlutterMethodChannel` name in
  /// `TrialEligibilityChannel.swift`.
  static const String methodIsEligible = 'isEligibleForIntroOffer';

  final MethodChannel _channel;

  /// True only on an iOS device build. Web, tests and Android answer locally
  /// instead of paying for a missing-plugin round trip.
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Asks the store, degrading to [TrialEligibility.unknown] for every
  /// non-answer. Never throws.
  Future<TrialEligibility> check(String productId) async {
    if (productId.isEmpty || !isSupported) return TrialEligibility.unknown;
    try {
      final answer = await _channel.invokeMethod<bool>(methodIsEligible, {
        'productId': productId,
      });
      if (answer == null) return TrialEligibility.unknown;
      return answer ? TrialEligibility.eligible : TrialEligibility.ineligible;
    } on MissingPluginException {
      // Android, web, or an iOS build older than the channel.
      return TrialEligibility.unknown;
    } on PlatformException {
      // StoreKit threw. Unknown, so the paywall keeps its safe copy rather
      // than silently withdrawing the offer from every user.
      return TrialEligibility.unknown;
    }
  }
}
