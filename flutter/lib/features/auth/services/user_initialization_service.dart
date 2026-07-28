import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../../../core/utils/error_handler.dart';

/// Shared initialization logic for user setup that was previously duplicated
/// across [AuthController] and the subscription feature.
///
/// Extracted as part of FL4 to break the cross-feature import from
/// auth -> subscription. SubscriptionRepository is injected via constructor
/// from InitialBinding; the import is kept for the type annotation only.
class UserInitializationService extends GetxService {
  final SubscriptionRepository _subscriptionRepo;

  UserInitializationService({required SubscriptionRepository subscriptionRepo})
      : _subscriptionRepo = subscriptionRepo;

  /// Redeem a referral code, swallowing errors so a failure never blocks the
  /// caller's flow (e.g. registration).
  Future<void> redeemReferralCode(String code) async {
    try {
      await _subscriptionRepo.redeemReferralCode(code);
      ErrorHandler.showInfo(
        'You and your friend both get 1 month of Pro free!',
        title: 'Referral Applied!',
      );
    } catch (e) {
      debugPrint('Failed to redeem referral code: $e');
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

  /// Merge the backend user profile into the in-memory [UserModel], returning
  /// a merged copy. Returns null when there is nothing to merge.
  UserModel? mergeBackendProfile(UserModel current, Map<String, dynamic> backendUser) {
    if (backendUser.isEmpty) return null;

    String? toNullableString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return current.copyWith(
      fullName: toNullableString(backendUser['full_name']) ?? current.fullName,
      avatarUrl: toNullableString(backendUser['avatar_url']) ?? current.avatarUrl,
      birthDate: toNullableString(backendUser['birth_date']),
      birthTime: toNullableString(backendUser['birth_time']),
      birthPlace: toNullableString(backendUser['birth_place']),
      createdAt: DateTime.tryParse(backendUser['created_at']?.toString() ?? '') ??
          current.createdAt,
      updatedAt: DateTime.tryParse(backendUser['updated_at']?.toString() ?? '') ??
          current.updatedAt,
    );
  }
}
