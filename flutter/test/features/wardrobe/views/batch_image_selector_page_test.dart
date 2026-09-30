import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/features/wardrobe/models/social_import_models.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/batch_extraction_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_image_selector_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// In-memory [PersistenceService]: no SharedPreferences in tests.
class _InMemoryPersistenceService extends PersistenceService {
  final Map<String, Object> _store = {};

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }
}

SocialImportJobData terminalJob(
  SocialImportJobStatus status, {
  String? errorMessage,
}) => SocialImportJobData(
  id: 'job-1',
  status: status,
  platform: SocialPlatform.instagram,
  sourceUrl: 'https://instagram.com/user',
  normalizedUrl: 'https://instagram.com/user',
  totalPhotos: 4,
  discoveredPhotos: 4,
  processedPhotos: 4,
  approvedPhotos: 3,
  rejectedPhotos: 1,
  failedPhotos: 0,
  authRequired: false,
  discoveryCompleted: true,
  queuedCount: 0,
  errorMessage: errorMessage,
);

/// Pumps the selector in social mode with [job], and returns the container.
/// The container keeps the session alive after the page leaves, so tests can
/// read its state.
Future<ProviderContainer> _pumpSocialSelector(
  WidgetTester tester,
  SocialImportJobData job,
) async {
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      persistenceServiceProvider.overrideWithValue(
        _InMemoryPersistenceService(),
      ),
      socialCallbackLinksProvider.overrideWithValue(const Stream<Uri>.empty()),
    ],
  );
  addTearDown(container.dispose);
  container.listen(batchExtractionProvider, (_, _) {});
  container
      .read(batchExtractionProvider.notifier)
      .debugSetState(
        BatchState(
          mode: BatchInputMode.social,
          socialJobId: job.id,
          socialJob: job,
        ),
      );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const BatchImageSelectorPage(),
              ),
              GoRoute(
                path: Routes.wardrobe,
                builder: (_, _) =>
                    const Scaffold(body: Center(child: Text('wardrobe-tab'))),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {

  group('BatchImageSelectorPage terminal social import states', () {
    testWidgets(
      'completed job shows the success state, not the processing UI',
      (tester) async {
        await _pumpSocialSelector(
          tester,
          terminalJob(SocialImportJobStatus.completed),
        );

        expect(find.text('Import complete'), findsOneWidget);
        expect(find.text('Processing photos'), findsNothing);
        expect(find.text('Cancel import'), findsNothing);
        expect(find.text('View closet'), findsOneWidget);
      },
    );

    testWidgets('View closet navigates to the closet route and resets state', (
      tester,
    ) async {
      final container = await _pumpSocialSelector(
        tester,
        terminalJob(SocialImportJobStatus.completed),
      );

      await tester.tap(find.text('View closet'));
      await tester.pumpAndSettle();

      expect(find.text('wardrobe-tab'), findsOneWidget);
      expect(
        container.read(batchExtractionProvider).socialJob,
        isNull,
        reason: 'reopening the selector must not show a stale terminal state',
      );
    });

    testWidgets('failed job shows the error message and a Start over action', (
      tester,
    ) async {
      final container = await _pumpSocialSelector(
        tester,
        terminalJob(
          SocialImportJobStatus.failed,
          errorMessage: 'The profile could not be imported.',
        ),
      );

      expect(find.text('Import failed'), findsOneWidget);
      expect(find.text('The profile could not be imported.'), findsOneWidget);
      expect(find.text('Processing photos'), findsNothing);
      expect(find.text('Cancel import'), findsNothing);

      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();

      expect(container.read(batchExtractionProvider).socialJob, isNull);
      expect(
        find.text('Import from a profile'),
        findsWidgets,
        reason: 'after Start over the input form is back',
      );
    });

    testWidgets('cancelled job shows an ended state with Start over', (
      tester,
    ) async {
      await _pumpSocialSelector(
        tester,
        terminalJob(SocialImportJobStatus.cancelled),
      );

      expect(find.text('Import cancelled'), findsOneWidget);
      expect(find.text('Cancel import'), findsNothing);
      expect(find.text('Start over'), findsOneWidget);
    });
  });
}
