import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'paper_borders.dart';
import 'paper_tokens.dart';

/// Display face. Basteleur (Velvetyne, SIL OFL): Bold (700) for display
/// sizes, Moonlight (400) for headlines and page titles.
const String displayFontFamily = 'Basteleur';

final Map<(Brightness, PaperStockId), ThemeData> _cache = {};

/// Builds the app theme for one paper stock.
///
/// Each stock becomes a full [ColorScheme], so Material defaults (inputs,
/// switches, progress, chips, tabs) take the stock colours without per-widget
/// styling. Brand red is set only on filled buttons and the FAB.
ThemeData paperTheme(Brightness brightness, PaperStockId stockId) =>
    _cache.putIfAbsent((brightness, stockId), () {
      final base = brightness == Brightness.dark
          ? PaperTokens.dark
          : PaperTokens.light;
      return _build(base.withCurrent(stockId), brightness);
    });

ThemeData _build(PaperTokens t, Brightness brightness) {
  final s = t.stock;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: s.accent,
    onPrimary: s.onAccent,
    primaryContainer: s.tint,
    onPrimaryContainer: t.textPrimary,
    secondary: s.accent,
    onSecondary: s.onAccent,
    secondaryContainer: s.tint,
    onSecondaryContainer: t.textPrimary,
    tertiary: t.brand,
    onTertiary: t.onBrand,
    error: t.error,
    onError: brightness == Brightness.dark ? s.page : Colors.white,
    surface: s.page,
    onSurface: t.textPrimary,
    onSurfaceVariant: t.textSecondary,
    surfaceContainerLowest: s.card,
    surfaceContainerLow: s.card,
    surfaceContainer: s.card,
    surfaceContainerHigh: s.card,
    surfaceContainerHighest: s.sunk,
    outline: s.shadow,
    outlineVariant: s.edge,
    shadow: s.shadow,
    scrim: Colors.black54,
    inverseSurface: t.textPrimary,
    onInverseSurface: s.page,
    inversePrimary: s.tint,
    surfaceTint: Colors.transparent,
  );

  final typography = Typography.material2021(platform: defaultTargetPlatform);
  final body =
      (brightness == Brightness.dark ? typography.white : typography.black)
          .apply(bodyColor: t.textPrimary, displayColor: t.textPrimary);
  TextStyle display(TextStyle? s, double spacing) => s!.copyWith(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    letterSpacing: spacing,
    height: 1.1,
  );
  TextStyle headline(TextStyle? s) => s!.copyWith(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.15,
  );
  final textTheme = body.copyWith(
    displayLarge: display(body.displayLarge, -0.5),
    displayMedium: display(body.displayMedium, -0.4),
    displaySmall: display(body.displaySmall, -0.2),
    headlineLarge: headline(body.headlineLarge),
    headlineMedium: headline(body.headlineMedium),
    headlineSmall: headline(body.headlineSmall),
    labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  const radius = BorderRadius.all(Radius.circular(AppConstants.radius12));
  WidgetStateProperty<OutlinedBorder> slab(Color color, double depth) =>
      WidgetStateProperty.resolveWith(
        (states) => PaperSlabBorder(
          borderRadius: radius,
          slab: color,
          depth: states.contains(WidgetState.disabled)
              ? 0
              : states.contains(WidgetState.pressed)
              ? depth / 3
              : depth,
        ),
      );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.spacing20,
    vertical: AppConstants.spacing12,
  );
  final primaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? s.tint : t.brand,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.disabled) ? t.textSecondary : t.onBrand,
    ),
    overlayColor: WidgetStatePropertyAll(t.onBrand.withValues(alpha: 0.08)),
    elevation: const WidgetStatePropertyAll(0),
    minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
    padding: const WidgetStatePropertyAll(buttonPadding),
    shape: slab(t.brandSlab, 3),
    textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
  );
  final inputBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: s.edge),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: s.page,
    canvasColor: s.page,
    cardColor: s.card,
    dividerColor: s.edge,
    splashFactory: InkSparkle.splashFactory,
    extensions: [t],
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      // Transparent so the page grain runs under the title (AppPageBackground
      // paints it). Scroll views clip below the bar, so nothing shows through.
      backgroundColor: Colors.transparent,
      foregroundColor: t.textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.headlineSmall?.copyWith(fontSize: 24),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: s.card,
      surfaceTintColor: Colors.transparent,
      shape: PaperSlabBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppConstants.radius16),
        ),
        side: BorderSide(color: s.edge),
        slab: s.shadow,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
    filledButtonTheme: FilledButtonThemeData(style: primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? t.textMuted : s.accent,
        ),
        backgroundColor: WidgetStatePropertyAll(s.card),
        side: WidgetStatePropertyAll(BorderSide(color: s.edge)),
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        padding: const WidgetStatePropertyAll(buttonPadding),
        shape: slab(s.shadow, 2),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: s.accent,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing8,
        ),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: t.textPrimary,
        minimumSize: const Size(44, 44),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: t.brand,
      foregroundColor: t.onBrand,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: PaperSlabBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppConstants.radius16),
        ),
        slab: t.brandSlab,
      ),
      extendedTextStyle: textTheme.labelLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: s.card,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: s.accent, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: t.error)),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: t.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: t.textMuted),
      errorStyle: textTheme.bodySmall?.copyWith(color: t.error),
    ),
    chipTheme: ChipThemeData(
      // A selected chip is inked in the stock accent: clear at a glance.
      color: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? s.accent
            : states.contains(WidgetState.disabled)
            ? s.sunk
            : s.card,
      ),
      side: BorderSide(color: s.edge),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radius8)),
      ),
      labelStyle: textTheme.labelLarge?.copyWith(
        color: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? s.onAccent
              : t.textPrimary,
        ),
      ),
      checkmarkColor: s.onAccent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? s.onAccent : t.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? s.accent : s.sunk,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? s.accent : t.textMuted,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? s.accent : s.card,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? s.onAccent
              : t.textPrimary,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: s.edge)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: s.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: PaperSlabBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppConstants.radius24),
        ),
        side: BorderSide(color: s.edge),
        slab: s.shadow,
        depth: 4,
      ),
      titleTextStyle: textTheme.headlineSmall,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: s.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      showDragHandle: false,
      shape: const DeckleBorder(edge: PaperEdge.top, radius: 24),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: s.card,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: textTheme.bodyMedium,
      shape: PaperSlabBorder(
        borderRadius: radius,
        side: BorderSide(color: s.edge),
        slab: s.shadow,
      ),
    ),
    dividerTheme: DividerThemeData(color: s.edge, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: t.textPrimary,
      unselectedLabelColor: t.textMuted,
      indicatorColor: s.accent,
      dividerColor: Colors.transparent,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: s.accent,
      linearTrackColor: s.sunk,
      circularTrackColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(iconColor: t.textSecondary),
  );
}
