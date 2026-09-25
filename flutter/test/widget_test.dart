import 'package:fitcheck_ai/core/providers.dart';
import 'package:fitcheck_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and leaves the splash for the intro', (
    tester,
  ) async {
    // Same container as main(): route guards read it directly.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: appContainer,
        child: const FitCheckApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);

    // Paper scenes sway forever, so pumpAndSettle never returns. Pump past
    // the splash minimum and the route transition instead.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    // A first launch shows the intro sheets before the sign-in entry.
    expect(find.text('Snap your closet once.'), findsOneWidget);
  });
}
