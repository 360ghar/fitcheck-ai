import 'dart:convert';
import 'dart:io';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/outfits/controllers/outfit_builder_controller.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_builder_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_collections_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_detail_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_edit_page.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/batch_extraction_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/item_add_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_extraction_progress_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_image_selector_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_item_review_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_add_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_detail_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_edit_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_stats_page.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/ai_extraction_widget.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/manual_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _item = ItemModel(
  id: 'item',
  userId: 'user',
  name: 'Oversized cotton shirt',
  category: Category.tops,
  condition: domain.Condition.clean,
);
const _outfit = OutfitModel(
  id: 'outfit',
  userId: 'user',
  name: 'Weekend city essentials',
  itemIds: [],
);

class _Network extends NetworkService {
  @override
  // Skip platform listeners in layout fixtures.
  // ignore: must_call_super
  void onInit() {}
}

class _Wardrobe extends WardrobeController {
  @override
  // Layout fixtures deliberately skip network and platform initialization.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> refreshItemById(String id) async {}
}

class _Outfits extends OutfitListController {
  @override
  // Layout fixtures deliberately skip network and platform initialization.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> refreshOutfitById(String id) async {}
  @override
  Future<OutfitModel?> fetchOutfitById(String id) async => _outfit;
}

class _Builder extends OutfitBuilderController {
  @override
  // Layout fixtures deliberately skip network and platform initialization.
  // ignore: must_call_super
  void onInit() {}
}

class _Batch extends BatchExtractionController {
  @override
  // Layout fixtures deliberately skip network and platform initialization.
  // ignore: must_call_super
  void onInit() {}
}

class _Collections extends OutfitRepository {
  @override
  Future<List<Map<String, dynamic>>> getCollections() async => [
    {
      'id': 'collection',
      'name': 'A very long summer collection name',
      'outfit_count': 100,
      'is_favorite': true,
    },
  ];
}

class _ShareRepository extends OutfitRepository {
  @override
  Future<String> shareOutfit(String id) async =>
      'https://fitcheckaiapp.com/outfits/$id';
}

class _Statistics extends ItemRepository {
  @override
  Future<Map<String, dynamic>> getStatistics() async => {
    'total_items': 1234,
    'total_value': 123456.75,
    'items_by_category': {'tops': 1200, 'accessories': 34},
    'most_worn_items': [
      {'name': 'Oversized cotton shirt', 'times_worn': 100},
    ],
  };
}

void main() {
  late File photo;
  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('wardrobe_layout');
    addTearDown(() => directory.deleteSync(recursive: true));
    photo = await File('${directory.path}/photo.png').writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a6WQAAAAASUVORK5CYII=',
      ),
    );
  });
  setUp(() {
    Get.put<NetworkService>(_Network());
    Get.put<WardrobeController>(_Wardrobe()..items.add(_item));
    Get.put<OutfitListController>(_Outfits()..outfits.add(_outfit));
    Get.put<OutfitBuilderController>(
      _Builder()
        ..availableItems.add(_item)
        ..addItem(_item),
    );
    Get.put<ItemAddController>(
      ItemAddController()
        ..generatedItems.add(
          const DetectedItemDataWithImage(
            tempId: 'generated',
            category: 'tops',
            name: 'Oversized cotton shirt',
            confidence: 0.9,
            personId: 'person',
            personLabel: 'Person with a long name',
            generationError: 'Could not create photo',
          ),
        ),
    );
    Get.put<BatchExtractionController>(
      _Batch()
        ..selectedImages.add(BatchImage(id: 'source', filePath: photo.path))
        ..extractedItems.add(
          const BatchExtractedItem(
            id: 'extracted',
            sourceImageId: 'source',
            name: 'Oversized cotton shirt',
            category: Category.tops,
            personId: 'person',
            personLabel: 'Person with a long name',
            status: BatchItemStatus.failed,
            error: 'Photo generation failed. You can still save this item.',
            confidence: 0.9,
          ),
        )
        ..jobStatus.value = BatchJobStatus.extracting,
    );
  });
  tearDown(Get.reset);

  testWidgets('share failure retains outfit page and supplies iPad origin', (
    tester,
  ) async {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    Map<dynamic, dynamic>? shareArguments;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          shareArguments = call.arguments as Map<dynamic, dynamic>;
          throw PlatformException(code: 'share_failed');
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('Closet route'))),
    );
    Get.to(
      () =>
          OutfitDetailPage(outfitId: 'outfit', repository: _ShareRepository()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(shareArguments?['originWidth'], greaterThan(0));
    expect(shareArguments?['originHeight'], greaterThan(0));
    expect(find.byType(OutfitDetailPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  for (final dark in [false, true]) {
    for (final name in [
      'add',
      'manual',
      'item edit',
      'item detail',
      'outfit edit',
      'outfit detail',
      'outfit builder',
      'collections',
      'batch selector',
      'social import',
      'stats',
      'batch progress',
      'batch review',
      'AI review',
    ]) {
      testWidgets('$name at 320px / 200% text / dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final page = switch (name) {
          'add' => const ItemAddPage(),
          'manual' => const ManualEntryForm(),
          'item edit' => const ItemEditPage(itemId: 'item'),
          'item detail' => const ItemDetailPage(itemId: 'item'),
          'outfit edit' => const OutfitEditPage(outfitId: 'outfit'),
          'outfit detail' => const OutfitDetailPage(outfitId: 'outfit'),
          'outfit builder' => const OutfitBuilderPage(),
          'collections' => OutfitCollectionsPage(repository: _Collections()),
          'batch selector' => const BatchImageSelectorPage(),
          'social import' => const BatchImageSelectorPage(
            launchInSocialMode: true,
          ),
          'stats' => WardrobeStatsPage(repository: _Statistics()),
          'batch progress' => const BatchExtractionProgressPage(),
          'batch review' => const BatchItemReviewPage(),
          _ => Scaffold(
            body: AIExtractionWidget(
              imageFile: photo,
              extractionResult: null,
              isProcessing: false,
              onRetake: () {},
              onSaveExtracted: (_) {},
              onSaveGenerated: () {},
              onManualEntry: () {},
            ),
          ),
        };
        await tester.pumpWidget(
          GetMaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: page,
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        if (name == 'outfit builder' || name == 'collections') {
          final icon = tester.widget<Icon>(
            find.byIcon(
              name == 'outfit builder' ? Icons.check : Icons.favorite,
            ),
          );
          final scheme = Theme.of(
            tester.element(find.byWidget(page)),
          ).colorScheme;
          final background = name == 'outfit builder'
              ? scheme.primary
              : Color.alphaBlend(
                  scheme.secondary.withValues(alpha: 0.9),
                  scheme.surface,
                );
          final foregroundLuminance = icon.color!.computeLuminance();
          final backgroundLuminance = background.computeLuminance();
          final lighter = foregroundLuminance > backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          final darker = foregroundLuminance < backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          expect(
            (lighter + 0.05) / (darker + 0.05),
            greaterThanOrEqualTo(3),
            reason:
                'Selection and favourite icons must remain visible on brand fills.',
          );
        }
        for (var scroll = 0; scroll < 12; scroll++) {
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isEmpty) break;
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull, reason: 'scroll=$scroll');
        }
        if (name == 'AI review') await tester.pumpAndSettle();
        // Adding the first photo must handle nullable API image metadata.
        if (name == 'item edit' || name == 'outfit edit') {
          final dynamic state = tester.state(find.byWidget(page));
          state.newImages.add(photo);
          await tester.pump();
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 4000),
          );
          await tester.pump();
          expect(find.byTooltip('Remove new photo'), findsOneWidget);
        }
        if (name == 'batch review') {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 2000),
          );
          await tester.pump();
          await Scrollable.ensureVisible(
            tester.element(find.text('Exclude')),
            alignment: 0.5,
          );
          await tester.pump();
          await tester.tap(find.text('Exclude'));
          await tester.pump();
          expect(Get.find<BatchExtractionController>().selectedItemCount, 0);
          await Scrollable.ensureVisible(
            tester.element(find.text('Include')),
            alignment: 0.5,
          );
          await tester.pump();
          await tester.tap(find.text('Include'));
          await tester.pump();
          expect(Get.find<BatchExtractionController>().selectedItemCount, 1);
        }
      });
    }
  }
}
