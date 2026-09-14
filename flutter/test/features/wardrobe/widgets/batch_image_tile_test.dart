import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/batch_image_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'photo removal has a labelled 48px target inside the batch grid',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var removals = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                // The 320px batch grid constrains each tile to about 90px.
                dimension: 90,
                child: BatchImageTile(
                  image: const BatchImage(
                    id: 'photo',
                    filePath: '/missing-test-photo.jpg',
                  ),
                  onRemove: () => removals++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byTooltip('Remove photo');
      expect(tester.getSize(button), const Size(48, 48));
      expect(tester.getSize(find.byType(BatchImageTile)), const Size(90, 90));
      expect(
        tester.getSemantics(button),
        matchesSemantics(
          tooltip: 'Remove photo',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      // The edge of the native target must work, not just the small close icon.
      await tester.tapAt(tester.getTopLeft(button) + const Offset(2, 24));
      expect(removals, 1);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
