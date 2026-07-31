import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/env_config.dart';
import '../../../core/utils/error_handler.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription_model.dart';
import '../../../core/utils/frame_safe.dart';

/// Controller for subscription and referral state
class SubscriptionController extends GetxController {
  final SubscriptionRepository _repository = SubscriptionRepository();

  // Observable state
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final Rx<UsageLimitsModel?> usage = Rx<UsageLimitsModel?>(null);
  final Rx<ReferralCodeModel?> referralCode = Rx<ReferralCodeModel?>(null);
  final Rx<ReferralStatsModel?> referralStats = Rx<ReferralStatsModel?>(null);
  final RxList<PlanDetailsModel> plans = <PlanDetailsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool isLoadingReferral = false.obs;
  final RxString error = ''.obs;
  final RxString referralError = ''.obs;

  // Computed properties
  bool get isPro {
    final plan = subscription.value?.planType;
    // An unknown plan (fetch failed / still pending) must not be treated as
    // paid, or the page would show pricing and a "Cancel subscription"
    // section for a user whose entitlement is unknown.
    return plan != null && plan != PlanType.free;
  }
  bool get isCancelled => subscription.value?.cancelAtPeriodEnd ?? false;

  /// Whether a higher tier exists to upsell (Free and Plus users).
  ///
  /// Distinct from [isPro]: a Plus subscriber is entitled to every paid
  /// feature but can still move up to Pro, so an upgrade CTA gated on
  /// `!isPro` would leave them with no way to do it.
  bool get canUpgrade {
    final plan = subscription.value?.planType;
    if (plan == null) return false; // entitlement unknown (fetch failed / pending)
    return plan != PlanType.proMonthly && plan != PlanType.proYearly;
  }

  /// Whether monetization CTAs (paywall, Stripe checkout, pricing) may render.
  /// OFF on iOS for v1 (App Store Guideline 3.1.1 anti-steering).
  bool get showPaywall => EnvConfig.paywallEnabled;

  String get planName {
    switch (subscription.value?.planType) {
      case PlanType.plusMonthly:
        return 'Plus Monthly';
      case PlanType.plusYearly:
        return 'Plus Yearly';
      case PlanType.proMonthly:
        return 'Pro Monthly';
      case PlanType.proYearly:
        return 'Pro Yearly';
      case PlanType.free:
      default:
        return 'Free';
    }
  }

  double get extractionsPercentage {
    final u = usage.value;
    if (u == null || u.monthlyExtractionsLimit == 0) return 0;
    return (u.monthlyExtractions / u.monthlyExtractionsLimit).clamp(0.0, 1.0);
  }

  double get generationsPercentage {
    final u = usage.value;
    if (u == null || u.monthlyGenerationsLimit == 0) return 0;
    return (u.monthlyGenerations / u.monthlyGenerationsLimit).clamp(0.0, 1.0);
  }

  bool get isNearLimit =>
      extractionsPercentage > 0.8 || generationsPercentage > 0.8;

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
    fetchReferralCode();
    fetchReferralStats();
    fetchPlans();
  }

  /// Fetch subscription and usage data
  Future<void> fetchSubscription() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _repository.getSubscription();
      subscription.value = data.subscription;
      usage.value = data.usage;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch usage only
  Future<void> fetchUsage() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      usage.value = await _repository.getUsage();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Fetch available plans
  Future<void> fetchPlans() async {
    try {
      final result = await _repository.getPlans();
      plans.assignAll(result);
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Fetch referral code (API always creates one if missing)
  Future<void> fetchReferralCode() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoadingReferral.value = true;
    referralError.value = '';
    try {
      referralCode.value = await _repository.getReferralCode();
    } catch (e, stackTrace) {
      referralError.value = ErrorHandler.extractMessage(e);
      // Auth race (401 before token ready) is common on cold start — surface for retry
      ErrorHandler.reportError(e, referralError.value, stackTrace: stackTrace);
    } finally {
      isLoadingReferral.value = false;
    }
  }

  /// Fetch referral stats
  Future<void> fetchReferralStats() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      referralStats.value = await _repository.getReferralStats();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Start checkout for a plan
  Future<void> startCheckout(String planType) async {
    // Hard guard: never open external Stripe checkout when the paywall is
    // disabled (e.g. iOS v1). Prevents a stray call during App Review.
    if (!showPaywall) return;
    isCheckingOut.value = true;
    error.value = '';
    try {
      final session = await _repository.createCheckoutSession(
        planType: planType,
      );
      if (session.updated) {
        // Paid-plan changes are applied directly to the existing Stripe
        // subscription. Refresh local entitlements instead of opening a
        // checkout URL that the backend deliberately did not return.
        await fetchSubscription();
        return;
      }
      final checkoutUrl = session.checkoutUrl;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        error.value = 'Checkout did not return a payment link';
        return;
      }
      final url = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        error.value = 'Could not open checkout page';
      }
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    } finally {
      isCheckingOut.value = false;
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    isLoading.value = true;
    error.value = '';
    try {
      await _repository.cancelSubscription();
      await fetchSubscription();
      ErrorHandler.showSuccess('Subscription cancelled. You\'ll retain access until period end.', title: 'Success');
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError('Failed to cancel subscription', title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy referral link to clipboard
  Future<void> copyReferralLink() async {
    if (referralCode.value == null) {
      await fetchReferralCode();
    }
    final code = referralCode.value;
    if (code == null) {
      ErrorHandler.showError(referralError.value.isNotEmpty
            ? referralError.value
            : 'Could not load your referral link. Try again.', title: 'Error');
      return;
    }
    await Clipboard.setData(ClipboardData(text: code.shareUrl));
    ErrorHandler.showSuccess('Referral link copied to clipboard', title: 'Copied');
  }

  /// Share referral link via the platform share sheet.
  /// [sharePositionOrigin] is required on iPad for the popover.
  Future<void> shareReferralLink({Rect? sharePositionOrigin}) async {
    if (referralCode.value == null) {
      await fetchReferralCode();
    }
    final code = referralCode.value;
    if (code == null) {
      ErrorHandler.showError(referralError.value.isNotEmpty
            ? referralError.value
            : 'Could not load your referral link. Try again.', title: 'Error');
      return;
    }
    try {
      await Share.share(
        'Join FitCheck AI and get 1 month of Pro free! ${code.shareUrl}',
        subject: 'Try FitCheck AI',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      // Fall back to clipboard so the user still gets a working path
      try {
        await Clipboard.setData(ClipboardData(text: code.shareUrl));
        ErrorHandler.showError('Share sheet failed — link copied to clipboard instead.', title: 'Link copied');
      } catch (_) {
        ErrorHandler.showValidation('Please copy the link instead.', title: 'Share failed');
      }
    }
  }
}
