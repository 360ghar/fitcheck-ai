import 'package:flutter/material.dart';

/// The five paper stocks. Each main tab owns one stock, so every screen of
/// a feature is cut from the same paper. Sheets and dialogs use [stone].
enum PaperStockId { ink, clay, moss, marigold, stone }

/// Stock per shell tab, in bottom-navigation order:
/// Home, Photoshoot, Closet, Outfits, More.
const List<PaperStockId> tabStocks = [
  PaperStockId.ink,
  PaperStockId.clay,
  PaperStockId.moss,
  PaperStockId.marigold,
  PaperStockId.stone,
];

/// One sheet of coloured paper and the tones cut from it.
@immutable
class PaperStock {
  const PaperStock({
    required this.page,
    required this.card,
    required this.sunk,
    required this.tint,
    required this.edge,
    required this.shadow,
    required this.accent,
    required this.onAccent,
  });

  /// Screen background.
  final Color page;

  /// Raised surfaces: cards, sheets, inputs.
  final Color card;

  /// Recessed surfaces: skeletons, image wells, placeholders.
  final Color sunk;

  /// Selected and highlighted surfaces.
  final Color tint;

  /// Hairline edge of a surface.
  final Color edge;

  /// The offset slab under a raised surface. Never blurred.
  final Color shadow;

  /// Tonal accent for text, icons and selected controls.
  final Color accent;

  /// Text and icons on [accent].
  final Color onAccent;

  static PaperStock lerp(PaperStock a, PaperStock b, double t) => PaperStock(
    page: Color.lerp(a.page, b.page, t)!,
    card: Color.lerp(a.card, b.card, t)!,
    sunk: Color.lerp(a.sunk, b.sunk, t)!,
    tint: Color.lerp(a.tint, b.tint, t)!,
    edge: Color.lerp(a.edge, b.edge, t)!,
    shadow: Color.lerp(a.shadow, b.shadow, t)!,
    accent: Color.lerp(a.accent, b.accent, t)!,
    onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
  );
}

/// Paper design tokens. Read with [PaperTokens.of].
///
/// Brand red is reserved for primary actions (filled buttons, the FAB).
/// Everything else uses the current stock's tonal [PaperStock.accent].
@immutable
class PaperTokens extends ThemeExtension<PaperTokens> {
  const PaperTokens({
    required this.ink,
    required this.clay,
    required this.moss,
    required this.marigold,
    required this.stone,
    required this.current,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.brand,
    required this.brandSlab,
    required this.onBrand,
    required this.success,
    required this.warning,
    required this.error,
    required this.grainOpacity,
    this.shadowOffset = const Offset(1.5, 3),
    this.pressedOffset = const Offset(0.5, 1),
  });

  final PaperStock ink;
  final PaperStock clay;
  final PaperStock moss;
  final PaperStock marigold;
  final PaperStock stone;

  /// The stock of the current subtree. Set by `PaperStockScope`.
  final PaperStockId current;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Primary-action fill.
  final Color brand;

  /// Slab under a [brand] surface.
  final Color brandSlab;
  final Color onBrand;

  final Color success;
  final Color warning;
  final Color error;

  /// Opacity of the paper grain texture. 0 turns it off.
  final double grainOpacity;

  /// Offset of the slab under a surface at lift 1.
  final Offset shadowOffset;

  /// Offset of the slab while a surface is pressed.
  final Offset pressedOffset;

  PaperStock get stock => stockOf(current);

  bool get isDark => textPrimary.computeLuminance() > 0.5;

  /// Colour of a cut-paper shape (garment, sun) from [id]: the stock's edge
  /// tone in light mode, lifted toward its accent in dark mode so shapes
  /// stay visible on dark paper.
  Color cutOf(PaperStockId id, {bool light = false}) {
    final s = stockOf(id);
    final base = light ? s.tint : s.edge;
    return isDark ? Color.lerp(base, s.accent, 0.5)! : base;
  }

  PaperStock stockOf(PaperStockId id) => switch (id) {
    PaperStockId.ink => ink,
    PaperStockId.clay => clay,
    PaperStockId.moss => moss,
    PaperStockId.marigold => marigold,
    PaperStockId.stone => stone,
  };

  static PaperTokens of(BuildContext context) =>
      Theme.of(context).extension<PaperTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  static const light = PaperTokens(
    ink: PaperStock(
      page: Color(0xFFE3E9F1),
      card: Color(0xFFFBFCFD),
      sunk: Color(0xFFD6DEE9),
      tint: Color(0xFFD3DDEA),
      edge: Color(0xFFC3CEDC),
      shadow: Color(0xFF9FB0C6),
      accent: Color(0xFF2E4A6E),
      onAccent: Color(0xFFFFFFFF),
    ),
    clay: PaperStock(
      page: Color(0xFFF1E0D6),
      card: Color(0xFFFFFCFA),
      sunk: Color(0xFFEAD2C4),
      tint: Color(0xFFEFD3C4),
      edge: Color(0xFFDDBFAE),
      shadow: Color(0xFFC99A82),
      accent: Color(0xFF8C4026),
      onAccent: Color(0xFFFFFFFF),
    ),
    moss: PaperStock(
      page: Color(0xFFE2E9DA),
      card: Color(0xFFFCFDFA),
      sunk: Color(0xFFD3DECA),
      tint: Color(0xFFD2DEC6),
      edge: Color(0xFFC0CEB3),
      shadow: Color(0xFF9CB08C),
      accent: Color(0xFF3F5E36),
      onAccent: Color(0xFFFFFFFF),
    ),
    marigold: PaperStock(
      page: Color(0xFFF5E6BF),
      card: Color(0xFFFFFEFA),
      sunk: Color(0xFFEEDBA6),
      tint: Color(0xFFF0DC9E),
      edge: Color(0xFFE0C987),
      shadow: Color(0xFFCDA94F),
      accent: Color(0xFF6E510C),
      onAccent: Color(0xFFFFFFFF),
    ),
    stone: PaperStock(
      page: Color(0xFFE7E6E1),
      card: Color(0xFFFDFDFC),
      sunk: Color(0xFFDCDBD5),
      tint: Color(0xFFDAD9D2),
      edge: Color(0xFFCAC9C2),
      shadow: Color(0xFFABAAA2),
      accent: Color(0xFF3A3A35),
      onAccent: Color(0xFFFFFFFF),
    ),
    current: PaperStockId.stone,
    textPrimary: Color(0xFF1C1B17),
    textSecondary: Color(0xFF45433C),
    textMuted: Color(0xFF5B5951),
    brand: Color(0xFFE00016),
    brandSlab: Color(0xFF9E0010),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF285E37),
    warning: Color(0xFF7F5300),
    error: Color(0xFFA3140F),
    grainOpacity: 0.55,
  );

  static const dark = PaperTokens(
    ink: PaperStock(
      page: Color(0xFF0F1B30),
      card: Color(0xFF182742),
      sunk: Color(0xFF0B1426),
      tint: Color(0xFF1F3354),
      edge: Color(0xFF2A4166),
      shadow: Color(0xFF050A14),
      accent: Color(0xFFA7C0E2),
      onAccent: Color(0xFF0B1426),
    ),
    clay: PaperStock(
      page: Color(0xFF22150F),
      card: Color(0xFF3B271F),
      sunk: Color(0xFF1A0F0B),
      tint: Color(0xFF4B3024),
      edge: Color(0xFF4A3025),
      shadow: Color(0xFF0E0806),
      accent: Color(0xFFE9A487),
      onAccent: Color(0xFF22150F),
    ),
    moss: PaperStock(
      page: Color(0xFF151D13),
      card: Color(0xFF212C1E),
      sunk: Color(0xFF0F150E),
      tint: Color(0xFF2B3A27),
      edge: Color(0xFF33432E),
      shadow: Color(0xFF070A06),
      accent: Color(0xFFA9C79A),
      onAccent: Color(0xFF151D13),
    ),
    marigold: PaperStock(
      page: Color(0xFF211A0A),
      card: Color(0xFF3A2E16),
      sunk: Color(0xFF181206),
      tint: Color(0xFF45371A),
      edge: Color(0xFF4A3B1C),
      shadow: Color(0xFF0C0903),
      accent: Color(0xFFE8C66A),
      onAccent: Color(0xFF211A0A),
    ),
    stone: PaperStock(
      page: Color(0xFF1A1917),
      card: Color(0xFF262522),
      sunk: Color(0xFF131211),
      tint: Color(0xFF302E2A),
      edge: Color(0xFF383631),
      shadow: Color(0xFF0A0A09),
      accent: Color(0xFFD6D2C8),
      onAccent: Color(0xFF1A1917),
    ),
    current: PaperStockId.stone,
    textPrimary: Color(0xFFF1EFE9),
    textSecondary: Color(0xFFCFCBC1),
    textMuted: Color(0xFFA8A49A),
    brand: Color(0xFFE00016),
    brandSlab: Color(0xFF7A000C),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF8FD0A0),
    warning: Color(0xFFF0C060),
    error: Color(0xFFFF9B92),
    grainOpacity: 0.35,
  );

  PaperTokens withCurrent(PaperStockId id) =>
      id == current ? this : copyWith(current: id);

  @override
  PaperTokens copyWith({PaperStockId? current, double? grainOpacity}) =>
      PaperTokens(
        ink: ink,
        clay: clay,
        moss: moss,
        marigold: marigold,
        stone: stone,
        current: current ?? this.current,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textMuted: textMuted,
        brand: brand,
        brandSlab: brandSlab,
        onBrand: onBrand,
        success: success,
        warning: warning,
        error: error,
        grainOpacity: grainOpacity ?? this.grainOpacity,
        shadowOffset: shadowOffset,
        pressedOffset: pressedOffset,
      );

  @override
  PaperTokens lerp(covariant PaperTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PaperTokens(
      ink: PaperStock.lerp(ink, other.ink, t),
      clay: PaperStock.lerp(clay, other.clay, t),
      moss: PaperStock.lerp(moss, other.moss, t),
      marigold: PaperStock.lerp(marigold, other.marigold, t),
      stone: PaperStock.lerp(stone, other.stone, t),
      current: t < 0.5 ? current : other.current,
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      brand: c(brand, other.brand),
      brandSlab: c(brandSlab, other.brandSlab),
      onBrand: c(onBrand, other.onBrand),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      error: c(error, other.error),
      grainOpacity: grainOpacity + (other.grainOpacity - grainOpacity) * t,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      pressedOffset: Offset.lerp(pressedOffset, other.pressedOffset, t)!,
    );
  }
}
