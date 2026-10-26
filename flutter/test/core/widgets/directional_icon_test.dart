import 'package:fitcheck_ai/core/widgets/directional_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpIcon(
    WidgetTester tester, {
    required TextDirection textDirection,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: const DirectionalIcon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }

  // Icon and the text engine insert their own Transform widgets, so scope the
  // finder to the one this widget owns rather than matching every Transform.
  Transform ownTransform(WidgetTester tester) {
    return tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(DirectionalIcon),
            matching: find.byType(Transform),
          )
          .first,
    );
  }

  testWidgets('draws the glyph unflipped in a left-to-right locale', (
    tester,
  ) async {
    await pumpIcon(tester, textDirection: TextDirection.ltr);

    // No horizontal mirror: x stays x.
    expect(ownTransform(tester).transform.entry(0, 0), equals(1.0));
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('flips the glyph in a right-to-left locale', (tester) async {
    await pumpIcon(tester, textDirection: TextDirection.rtl);

    // A horizontal mirror: x -> -x. Checked element-wise rather than against a
    // hardcoded matrix so a refactor to Matrix4.diagonal3Values still passes.
    expect(ownTransform(tester).transform.entry(0, 0), equals(-1.0));
    // The glyph itself is unchanged; only the paint is mirrored.
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('keeps the icon size and colour it was given', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: DirectionalIcon(
          Icons.arrow_back_rounded,
          size: 18,
          color: Color(0xFF112233),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, equals(18));
    expect(icon.color, equals(const Color(0xFF112233)));
  });
}
