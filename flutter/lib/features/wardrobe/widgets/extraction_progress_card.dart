import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';

/// A thin progress track. The fill keeps round caps at every value (it never
/// narrows below its own height), and it eases between values unless the
/// platform asks for reduced motion.
class PaperProgressTrack extends StatelessWidget {
  const PaperProgressTrack({
    super.key,
    required this.value,
    this.height = 6,
    this.semanticLabel,
  });

  /// 0 to 1.
  final double value;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final stock = PaperTokens.of(context).stock;
    final v = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height / 2);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final full = constraints.maxWidth;
            final width = v <= 0 ? 0.0 : (full * v).clamp(height, full);
            return DecoratedBox(
              decoration: BoxDecoration(
                color: stock.sunk,
                borderRadius: radius,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: stock.accent,
                    borderRadius: radius,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One photo in the batch progress list: thumbnail, status and the number
/// of pieces found.
class ExtractionProgressCard extends StatelessWidget {
  const ExtractionProgressCard({super.key, required this.image});

  final BatchImage image;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final count = image.extractedItems.length;
    final detail =
        image.error ??
        (count > 0
            ? (count == 1 ? '1 piece found' : '$count pieces found')
            : null);

    return PaperSurface(
      lift: 0.6,
      padding: const EdgeInsets.all(AppConstants.spacing8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox.square(
              dimension: 56,
              child: ColoredBox(
                color: tokens.stock.sunk,
                child: Image.file(
                  File(image.filePath),
                  fit: BoxFit.cover,
                  cacheWidth: 168,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.image_not_supported_outlined,
                    color: tokens.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label,
                  style: text.bodyMedium?.copyWith(color: tokens.textPrimary),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: image.error != null
                          ? tokens.error
                          : tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing8),
          SizedBox.square(
            dimension: 24,
            child: Center(child: _statusIcon(tokens)),
          ),
          const SizedBox(width: AppConstants.spacing4),
        ],
      ),
    );
  }

  String get _label => switch (image.status) {
    BatchImageStatus.pending => 'Waiting',
    BatchImageStatus.uploading => 'Uploading',
    BatchImageStatus.extracting => 'Looking for pieces',
    BatchImageStatus.extracted => 'Pieces found',
    BatchImageStatus.generating => 'Making studio photos',
    BatchImageStatus.generated => 'Done',
    BatchImageStatus.failed => 'Skipped',
  };

  Widget _statusIcon(PaperTokens tokens) => switch (image.status) {
    BatchImageStatus.pending => Icon(
      Icons.schedule_rounded,
      size: 20,
      color: tokens.textMuted,
    ),
    BatchImageStatus.uploading ||
    BatchImageStatus.extracting ||
    BatchImageStatus.generating => SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: tokens.stock.accent,
        strokeCap: StrokeCap.round,
      ),
    ),
    BatchImageStatus.extracted || BatchImageStatus.generated => Icon(
      Icons.check_rounded,
      size: 22,
      color: tokens.success,
    ),
    BatchImageStatus.failed => Icon(
      Icons.error_outline_rounded,
      size: 22,
      color: tokens.error,
    ),
  };
}
