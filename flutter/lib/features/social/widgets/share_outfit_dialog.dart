import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Share outfit dialog
class ShareOutfitDialog extends StatelessWidget {
  final String outfitId;
  final String outfitName;
  final VoidCallback onShare;

  const ShareOutfitDialog({
    super.key,
    required this.outfitId,
    required this.outfitName,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AlertDialog(
      title: const Text('Share Outfit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.share,
            size: 48,
            color: tokens.brandColor,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Share "${outfitName}" with others',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing24),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Public Link',
              hintText: 'Generating...',
              filled: true,
              fillColor: tokens.cardColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyLink(context),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            onShare();
            Get.back();
          },
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    );
  }

  void _copyLink(BuildContext context) {
    // Would copy to clipboard
    Get.snackbar(
      'Copied',
      'Link copied to clipboard',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }
}
