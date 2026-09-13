import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/batch_extraction_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/social_import_models.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_image_selector_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// In-memory [PersistenceService] so the controller's social-import
/// persistence paths never touch real SharedPreferences in tests.
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

Future<void> _pumpSocialSelector(
  WidgetTester tester,
  BatchExtractionController controller,
) async {
  controller.inputMode.value = BatchInputMode.social;
  await tester.pumpWidget(
    GetMaterialApp(
      getPages: [
        GetPage(
          name: Routes.wardrobe,
          page: () =>
              const Scaffold(body: Center(child: Text('wardrobe-tab'))),
        ),
      ],
      home: const BatchImageSelectorPage(),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  group('BatchImageSelectorPage terminal social import states', () {
    testWidgets('completed job shows the success card, not the processing UI', (
      tester,
    ) async {
      Get.put<PersistenceService>(_InMemoryPersistenceService());
      final controller = BatchExtractionController();
      Get.put(controller);
      controller.socialJob.value = terminalJob(SocialImportJobStatus.completed);

      await _pumpSocialSelector(tester, controller);

      expect(
        find.text('Import Complete'),
        findsOneWidget,
        reason: 'a completed job must show closure UI instead of hanging on '
            'the processing view forever',
      );
      expect(find.text('Processing Photos'), findsNothing);
      expect(find.text('Cancel Import'), findsNothing);
      expect(find.text('View Wardrobe'), findsOneWidget);
    });

    testWidgets(
      'View Wardrobe navigates to the wardrobe route and resets state',
      (tester) async {
        Get.put<PersistenceService>(_InMemoryPersistenceService());
        final controller = BatchExtractionController();
        Get.put(controller);
        controller.socialJob.value = terminalJob(
          SocialImportJobStatus.completed,
        );

        await _pumpSocialSelector(tester, controller);

        await tester.tap(find.text('View Wardrobe'));
        await tester.pumpAndSettle();

        expect(find.text('wardrobe-tab'), findsOneWidget);
        expect(
          controller.socialJob.value,
          isNull,
          reason: 'the completed job must be cleared so reopening the '
              'selector does not show a stale terminal card',
        );
      },
    );

    testWidgets('failed job shows the error message and a Start Over action', (
      tester,
    ) async {
      Get.put<PersistenceService>(_InMemoryPersistenceService());
      final controller = BatchExtractionController();
      Get.put(controller);
      controller.socialJob.value = terminalJob(
        SocialImportJobStatus.failed,
        errorMessage: 'The profile could not be imported.',
      );

      await _pumpSocialSelector(tester, controller);

      expect(find.text('Import Failed'), findsOneWidget);
      expect(find.text('The profile could not be imported.'), findsOneWidget);
      expect(find.text('Processing Photos'), findsNothing);
      expect(find.text('Cancel Import'), findsNothing);

      await tester.tap(find.text('Start Over'));
      await tester.pumpAndSettle();

      expect(
        controller.socialJob.value,
        isNull,
        reason: 'Start Over must reset the social import state',
      );
      expect(
        find.text('Import from Social'),
        findsWidgets,
        reason: 'after Start Over the selector should be back on the '
            'input form, ready for a new attempt',
      );
    });

    testWidgets('cancelled job shows an ended card with Start Over', (
      tester,
    ) async {
      Get.put<PersistenceService>(_InMemoryPersistenceService());
      final controller = BatchExtractionController();
      Get.put(controller);
      controller.socialJob.value = terminalJob(
        SocialImportJobStatus.cancelled,
      );

      await _pumpSocialSelector(tester, controller);

      expect(find.text('Import Cancelled'), findsOneWidget);
      expect(find.text('Cancel Import'), findsNothing);
      expect(find.text('Start Over'), findsOneWidget);
    });
  });
}
