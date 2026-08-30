import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../../../core/services/referral_redemption_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Outcome of a referral redemption attempt.
///
/// The legacy [UserInitializationService.redeemReferralCode] bool API cannot
/// distinguish "backend said no" (invalid/expired/revoked code — retrying can
/// never succeed) from "network hiccup" (retrying later will). Callers that
/// need that distinction use [redeemReferralCodeWithResult].
enum ReferralRedemptionStatus { success, definitiveRejection, transientFailure }

class ReferralRedemptionResult {
  final ReferralRedemptionStatus status;
  final Object? error;

  const ReferralRedemptionResult(this.status, {this.error});

  bool get isSuccess => status == ReferralRedemptionStatus.success;
}

/// Shared initialization logic for user setup that was previously duplicated
/// across [AuthController] and the subscription feature.
///
/// Extracted as part of FL4 to break the cross-feature import from
/// auth -> subscription: the subscription repository is injected behind the
/// core [ReferralRedemptionService] interface, so auth keeps no compile-time
/// dependency on the subscription feature.
class UserInitializationService extends GetxService {
  final ReferralRedemptionService _subscriptionRepo;

  UserInitializationService({
    required ReferralRedemptionService subscriptionRepo,
  }) : _subscriptionRepo = subscriptionRepo;

  /// Redeem a referral code, returning whether it succeeded so callers can
  /// decide whether to keep the pending code for a later retry. Never throws:
  /// a failure must not block the caller's flow (e.g. registration).
  Future<bool> redeemReferralCode(String code) async {
    final result = await redeemReferralCodeWithResult(code);
    return result.isSuccess;
  }

  /// Redeem a referral code with a typed outcome: [ReferralRedemptionStatus.definitiveRejection]
  /// means the backend definitively rejected the code (HTTP 400/403/404/410 —
  /// invalid, revoked, or expired), so retrying is pointless. Never throws.
  Future<ReferralRedemptionResult> redeemReferralCodeWithResult(
    String code,
  ) async {
    try {
      final redeemed = await _subscriptionRepo.redeemReferralCode(code);
      if (!redeemed) {
        return const ReferralRedemptionResult(
          ReferralRedemptionStatus.definitiveRejection,
        );
      }
      ErrorHandler.showInfo(
        'You and your friend both get 1 month of Pro free!',
        title: 'Referral Applied!',
      );
      return const ReferralRedemptionResult(ReferralRedemptionStatus.success);
    } on DioException catch (e) {
      debugPrint('Failed to redeem referral code: $e');
      final statusCode = e.response?.statusCode;
      if (statusCode != null &&
          const {400, 403, 404, 410}.contains(statusCode)) {
        return ReferralRedemptionResult(
          ReferralRedemptionStatus.definitiveRejection,
          error: e,
        );
      }
      return ReferralRedemptionResult(
        ReferralRedemptionStatus.transientFailure,
        error: e,
      );
    } on AppException catch (e) {
      debugPrint('Failed to redeem referral code: $e');
      final statusCode = e.statusCode;
      if (statusCode != null &&
          const {400, 403, 404, 410}.contains(statusCode)) {
        return ReferralRedemptionResult(
          ReferralRedemptionStatus.definitiveRejection,
          error: e,
        );
      }
      return ReferralRedemptionResult(
        ReferralRedemptionStatus.transientFailure,
        error: e,
      );
    } catch (e) {
      debugPrint('Failed to redeem referral code: $e');
      return ReferralRedemptionResult(
        ReferralRedemptionStatus.transientFailure,
        error: e,
      );
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
