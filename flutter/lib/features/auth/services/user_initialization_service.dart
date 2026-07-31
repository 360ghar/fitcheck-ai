import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../../../core/services/referral_redemption_service.dart';
import '../../../core/utils/error_handler.dart';

/// Shared initialization logic for user setup that was previously duplicated
/// across [AuthController] and the subscription feature.
///
/// Extracted as part of FL4 to break the cross-feature import from
/// auth -> subscription: the subscription repository is injected behind the
/// core [ReferralRedemptionService] interface, so auth keeps no compile-time
/// dependency on the subscription feature.
class UserInitializationService extends GetxService {
  final ReferralRedemptionService _subscriptionRepo;

  UserInitializationService({required ReferralRedemptionService subscriptionRepo})
      : _subscriptionRepo = subscriptionRepo;

  /// Redeem a referral code, returning whether it succeeded so callers can
  /// decide whether to keep the pending code for a later retry. Never throws:
  /// a failure must not block the caller's flow (e.g. registration).
  Future<bool> redeemReferralCode(String code) async {
    try {
      await _subscriptionRepo.redeemReferralCode(code);
      ErrorHandler.showInfo(
        'You and your friend both get 1 month of Pro free!',
        title: 'Referral Applied!',
      );
      return true;
    } catch (e) {
      debugPrint('Failed to redeem referral code: $e');
      return false;
    }
  }

  /// Sync the OAuth profile with the backend, swallowing errors so the login
  /// flow never fails on a transient profile sync failure.
  Future<void> syncOAuthProfile() async {
    try {
      await AuthRepository().syncOAuthProfile();
    } catch (e) {
      debugPrint('OAuth sync failed: $e');
      // Non-fatal - continue with login
    }
  }
}
