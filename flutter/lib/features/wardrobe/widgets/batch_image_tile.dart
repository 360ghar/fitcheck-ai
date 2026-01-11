import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';

/// A tile widget displaying a batch image with status indicator and remove button
class BatchImageTile extends StatelessWidget {
  const BatchImageTile({
    super.key,
    required this.image,
    this.onRemove,
    this.showStatus = true,
    this.size = 100,
  });

  final BatchImage image;
  final VoidCallback? onRemove;
  final bool showStatus;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: _getBorderColor(tokens),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radius12 - 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.file(
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

            // Status overlay for non-pending states
            if (showStatus && image.status != BatchImageStatus.pending)
              _buildStatusOverlay(tokens),

            // Remove button
            if (onRemove != null && image.status == BatchImageStatus.pending)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Items count badge (after extraction)
            if (image.extractedItems.isNotEmpty)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brandColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${image.extractedItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverlay(AppUiTokens tokens) {
    return Container(
      color: _getOverlayColor(),
      child: Center(
        child: _buildStatusIcon(tokens),
      ),
    );
  }

  Widget _buildStatusIcon(AppUiTokens tokens) {
    switch (image.status) {
      case BatchImageStatus.pending:
        return const SizedBox.shrink();
      case BatchImageStatus.uploading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case BatchImageStatus.extracting:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case BatchImageStatus.extracted:
        return const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 32,
        );
      case BatchImageStatus.generating:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case BatchImageStatus.generated:
        return const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 32,
        );
      case BatchImageStatus.failed:
        return const Icon(
          Icons.error,
          color: Colors.white,
          size: 32,
        );
    }
  }

  Color _getBorderColor(AppUiTokens tokens) {
    switch (image.status) {
      case BatchImageStatus.pending:
        return tokens.cardBorderColor;
      case BatchImageStatus.uploading:
      case BatchImageStatus.extracting:
      case BatchImageStatus.generating:
        return tokens.brandColor;
      case BatchImageStatus.extracted:
      case BatchImageStatus.generated:
        return Colors.green;
      case BatchImageStatus.failed:
        return Colors.red;
    }
  }

  Color _getOverlayColor() {
    switch (image.status) {
      case BatchImageStatus.pending:
        return Colors.transparent;
      case BatchImageStatus.uploading:
      case BatchImageStatus.extracting:
      case BatchImageStatus.generating:
        return Colors.black.withOpacity(0.5);
      case BatchImageStatus.extracted:
      case BatchImageStatus.generated:
        return Colors.green.withOpacity(0.6);
      case BatchImageStatus.failed:
        return Colors.red.withOpacity(0.6);
    }
  }
}
