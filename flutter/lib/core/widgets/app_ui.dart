import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'paper.dart';

export 'app_image.dart';
export 'app_image_viewer.dart';
export 'app_states.dart';
export 'brand.dart';
export 'infinite_scroll_wrapper.dart';
export 'inline_processing_status.dart';
export 'paper.dart';
export 'paper_scene.dart';
export 'skeletons.dart';

/// Colour shortcuts for feature code. Reads [PaperTokens] for the current
/// paper stock, so the same call site follows the stock of its screen.
class AppUiTokens {
  AppUiTokens._(this.paper, this.isDarkMode);

  factory AppUiTokens.of(BuildContext context) => AppUiTokens._(
    PaperTokens.of(context),
    Theme.of(context).brightness == Brightness.dark,
  );

  final PaperTokens paper;
  final bool isDarkMode;

  PaperStock get stock => paper.stock;

  Color get textPrimary => paper.textPrimary;
  Color get textSecondary => paper.textSecondary;
  Color get textMuted => paper.textMuted;

  /// Raised surface.
  Color get cardColor => stock.card;
  Color get cardBorderColor => stock.edge;

  /// Kept for old call sites; surfaces use a solid slab, not a blur.
  Color get cardShadowColor => Colors.transparent;
  Color get navBackground => stock.card;
  Color get navBorder => stock.edge;

  /// Tonal accent of the current stock. Brand red is [brand].
  Color get brandColor => stock.accent;
  Color get accent => stock.accent;
  Color get onAccent => stock.onAccent;
  Color get tint => stock.tint;
  Color get sunk => stock.sunk;
  Color get page => stock.page;

  /// Primary-action red.
  Color get brand => paper.brand;
  Color get onBrand => paper.onBrand;

  Color get success => paper.success;
  Color get warning => paper.warning;
  Color get error => paper.error;
}

/// Page background in the current stock with paper grain, content capped at
/// [AppConstants.maxContentWidth] on tablets.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final stock = PaperTokens.of(context).stock;
    final decoration = BoxDecoration(
      color: stock.page,
      image: paperGrain(context),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Runs up under the transparent app bar to the top of the screen, so
        // the grain has no seam where the bar ends.
        Positioned(
          top: -(MediaQuery.paddingOf(context).top + kToolbarHeight * 2),
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(decoration: decoration),
        ),
        Positioned.fill(child: _content()),
      ],
    );
  }

  Widget _content() => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    ),
  );
}

/// Former name of [PaperSurface]; same constructor.
typedef AppGlassCard = PaperSurface;

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
