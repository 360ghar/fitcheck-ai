import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../repositories/outfit_repository.dart';
import '../../../core/utils/error_handler.dart';

/// Controller for outfit sharing.
///
/// Used to own AI visualization generation + polling too, but that flow had
/// zero callers anywhere in the app (outfit_builder_controller.dart owns
/// visualization generation for the live outfit-builder flow instead) - only
/// [shareOutfit] was ever wired up, from outfits_content.dart.
class OutfitGenerationController extends GetxController {
  final OutfitRepository _repository = OutfitRepository();

  /// Share outfit
  Future<void> shareOutfit(String outfitId) async {
    try {
      final shareUrl = await _repository.shareOutfit(outfitId);

      await Get.dialog(
        AlertDialog(
          title: const Text('Outfit Shared'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('Your outfit is now publicly available'),
              const SizedBox(height: 16),
              SelectableText(shareUrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: shareUrl));
                ErrorHandler.showSuccess('Share link copied to clipboard', title: 'Copied');
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () async {
                await Share.share(
                  'Check out my outfit on FitCheck AI!\n\n$shareUrl',
                  subject: 'Check out my outfit!',
                );
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ErrorHandler.showError(
        ErrorHandler.extractMessage(e),
      );
    }
  }
}
