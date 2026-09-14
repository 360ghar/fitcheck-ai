import 'dart:convert';
import 'dart:io';

import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/services/wardrobe_sync_service.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/manual_entry_form.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_add_page.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/item_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class _Picker extends ImagePicker {
  _Picker(this.files);
  final List<File> files;

  @override
  Future<List<XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async => files.map((file) => XFile(file.path)).toList();
}

class _Repository extends ItemRepository {
  final List<String> uploaded = [];
  int creates = 0;
  String? failedPath;

  ItemModel get item => ItemModel(
    id: 'saved',
    userId: 'user-1',
    name: 'Shirt',
    category: Category.tops,
    condition: domain.Condition.clean,
    itemImages: uploaded.map((path) => ItemImage(id: path, url: path)).toList(),
  );

  @override
  Future<ItemModel> createItem(CreateItemRequest request) async {
    creates++;
    return item;
  }

  @override
  Future<ItemModel> getItem(String itemId) async => item;

  @override
  Future<List<ItemImage>> uploadImages(String itemId, List<File> images) async {
    if (images.any((image) => image.path == failedPath)) {
      throw StateError('Upload failed');
    }
    uploaded.addAll(images.map((image) => image.path));
    return images
        .map((image) => ItemImage(id: image.path, url: image.path))
        .toList();
  }
}

class _Sync extends WardrobeSyncService {
  ItemModel? saved;

  @override
  void addItem(ItemModel item) => saved = item;
}

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  for (final embedded in [false, true]) {
    testWidgets(
      'manual completion closes the add route once: embedded=$embedded',
      (tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: Text('Home route'))),
        );
        Get.to(() => const Scaffold(body: Text('Closet route')));
        await tester.pumpAndSettle();
        final result = Get.to<ItemModel>(() => const ItemAddPage());
        await tester.pumpAndSettle();
        if (embedded) {
          Get.find<ItemAddController>().proceedToManualEntry();
          await tester.pumpAndSettle();
          expect(find.byType(AppBar), findsOneWidget);
          tester.widget<ManualEntryForm>(find.byType(ManualEntryForm)).onSaved!(
            _Repository().item,
          );
        } else {
          await tester.ensureVisible(find.text('Enter Manually'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Enter Manually'));
          await tester.pumpAndSettle();
          expect(find.byType(ManualEntryForm), findsOneWidget);
          Get.back(result: _Repository().item);
        }
        await tester.pumpAndSettle();
        expect((await result)?.id, 'saved');
        expect(find.text('Closet route'), findsOneWidget);
        expect(find.text('Home route'), findsNothing);
      },
    );
  }

  testWidgets('embedded form reports one saved item through its callback', (
    tester,
  ) async {
    final repository = _Repository();
    Get.put<WardrobeSyncService>(_Sync());
    final saved = <ItemModel>[];
    await tester.pumpWidget(
      GetMaterialApp(
        home: ManualEntryForm(repository: repository, onSaved: saved.add),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Shirt');
    await tester.ensureVisible(find.text('Save Item'));
    await tester.tap(find.text('Save Item'));
    await tester.pumpAndSettle();
    expect(saved.single.id, 'saved');
    expect(repository.creates, 1);
    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  for (final (hasPrimary, hasFailure) in [
    (true, false),
    (false, false),
    (true, true),
  ]) {
    testWidgets(
      'saves available photos with primary=$hasPrimary failure=$hasFailure',
      (tester) async {
        late List<File> photos;
        await tester.runAsync(() async {
          final dir = await Directory.systemTemp.createTemp('manual_photos');
          addTearDown(() => dir.deleteSync(recursive: true));
          final bytes = base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a6WQAAAAASUVORK5CYII=',
          );
          photos = await Future.wait(
            List.generate(
              2,
              (index) => File('${dir.path}/$index.png').writeAsBytes(bytes),
            ),
          );
        });
        final repo = _Repository()
          ..failedPath = hasFailure ? photos.last.path : null;
        final sync = Get.put<WardrobeSyncService>(_Sync()) as _Sync;
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        Get.to(() => const Scaffold(body: Text('Add Item route')));
        await tester.pumpAndSettle();
        Get.to(
          () => ManualEntryForm(
            imageFile: hasPrimary ? photos.first : null,
            repository: repo,
            imagePicker: _Picker(hasPrimary ? [photos.last] : photos),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(hasPrimary ? 'Add More Photos' : 'Add Photo (Multiple)'),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'Shirt');
        await tester.ensureVisible(find.text('Save Item'));
        await tester.tap(find.text('Save Item'));
        await tester.pump();
        // Full settling consumes 3.3s, beyond the warning's 2s lifetime.
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Add Item route'), findsOneWidget);
        expect(repo.creates, 1);
        expect(
          repo.uploaded,
          photos
              .where((photo) => photo.path != repo.failedPath)
              .map((photo) => photo.path),
        );
        expect(sync.saved?.itemImages, hasLength(hasFailure ? 1 : 2));
        if (hasFailure) {
          expect(find.text('Some Photos Need Attention'), findsOneWidget);
        }
        Get.closeAllSnackbars();
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      },
    );
  }
}
