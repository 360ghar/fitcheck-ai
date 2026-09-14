import 'dart:async';

import 'package:fitcheck_ai/core/services/analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class FailingPosthog implements Posthog {
  Future<void> Function() setupAction = () async =>
      throw StateError('setup failed');
  int captures = 0;

  @override
  Future<void> setup(PostHogConfig config) => setupAction();
  @override
  Future<void> capture({
    required String eventName,
    Map<String, Object>? properties,
  }) {
    captures++;
    return Future.error(StateError('capture failed'));
  }

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  }) => throw StateError('identify failed');
  int resets = 0;
  @override
  Future<void> reset() {
    resets++;
    return Future.error(StateError('reset failed'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'setup failure and timeout resolve without replacing error handlers',
    () async {
      final originalHandler = FlutterError.onError;
      final client = FailingPosthog();
      final service = AnalyticsService(posthog: client);
      await service.init(apiKey: 'test-key');
      service.track('ignored');
      expect(client.captures, 0);
      client.setupAction = () => Completer<void>().future;
      await service.init(
        apiKey: 'test-key',
        setupTimeout: const Duration(milliseconds: 1),
      );
      expect(FlutterError.onError, same(originalHandler));
    },
  );

  test(
    'setup that outlives the init timeout enables analytics once it resolves',
    () async {
      final client = FailingPosthog();
      final setupCompleter = Completer<void>();
      client.setupAction = () => setupCompleter.future;
      final service = AnalyticsService(posthog: client);
      await service.init(
        apiKey: 'test-key',
        setupTimeout: const Duration(milliseconds: 1),
      );
      service.track('dropped-before-setup-resolves');
      expect(client.captures, 0);

      setupCompleter.complete();
      await Future<void>.delayed(Duration.zero);
      service.track('captured-after-late-setup');
      await Future<void>.delayed(Duration.zero);
      expect(client.captures, 1);
    },
  );

  test(
    'a reset requested before setup resolves is replayed once it succeeds',
    () async {
      final client = FailingPosthog();
      final setupCompleter = Completer<void>();
      client.setupAction = () => setupCompleter.future;
      final service = AnalyticsService(posthog: client);
      await service.init(
        apiKey: 'test-key',
        setupTimeout: const Duration(milliseconds: 1),
      );
      // A sign-out in this window must not leak the previous identity:
      // the reset is remembered, not dropped.
      service.reset();
      expect(client.resets, 0);

      setupCompleter.complete();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(client.resets, 1);
    },
  );

  test(
    'event and identify failures cannot escape into the app error handler',
    () async {
      final client = FailingPosthog()..setupAction = () async {};
      final service = AnalyticsService(posthog: client);
      await service.init(apiKey: 'test-key');
      service.track('test');
      service.screen('screen');
      service.identify('user');
      service.recordError(StateError('original error'), StackTrace.current);
      service.recordNonFatalError('test');
      service.reset();
      await Future<void>.delayed(Duration.zero);
      expect(client.captures, 4);
    },
  );
}
