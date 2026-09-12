import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// One component system for both mobile appearances.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final primary = dark ? AppColors.primaryDarkMode : AppColors.primary;
    final ink = dark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final muted = dark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariantLight;
    final canvas = dark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inset = dark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final border = dark ? AppColors.borderDark : AppColors.borderLight;
    final error = dark ? AppColors.errorDarkMode : AppColors.error;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: primary,
      onPrimary: dark ? AppColors.backgroundDark : Colors.white,
      primaryContainer: dark
          ? const Color(0xFF3A483F)
          : AppColors.primaryContainer,
      onPrimaryContainer: dark
          ? AppColors.onSurfaceDark
          : AppColors.primaryDark,
      secondary: dark ? AppColors.secondaryLight : AppColors.secondary,
      onSecondary: dark ? AppColors.backgroundDark : Colors.white,
      secondaryContainer: dark
          ? const Color(0xFF443D36)
          : const Color(0xFFECE4DD),
      onSecondaryContainer: dark
          ? AppColors.onSurfaceDark
          : AppColors.secondaryDark,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerHighest: inset,
      outline: muted,
      outlineVariant: border,
      error: error,
      onError: dark ? AppColors.backgroundDark : Colors.white,
    );
    final text = ThemeData(brightness: brightness).textTheme
        .merge(AppTextStyles.textTheme)
        .apply(bodyColor: ink, displayColor: ink);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final controlStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(shape),
      textStyle: WidgetStatePropertyAll(
        text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: canvas,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle:
            (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: canvas,
                  systemNavigationBarIconBrightness: dark
                      ? Brightness.light
                      : Brightness.dark,
                ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: shape.copyWith(side: BorderSide(color: border)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: controlStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: controlStyle.copyWith(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? null : primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? null : scheme.onPrimary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: controlStyle.copyWith(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? null : primary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: controlStyle.copyWith(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? null : primary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: shape,
        extendedTextStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inset,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 2),
        errorBorder: inputBorder(error),
        focusedErrorBorder: inputBorder(error, 2),
        errorStyle: text.bodySmall?.copyWith(color: error),
        errorMaxLines: 3,
        helperMaxLines: 3,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 0,
        backgroundColor: inset,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: primary),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: muted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        titleTextStyle: text.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: inset,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 500),
      ),
    );
  }
}
