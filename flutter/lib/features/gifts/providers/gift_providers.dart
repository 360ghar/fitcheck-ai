import '../../../core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env_config.dart';
import '../../../core/state/paged_state.dart' show BusyIds;
import '../../../core/utils/error_handler.dart';
import '../models/gift_models.dart';
import '../repositories/gift_repository.dart';

final giftRepositoryProvider = Provider<GiftRepository>(
  (ref) => GiftRepository(),
);

/// The gift summary: incoming gifts and free invitations. Null when gift
/// vouchers are off in this build. Alive for the session: the home banner
/// and the gift page read it.
final giftProvider = AsyncNotifierProvider<GiftNotifier, GiftDashboardSummary?>(
  GiftNotifier.new,
);

/// Busy markers: [GiftNotifier.createKey] or an incoming voucher id.
final giftBusyProvider = NotifierProvider<BusyIds, Set<String>>(BusyIds.new);

/// The summary to act on. A failed refresh returns null instead of the
/// previous summary: stale data could offer a gift that was already claimed
/// on another device. The home banner then falls back to referral.
GiftDashboardSummary? liveGiftSummary(AsyncValue<GiftDashboardSummary?> v) =>
    v.hasError ? null : v.value;

class GiftNotifier extends AsyncNotifier<GiftDashboardSummary?> {
  static const createKey = 'create';

  GiftRepository get _repository => ref.read(giftRepositoryProvider);

  @override
  Future<GiftDashboardSummary?> build() {
    // A second account must not see the first one's gift inbox.
    ref.watch(sessionUserIdProvider);
    return _load();
  }

  Future<GiftDashboardSummary?> _load() async {
    if (!EnvConfig.giftVouchersEnabled) return null;
    return _repository.getSummary();
  }

  /// Reloads and keeps the current summary on screen while it runs.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Creates a free named invitation. [clientRequestId] makes a retry after
  /// a lost response replay the same gift instead of creating a second one.
  /// Returns null when busy or on failure (the error is shown).
  Future<GiftVoucher?> createComplimentary({
    required int durationMonths,
    required String fromName,
    required String toName,
    required String recipientEmail,
    required String clientRequestId,
    String? message,
    GiftOccasion? occasion,
    String? occasionGreeting,
  }) {
    return ref.read(giftBusyProvider.notifier).run<GiftVoucher?>(
      createKey,
      () async {
        try {
          final voucher = await _repository.createComplimentary(
            durationMonths: durationMonths,
            fromName: fromName,
            toName: toName,
            recipientEmail: recipientEmail,
            clientRequestId: clientRequestId,
            message: message,
            occasion: occasion,
            occasionGreeting: occasionGreeting,
          );
          await refresh();
          return voucher;
        } catch (e, stackTrace) {
          ErrorHandler.showError(
            e,
            title: 'Could not create the gift',
            stackTrace: stackTrace,
          );
          return null;
        }
      },
    );
  }

  /// Claims a gift assigned to the signed-in, verified account. Returns null
  /// when busy or on failure (the error is shown).
  Future<GiftClaimResult?> claimIncoming(String voucherId) {
    return ref.read(giftBusyProvider.notifier).run<GiftClaimResult?>(
      voucherId,
      () async {
        try {
          final result = await _repository.claimAssigned(voucherId);
          await refresh();
          return result;
        } catch (e, stackTrace) {
          ErrorHandler.showError(
            e,
            title: 'Could not claim the gift',
            stackTrace: stackTrace,
          );
          return null;
        }
      },
    );
  }
}
