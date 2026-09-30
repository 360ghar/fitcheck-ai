import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/supabase_service.dart';

/// Turns off Riverpod's automatic retry of failed providers. Screens show
/// the error with an explicit retry, and repositories retry transient
/// network failures themselves (RetryHelper).
Duration? noRetry(int retryCount, Object error) => null;

/// The app's single provider container.
///
/// `main` hands it to `UncontrolledProviderScope`, so widgets and code
/// outside the widget tree (network interceptors, services) read the same
/// provider instances. Widgets use `ref`; read this only where there is no
/// `ref`.
final appContainer = ProviderContainer(retry: noRetry);

/// The root navigator. Dialogs and sheets opened from code without a
/// [BuildContext] use its context.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Calls [onChange] with each new value of [notifier] until [ref] is
/// disposed.
void listenValue<T>(
  Ref ref,
  ValueListenable<T> notifier,
  void Function(T value) onChange,
) {
  void listener() => onChange(notifier.value);
  notifier.addListener(listener);
  ref.onDispose(() => notifier.removeListener(listener));
}

/// The signed-in user's id, or null. Per-user providers watch it, so the
/// next account never sees the previous account's data.
final sessionUserIdProvider = NotifierProvider<SessionUserId, String?>(
  SessionUserId.new,
);

class SessionUserId extends Notifier<String?> {
  @override
  String? build() {
    final user = SupabaseService.instance.currentUser;
    listenValue(ref, user, (u) => state = u?.id);
    return user.value?.id;
  }
}
