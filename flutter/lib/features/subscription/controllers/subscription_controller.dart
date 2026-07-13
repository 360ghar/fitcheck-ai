import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../core/config/env_config.dart';
import '../../../core/utils/error_handler.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription_model.dart';

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
  final RxString error = ''.obs;

  // Computed properties
  bool get isPro => subscription.value?.planType != PlanType.free;
  bool get isCancelled => subscription.value?.cancelAtPeriodEnd ?? false;

  /// Whether monetization CTAs (paywall, Stripe checkout, pricing) may render.
  /// OFF on iOS for v1 (App Store Guideline 3.1.1 anti-steering).
  bool get showPaywall => EnvConfig.paywallEnabled;

  String get planName {
    switch (subscription.value?.planType) {
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
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _repository.getSubscription();
      subscription.value = data.subscription;
      usage.value = data.usage;
    } catch (e, stackTrace) {
      error.value = e.toString();
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch usage only
  Future<void> fetchUsage() async {
    try {
      usage.value = await _repository.getUsage();
    } catch (e, stackTrace) {
      error.value = e.toString();
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Fetch available plans
  Future<void> fetchPlans() async {
    try {
      final result = await _repository.getPlans();
      plans.assignAll(result);
    } catch (e, stackTrace) {
      error.value = e.toString();
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Fetch referral code
  Future<void> fetchReferralCode() async {
    try {
      referralCode.value = await _repository.getReferralCode();
    } catch (e) {
      // Referral code might not exist yet - not reported, this is expected
      // for new users and isn't a real error.
    }
  }

  /// Fetch referral stats
  Future<void> fetchReferralStats() async {
    try {
      referralStats.value = await _repository.getReferralStats();
    } catch (e, stackTrace) {
      error.value = e.toString();
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
      final url = Uri.parse(session.checkoutUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        error.value = 'Could not open checkout page';
      }
    } catch (e, stackTrace) {
      error.value = e.toString();
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
      Get.snackbar(
        'Success',
        'Subscription cancelled. You\'ll retain access until period end.',
      );
    } catch (e, stackTrace) {
      error.value = e.toString();
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to cancel subscription');
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy referral link to clipboard
  Future<void> copyReferralLink() async {
    final code = referralCode.value;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code.shareUrl));
    Get.snackbar('Copied', 'Referral link copied to clipboard');
  }

  /// Share referral link
  Future<void> shareReferralLink() async {
    final code = referralCode.value;
    if (code == null) return;
    await Share.share(
      'Join FitCheck AI and get 1 month of Pro free! ${code.shareUrl}',
      subject: 'Try FitCheck AI',
    );
  }
}
