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

  /// Retrieve and clear the pending referral code.
  Future<String?> getAndClearPendingReferralCode() async {
    final code = await _persistence.getString(_pendingReferralKey);
    if (code != null) {
      await _persistence.remove(_pendingReferralKey);
    }
    return code;
  }

  /// Redeem a referral code after registration, swallowing errors.
  Future<void> redeemReferralCode(String code) async {
    await _userInitService.redeemReferralCode(code);
  }

  /// Handle OAuth callback: sync profile and redeem any pending referral code.
  Future<void> handleOAuthCallback() async {
    // Sync user profile with backend
    await _userInitService.syncOAuthProfile();

    // Check for pending referral code from before OAuth redirect
    final pendingCode = await getAndClearPendingReferralCode();
    if (pendingCode != null && pendingCode.isNotEmpty) {
      await redeemReferralCode(pendingCode);
    }
  }
}
