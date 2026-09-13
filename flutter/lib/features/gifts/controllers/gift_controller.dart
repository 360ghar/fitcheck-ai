import 'package:get/get.dart';

import '../../../core/config/env_config.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/frame_safe.dart';
import '../models/gift_models.dart';
import '../repositories/gift_repository.dart';

class GiftController extends GetxController {
  GiftController({GiftRepository? repository})
    : _repository = repository ?? GiftRepository();

  final GiftRepository _repository;

  final Rxn<GiftDashboardSummary> summary = Rxn<GiftDashboardSummary>();
  final RxBool isLoading = false.obs;
  final RxBool hasLoaded = false.obs;
  final RxBool isCreating = false.obs;
  final RxString claimingVoucherId = ''.obs;
  final RxString error = ''.obs;

  Future<void>? _loadFuture;

  GiftDashboardPriority? get priority {
    final current = summary.value;
    if (current == null) return null;
    if (current.incoming.isNotEmpty) return GiftDashboardPriority.incoming;
    if (current.allowances.any((item) => item.remainingCount > 0)) {
      return GiftDashboardPriority.complimentary;
    }
    return null;
  }

  GiftVoucher? get incomingGift => summary.value?.incoming.isNotEmpty == true
      ? summary.value!.incoming.first
      : null;

  GiftAllowance? get freeAllowance {
    for (final allowance
        in summary.value?.allowances ?? const <GiftAllowance>[]) {
      if (allowance.remainingCount > 0) return allowance;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    if (EnvConfig.giftVouchersEnabled) {
      load();
    }
  }

  Future<void> load({bool showLoader = true}) async {
    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final future = _load(showLoader: showLoader);
    _loadFuture = future;
    try {
      await future;
    } finally {
      _loadFuture = null;
    }
  }

  /// Fresh fetch that never joins an in-flight load. Mutations use this so
  /// the summary cannot stay stale when a load started before the write.
  Future<void> refreshAfterMutation() => _load(showLoader: false);

  Future<void> _load({required bool showLoader}) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    if (showLoader) isLoading.value = true;
    error.value = '';
    try {
      summary.value = await _repository.getSummary();
    } catch (exception) {
      // The dashboard must fall back to referral when the server-authoritative
      // gift priority cannot be refreshed. Keeping stale incoming data could
      // surface a gift that was already claimed on another device.
      summary.value = null;
      error.value = ErrorHandler.extractMessage(exception);
    } finally {
      hasLoaded.value = true;
      if (showLoader) isLoading.value = false;
    }
  }

  Future<GiftVoucher?> createComplimentary({
    required int durationMonths,
    required String fromName,
    required String toName,
    required String recipientEmail,
    required String clientRequestId,
    String? message,
  }) async {
    isCreating.value = true;
    error.value = '';
    try {
      final voucher = await _repository.createComplimentary(
        durationMonths: durationMonths,
        fromName: fromName,
        toName: toName,
        recipientEmail: recipientEmail,
        clientRequestId: clientRequestId,
        message: message,
      );
      await refreshAfterMutation();
      return voucher;
    } catch (exception) {
      error.value = ErrorHandler.extractMessage(exception);
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  Future<GiftClaimResult?> claimIncoming(String voucherId) async {
    claimingVoucherId.value = voucherId;
    error.value = '';
    try {
      final result = await _repository.claimAssigned(voucherId);
      await refreshAfterMutation();
      return result;
    } catch (exception) {
      error.value = ErrorHandler.extractMessage(exception);
      return null;
    } finally {
      // Clear only this claim's marker so a concurrent second claim is not
      // left with its button re-enabled mid-request.
      if (claimingVoucherId.value == voucherId) {
        claimingVoucherId.value = '';
      }
    }
  }
}
