import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/widgets/today_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=';
const _ootd = DashboardOutfitOfTheDay(
  id: 'o1',
  name: 'Weekend edit',
  imageUrl: _pixel,
);

Future<void> _pump(WidgetTester tester, Widget body) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
  );
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: body)));
  await tester.pump();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('feature stacks item cutouts when photos are given', (
    tester,
  ) async {
    await _pump(
      tester,
      TodayEdit(
        outfit: _ootd,
        hasItems: true,
        itemPhotos: const [
          CollagePhoto(url: _pixel),
          CollagePhoto(url: _pixel),
        ],
        onOpen: () {},
      ),
    );

    expect(find.byType(OutfitStackCollage), findsOneWidget);
    // Two cutouts render; the flat outfit photo is gone.
    expect(find.byType(AppImage), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('feature falls back to the outfit image without photos', (
    tester,
  ) async {
    await _pump(
      tester,
      TodayEdit(outfit: _ootd, hasItems: true, onOpen: () {}),
    );

    expect(find.byType(OutfitStackCollage), findsNothing);
    expect(find.byType(AppImage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty collage shows a placeholder icon', (tester) async {
    await _pump(
      tester,
      const SizedBox(
        height: 220,
        child: OutfitStackCollage(photos: [], remintUrl: null),
      ),
    );

    expect(find.byIcon(Icons.checkroom_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single-photo collage renders one tile', (tester) async {
    await _pump(
      tester,
      const SizedBox(
        height: 220,
        child: OutfitStackCollage(
          photos: [CollagePhoto(url: _pixel)],
          remintUrl: null,
        ),
      ),
    );

    expect(find.byType(AppImage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
