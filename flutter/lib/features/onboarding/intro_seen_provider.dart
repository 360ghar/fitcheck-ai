import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/persistence_service.dart';

/// Whether this device has seen the intro pages. `main()` awaits [load]
/// before the first frame, so the router can read it synchronously.
final introSeenProvider = NotifierProvider<IntroSeenNotifier, bool>(
  IntroSeenNotifier.new,
);

class IntroSeenNotifier extends Notifier<bool> {
  static const storageKey = 'fitcheck_intro_seen';

  @override
  bool build() => false;

  Future<void> load() async {
    try {
      state = await PersistenceService.instance.getBool(storageKey) ?? false;
    } catch (_) {
      // Unreadable storage: show the intro again, which is harmless.
    }
  }

  Future<void> markSeen() async {
    state = true;
    try {
      await PersistenceService.instance.setBool(storageKey, true);
    } catch (_) {}
  }
}
