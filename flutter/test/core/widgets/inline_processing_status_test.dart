import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck_ai/core/widgets/inline_processing_status.dart';

void main() {
  // Wrap in a real TextButton (narrow width, inherits a foreground color)
  // to catch both the overflow risk of Flexible-in-a-min-Row and the
  // ambient-color-inheritance regression a hardcoded text color would cause.
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          body: TextButton(onPressed: () {}, child: child),
        ),
      );

  testWidgets('processing phase shows elapsed seconds and no overflow',
      (tester) async {
    await tester.pumpWidget(
      wrap(const InlineProcessingStatus(phase: ProcessingPhase.processing)),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('2s elapsed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uploading phase shows the uploading copy with no elapsed suffix',
      (tester) async {
    await tester.pumpWidget(
      wrap(const InlineProcessingStatus(phase: ProcessingPhase.uploading)),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Uploading photo…'), findsOneWidget);
    expect(find.textContaining('elapsed'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
