import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';

/// One selected photo: a thumbnail decoded at tile size, a status overlay
/// while the batch runs, and a remove button while it is pending.
class BatchImageTile extends StatelessWidget {
  const BatchImageTile({
    super.key,
    required this.image,
    this.onRemove,
    this.showStatus = true,
  });

  final BatchImage image;
  final VoidCallback? onRemove;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final status = image.status;
    final count = image.extractedItems.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: tokens.stock.sunk,
            child: Image.file(
              File(image.filePath),
              fit: BoxFit.cover,
              // Up to 50 tiles: decode at tile size, not camera size.
              cacheWidth: 360,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_not_supported_outlined,
                color: tokens.textMuted,
              ),
            ),
          ),
          if (showStatus && status != BatchImageStatus.pending)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(child: _statusIcon(status)),
            ),
          if (count > 0)
            Positioned(
              left: AppConstants.spacing6,
              bottom: AppConstants.spacing4,
              child: Text(
                count == 1 ? '1 piece' : '$count pieces',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
                ),
              ),
            ),
          if (onRemove != null && status == BatchImageStatus.pending)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Remove photo',
                onPressed: onRemove,
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusIcon(BatchImageStatus status) => switch (status) {
    BatchImageStatus.pending => const SizedBox.shrink(),
    BatchImageStatus.uploading ||
    BatchImageStatus.extracting ||
    BatchImageStatus.generating => const SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
        strokeCap: StrokeCap.round,
      ),
    ),
    BatchImageStatus.extracted || BatchImageStatus.generated => const Icon(
      Icons.check_rounded,
      color: Colors.white,
      size: 28,
    ),
    BatchImageStatus.failed => const Icon(
      Icons.error_outline_rounded,
      color: Colors.white,
      size: 28,
    ),
  };
}
