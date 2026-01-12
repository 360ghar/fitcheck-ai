import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../repositories/outfit_repository.dart';
import 'outfit_list_controller.dart';

/// Controller for AI outfit visualization generation
/// Focused responsibility: Managing AI generation and polling
class OutfitGenerationController extends GetxController {
  final OutfitRepository _repository = OutfitRepository();

  // Generation state
  final RxBool isGenerating = false.obs;
  final RxString generationStatus = ''.obs;
  final RxDouble generationProgress = 0.0.obs;
  final Rx<String?> generatedImageUrl = Rx<String?>(null);
  final RxString error = ''.obs;

  // Polling state
  bool _isPolling = false;

  @override
  void onClose() {
    _isPolling = false; // Stop any active polling
    super.onClose();
  }

  /// Generate AI visualization for an outfit
  Future<void> generateVisualization(
    String outfitId,
    List<String> itemIds, {
    String? pose,
    String? lighting,
    String? bodyProfileId,
  }) async {
    if (itemIds.isEmpty) {
      NotificationService.instance.showWarning(
        'No items selected for visualization',
        title: 'Cannot Generate',
      );
      return;
    }

    try {
      isGenerating.value = true;
      generationProgress.value = 0.0;
      generationStatus.value = 'Initializing...';
      generatedImageUrl.value = null;
      error.value = '';

      // Convert itemIds to list of maps
      final itemsData = itemIds.map((id) => {'id': id}).toList();

      final result = await _repository.generateOutfitVisualization(
        itemsData,
        style: pose,
        background: lighting,
      );

      if (result.status == 'failed') {
        isGenerating.value = false;
        NotificationService.instance.showError(
          result.error ?? 'An error occurred',
          title: 'Generation Failed',
        );
        return;
      }

      if (result.status == 'completed' &&
          (result.imageUrl != null || result.imageBase64 != null)) {
        generatedImageUrl.value = result.imageUrl ??
            (result.imageBase64 != null
                ? 'data:image/png;base64,${result.imageBase64}'
                : null);
        isGenerating.value = false;
        NotificationService.instance.showSuccess(
          'Your outfit has been generated',
          title: 'Complete!',
        );
        return;
      }

      // Poll for status (for tracked generations)
      await _pollGenerationStatus(result.id);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      isGenerating.value = false;
      NotificationService.instance.showError(
        error.value,
        title: 'Generation Failed',
      );
    }
  }

  Future<void> _pollGenerationStatus(String taskId) async {
    const maxAttempts = 120; // 2 minutes
    var attempts = 0;
    _isPolling = true;

    while (_isPolling && attempts < maxAttempts) {
      attempts++;
      await Future.delayed(const Duration(seconds: 1));

      if (!_isPolling) break; // Check if we should stop

      try {
        final status = await _repository.getGenerationStatus(taskId);
        generationProgress.value = status.progress ?? 0.0;
        generationStatus.value = status.message ?? 'Processing...';

        if (status.status == 'completed') {
          generatedImageUrl.value = status.imageUrl;
          isGenerating.value = false;
          _isPolling = false;

          // Refresh outfits list to get the updated image
          if (Get.isRegistered<OutfitListController>()) {
            await Get.find<OutfitListController>().fetchOutfits(refresh: true);
          }

          NotificationService.instance.showSuccess(
            'Your outfit has been generated',
            title: 'Complete!',
          );
          return;
        }

        if (status.status == 'failed') {
          isGenerating.value = false;
          _isPolling = false;
          NotificationService.instance.showError(
            status.error ?? 'An error occurred',
            title: 'Generation Failed',
          );
          return;
        }
      } catch (e) {
        isGenerating.value = false;
        _isPolling = false;
        return;
      }
    }

    // Timeout
    if (_isPolling) {
      isGenerating.value = false;
      _isPolling = false;
      NotificationService.instance.showWarning(
        'Generation is taking longer than expected',
        title: 'Timeout',
      );
    }
  }

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
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Reset generation state
  void reset() {
    _isPolling = false;
    isGenerating.value = false;
    generationStatus.value = '';
    generationProgress.value = 0.0;
    generatedImageUrl.value = null;
    error.value = '';
  }

  /// Cancel ongoing generation
  void cancelGeneration() {
    _isPolling = false;
    isGenerating.value = false;
    generationStatus.value = 'Cancelled';
  }
}
