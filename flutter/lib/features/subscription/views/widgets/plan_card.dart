import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_ui.dart';

/// One paid tier as the paywall shows it.
@immutable
class PlanOption {
  const PlanOption({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.note,
    required this.features,
  });

  /// `plus` or `pro`.
  final String id;
  final String title;

  /// Localized store price when known, else the /plans price.
  final String price;

  /// `/month` or `/year`.
  final String period;

  /// One line under the price, for example "Save $20 a year".
  final String note;
  final List<String> features;
}

/// Paid tiers side by side as sheets of paper. Tap a sheet to select it; the
/// selected sheet carries a 2px accent border.
///
/// The text is laid out as shared rows over the sheets, so the title, price,
/// note and each feature line start on the same line in every column,
/// whatever the copy length.
class PlanOptions extends StatelessWidget {
  const PlanOptions({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelect,
    this.enabled = true,
  });

  final List<PlanOption> options;
  final String selectedId;
  final ValueChanged<String> onSelect;

  /// False while a purchase is starting: selection is frozen.
  final bool enabled;

  static const _gap = AppConstants.spacing12;
  static const _pad = AppConstants.spacing16;
  static const _radius = AppConstants.radius12;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final featureCount = options.fold<int>(
      0,
      (n, o) => o.features.length > n ? o.features.length : n,
    );

    Widget row(Widget Function(PlanOption o) cell, {double top = 0}) => Padding(
      padding: EdgeInsets.only(top: top),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, o) in options.indexed) ...[
              if (i > 0) const SizedBox(width: _gap + 2 * _pad),
              Expanded(child: cell(o)),
            ],
          ],
        ),
      ),
    );

    final rows = Padding(
      padding: const EdgeInsets.all(_pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row((o) => Text(o.title, style: text.headlineSmall)),
          row(
            (o) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    o.price,
                    style: text.displaySmall?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(width: AppConstants.spacing4),
                  Text(
                    o.period,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            top: AppConstants.spacing8,
          ),
          row(
            (o) => Text(
              o.note,
              style: text.bodySmall?.copyWith(
                color: tokens.stock.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            top: AppConstants.spacing4,
          ),
          for (var f = 0; f < featureCount; f++)
            row(
              (o) => f < o.features.length
                  ? Text(
                      o.features[f],
                      style: text.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    )
                  : const SizedBox.shrink(),
              top: f == 0 ? AppConstants.spacing12 : AppConstants.spacing4,
            ),
        ],
      ),
    );

    final sheets = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, o) in options.indexed) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(child: _sheet(context, o, o.id == selectedId)),
        ],
      ],
    );

    return Stack(
      children: [
        Positioned.fill(child: sheets),
        IgnorePointer(child: ExcludeSemantics(child: rows)),
      ],
    );
  }

  Widget _sheet(BuildContext context, PlanOption o, bool selected) {
    final tokens = PaperTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        PaperSurface(
          borderRadius: _radius,
          color: selected ? tokens.stock.tint : null,
          onTap: enabled ? () => onSelect(o.id) : null,
          semanticLabel:
              '${o.title}, ${o.price} ${o.period == '/year' ? 'a year' : 'a month'}. '
              '${o.features.join(', ')}.${selected ? ' Selected.' : ''}',
          child: const SizedBox.expand(),
        ),
        if (selected)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: tokens.stock.accent, width: 2),
                borderRadius: BorderRadius.circular(_radius),
              ),
            ),
          ),
      ],
    );
  }
}
