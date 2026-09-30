import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/theme/paper_borders.dart';
import 'package:fitcheck_ai/core/theme/paper_theme.dart';
import 'package:fitcheck_ai/core/theme/paper_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand red is used only for primary actions', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final tokens = theme.extension<PaperTokens>()!;
      expect(
        theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}),
        tokens.brand,
      );
      expect(theme.floatingActionButtonTheme.backgroundColor, tokens.brand);
      // Everything else is tonal: the scheme primary is the stock accent.
      expect(theme.colorScheme.primary, tokens.stock.accent);
      expect(theme.colorScheme.primary, isNot(tokens.brand));
    }
  });

  test('each stock re-themes surfaces and keeps 44px targets', () {
    final moss = paperTheme(Brightness.light, PaperStockId.moss);
    expect(moss.scaffoldBackgroundColor, PaperTokens.light.moss.page);
    expect(moss.extension<PaperTokens>()!.current, PaperStockId.moss);
    expect(
      moss.elevatedButtonTheme.style?.minimumSize?.resolve({}),
      const Size(44, 44),
    );
  });

  test('pressed buttons sink onto a shallower slab', () {
    final shape = AppTheme.lightTheme.elevatedButtonTheme.style!.shape!;
    final rest = shape.resolve({})! as PaperSlabBorder;
    final pressed = shape.resolve({WidgetState.pressed})! as PaperSlabBorder;
    final disabled = shape.resolve({WidgetState.disabled})! as PaperSlabBorder;
    expect(pressed.depth, lessThan(rest.depth));
    expect(disabled.depth, 0);
    // Material merges the side into the shape; the slab must survive it.
    expect(rest.copyWith(side: const BorderSide()).depth, rest.depth);
  });

  test('display and headline styles use the display face', () {
    final text = AppTheme.lightTheme.textTheme;
    expect(text.displaySmall?.fontFamily, displayFontFamily);
    expect(text.headlineSmall?.fontFamily, displayFontFamily);
    expect(text.bodyMedium?.fontFamily, isNot(displayFontFamily));
  });
}
