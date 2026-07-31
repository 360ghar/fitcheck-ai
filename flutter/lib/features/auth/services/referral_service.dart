import 'package:get/get.dart';
import '../../../core/services/persistence_service.dart';
import 'user_initialization_service.dart';

/// Handles referral code operations — storing pending codes for OAuth flows
/// and redeeming them after registration.
///
/// Extracted from [AuthController] as part of FL7.
class ReferralService extends GetxService {
  static const String _pendingReferralKey = 'pending_referral_code';

  final PersistenceService _persistence;
  final UserInitializationService _userInitService;

  ReferralService({
    required PersistenceService persistence,
    required UserInitializationService userInitService,
  }) : _persistence = persistence,
       _userInitService = userInitService;

  /// Store a pending referral code (e.g. before OAuth redirect).
  Future<void> setPendingReferralCode(String code) async {
    await _persistence.setString(_pendingReferralKey, code);
  }

  /// Retrieve the pending referral code without removing it. The code is
  /// only cleared once redemption succeeds (see [handleOAuthCallback]), so a
  /// transient redemption failure does not permanently lose it.
  Future<String?> getPendingReferralCode() async {
    return _persistence.getString(_pendingReferralKey);
  }

  /// Redeem a referral code after registration, reporting success.
  Future<bool> redeemReferralCode(String code) async {
    return _userInitService.redeemReferralCode(code);
  }

  /// Handle OAuth callback: sync profile and redeem any pending referral code.
  Future<void> handleOAuthCallback() async {
    // Sync user profile with backend
    await _userInitService.syncOAuthProfile();

    // Check for pending referral code from before OAuth redirect; clear it
    // only after redemption succeeds so a failure can retry later.
    final pendingCode = await getPendingReferralCode();
    if (pendingCode != null && pendingCode.isNotEmpty) {
      final redeemed = await redeemReferralCode(pendingCode);
      if (redeemed) {
        await _persistence.remove(_pendingReferralKey);
      }
    }
  }
}
