import 'dart:async';

import '../../../core/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/persistence_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(),
);

/// Hour-of-day behind the home greeting. A seam so golden screenshots pin
/// one bucket instead of failing whenever the wall clock rolls over.
final dashboardGreetingHourProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(_hourTickProvider).value?.hour ?? DateTime.now().hour,
);

/// Emits the current time, then re-emits at each hour boundary so a cached
/// greeting never goes stale while the app stays open.
final _hourTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final ticks = StreamController<DateTime>();
  Timer? timer;
  void tick() {
    final now = DateTime.now();
    ticks.add(now);
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    timer = Timer(nextHour.difference(now), tick);
  }

  ref.onDispose(() {
    timer?.cancel();
    unawaited(ticks.close());
  });
  tick();
  return ticks.stream;
});

/// Dashboard data plus the optional streak.
@immutable
class DashboardSnapshot {
  const DashboardSnapshot({required this.data, this.streak});

  final DashboardData data;

  /// Null when the gamification service is unavailable.
  final StreakData? streak;
}

/// Home and More both read this; it stays alive for the session.
final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardSnapshot>(
      DashboardNotifier.new,
    );

class DashboardNotifier extends AsyncNotifier<DashboardSnapshot> {
  @override
  Future<DashboardSnapshot> build() {
    ref.watch(sessionUserIdProvider);
    return _load();
  }

  Future<DashboardSnapshot> _load() async {
    final repository = ref.read(dashboardRepositoryProvider);
    // Both requests start together. The streak is optional: its failure
    // never fails the dashboard.
    final streak = repository.fetchStreak().then<StreakData?>(
      (s) => s,
      onError: (Object e, StackTrace stack) {
        ErrorHandler.reportError(e, 'Dashboard streak', stackTrace: stack);
        return null;
      },
    );
    final data = await repository.fetchDashboard();
    return DashboardSnapshot(data: data, streak: await streak);
  }

  /// Reloads and keeps the current data on screen while it runs. A failure
  /// keeps the old data and exposes the error for a banner.
  ///
  /// Riverpod carries the previous value into loading and error states set
  /// here, so the screen never blanks.
  Future<void> refresh() async {
    // A rebuild (not a manual state write) so Riverpod carries the previous
    // snapshot into loading and error states; the screen never blanks, and
    // a refresh started for one account cannot publish into another
    // account's session because build() re-reads the session id.
    ref.invalidateSelf();
  }
}

const _referralDismissedKey = 'referral_banner_dismissed_at';
const _dismissFor = Duration(days: 7);

/// True while the referral banner is dismissed (for a week after a tap).
final referralBannerDismissedProvider =
    AsyncNotifierProvider<ReferralBannerDismissed, bool>(
      ReferralBannerDismissed.new,
    );

class ReferralBannerDismissed extends AsyncNotifier<bool> {
  PersistenceService get _store => PersistenceService.instance;

  @override
  Future<bool> build() async {
    final at = await _store.getInt(_referralDismissedKey);
    if (at == null) return false;
    final since = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(at),
    );
    return since < _dismissFor;
  }

  Future<void> dismiss() async {
    state = const AsyncData(true);
    await _store.setInt(
      _referralDismissedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
