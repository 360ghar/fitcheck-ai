import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';

/// Card widget showing extraction progress for a single image
class ExtractionProgressCard extends StatelessWidget {
  const ExtractionProgressCard({
    super.key,
    required this.image,
    this.onRetry,
  });

  final BatchImage image;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.file(
                File(image.filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: tokens.cardColor,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: tokens.textMuted,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing12),

          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                if (image.error != null)
                  Text(
                    image.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (image.extractedItems.isNotEmpty)
                  Text(
                    '${image.extractedItems.length} item${image.extractedItems.length == 1 ? '' : 's'} detected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
              ],
            ),
          ),

          // Status icon
          _buildStatusIcon(tokens),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (image.status) {
      case BatchImageStatus.pending:
        return 'Waiting...';
      case BatchImageStatus.uploading:
        return 'Uploading...';
      case BatchImageStatus.extracting:
        return 'Extracting items...';
      case BatchImageStatus.extracted:
        return 'Extracted';
      case BatchImageStatus.generating:
        return 'Generating images...';
      case BatchImageStatus.generated:
        return 'Complete';
      case BatchImageStatus.failed:
        return 'Failed';
    }
  }

  Widget _buildStatusIcon(AppUiTokens tokens) {
    switch (image.status) {
      case BatchImageStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          color: tokens.textMuted,
          size: 24,
        );
      case BatchImageStatus.uploading:
      case BatchImageStatus.extracting:
      case BatchImageStatus.generating:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
          ),
        );
      case BatchImageStatus.extracted:
      case BatchImageStatus.generated:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        );
      case BatchImageStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 24,
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh,
                  color: tokens.brandColor,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        );
    }
  }
}
