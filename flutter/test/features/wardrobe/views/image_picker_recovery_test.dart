import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_edit_page.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/manual_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class _DeniedOncePicker extends ImagePicker {
  int calls = 0;

  @override
  Future<List<XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    if (++calls == 1) throw PlatformException(code: 'photo_access_denied');
    return [];
  }
}

class _DeniedCameraPicker extends ImagePicker {
  int calls = 0;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    throw PlatformException(code: 'camera_access_denied');
  }
}

class _RecoveryNetwork extends NetworkService {
  @override
  // Skip platform listeners in fixtures.
  // ignore: must_call_super
  void onInit() {}
}

class _RecoveryWardrobe extends WardrobeController {
  @override
  // Layout fixtures deliberately skip network and platform initialization.
  // ignore: must_call_super
  void onInit() {}
}

const _editItem = ItemModel(
  id: 'item',
  userId: 'user',
  name: 'Oversized cotton shirt',
  category: Category.tops,
  condition: domain.Condition.clean,
);

Future<void> _pumpEditPage(
  WidgetTester tester, {
  required ImagePicker picker,
}) async {
  Get.put<NetworkService>(_RecoveryNetwork());
  Get.put<WardrobeController>(_RecoveryWardrobe()..items.add(_editItem));
  await tester.pumpWidget(
    GetMaterialApp(
      home: ItemEditPage(itemId: 'item', imagePicker: picker),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  testWidgets('denied photo access preserves form and allows another attempt', (
    tester,
  ) async {
    final picker = _DeniedOncePicker();
    await tester.pumpWidget(
      GetMaterialApp(home: ManualEntryForm(imagePicker: picker)),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Blue shirt');
    await tester.tap(find.text('Add Photo (Multiple)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Photos Access Needed'), findsOneWidget);
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Photo (Multiple)'));
    await tester.pumpAndSettle();
    expect(picker.calls, 2);
    expect(find.text('Blue shirt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit page surfaces the Settings recovery on denied access', (
    tester,
  ) async {
    final picker = _DeniedOncePicker();
    await _pumpEditPage(tester, picker: picker);
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Photos Access Needed'), findsOneWidget);
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(picker.calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit page camera denial offers to open Settings', (
    tester,
  ) async {
    final picker = _DeniedCameraPicker();
    await _pumpEditPage(tester, picker: picker);
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Camera Access Needed'), findsOneWidget);
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    expect(picker.calls, 1);
    expect(tester.takeException(), isNull);
  });
}
