import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main and legacy routes resolve to the current five destinations', () {
    const expected = {
      Routes.home: 0,
      Routes.wardrobe: 1,
      Routes.wardrobeStats: 1,
      Routes.outfits: 2,
      Routes.outfitCollections: 2,
      Routes.studio: 3,
      Routes.photoshoot: 3,
      Routes.tryOn: 3,
      Routes.profile: 4,
      Routes.more: 4,
      Routes.bodyProfiles: 4,
      Routes.recommendations: 4,
      Routes.settings: 4,
      Routes.aiSettings: 4,
      Routes.calendar: 4,
      Routes.gamification: 4,
      Routes.gifts: 4,
      Routes.subscription: 4,
      Routes.referral: 4,
      Routes.help: 4,
      Routes.feedback: 4,
      Routes.legal: 4,
      '/settings?section=ai': 4,
      '/unknown': 0,
    };
    for (final entry in expected.entries) {
      expect(
        AppBottomNavigationBar.getIndexForRoute(entry.key),
        entry.value,
        reason: entry.key,
      );
    }
    expect(AppBottomNavigationBar.navigationItems.map((item) => item.label), [
      'Home',
      'Closet',
      'Outfits',
      'Studio',
      'Profile',
    ]);
  });

  testWidgets('navigation fits 320px at 200% text and announces selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: selected,
              onTabChanged: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Studio'), findsOneWidget);
    final node = tester.getSemantics(find.text('Studio'));
    final selectedState = node.getSemanticsData().flagsCollection.isSelected;
    semantics.dispose();
    expect(selectedState, Tristate.isTrue);
    for (final label in ['Home', 'Closet', 'Outfits', 'Studio', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
