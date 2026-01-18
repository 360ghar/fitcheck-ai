import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/item_add_controller.dart';
import '../models/item_model.dart';

/// Widget showing AI extraction progress and results
class AIExtractionWidget extends StatefulWidget {
  final File imageFile;
  final SyncExtractionResponse? extractionResult;
  final bool isProcessing;
  final bool isSaving;
  final bool isGeneratingImages;
  final double generationProgress;
  final String currentGenerationStatus;
  final VoidCallback onRetake;
  final Function(List<DetectedItemData>) onSaveExtracted;
  final VoidCallback onSaveGenerated;
  final VoidCallback onManualEntry;

  const AIExtractionWidget({
    super.key,
    required this.imageFile,
    required this.extractionResult,
    required this.isProcessing,
    this.isSaving = false,
    this.isGeneratingImages = false,
    this.generationProgress = 0,
    this.currentGenerationStatus = '',
    required this.onRetake,
    required this.onSaveExtracted,
    required this.onSaveGenerated,
    required this.onManualEntry,
  });

  @override
  State<AIExtractionWidget> createState() => _AIExtractionWidgetState();
}

class _AIExtractionWidgetState extends State<AIExtractionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final controller = Get.find<ItemAddController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius16),
            child: Image.file(
              widget.imageFile,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: AppConstants.spacing24),

          // Status section
          if (widget.isSaving)
            _buildSavingStatus(tokens)
          else if (widget.isGeneratingImages)
            _buildGeneratingStatus(tokens, controller)
          else if (widget.isProcessing)
            _buildProcessingStatus(tokens)
          else if (controller.generatedItems.isNotEmpty)
            _buildGeneratedItemsResults(tokens, controller)
          else if (widget.extractionResult?.items != null &&
              widget.extractionResult!.items!.isNotEmpty)
            _buildExtractionResults(tokens)
          else
            _buildNoResults(tokens),
        ],
      ),
    );
  }

  Widget _buildSavingStatus(AppUiTokens tokens) {
    return Column(
      children: [
        // Animated progress indicator
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.save,
                          size: 32,
                          color: Colors.green.withOpacity(0.7),
                        ),
                      ),
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 3,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  'Saving to Wardrobe...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Please wait while we save your items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGeneratingStatus(AppUiTokens tokens, ItemAddController controller) {
    return Column(
      children: [
        // Animated progress indicator with image generation theme
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: 32,
                          color: Colors.purple.withOpacity(0.7),
                        ),
                      ),
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 3,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  'Creating Product Images...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  widget.currentGenerationStatus.isEmpty
                      ? 'AI is generating catalog-style images of your clothes'
                      : widget.currentGenerationStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (controller.generatedItems.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    '${controller.generatedItems.length} items ready',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProcessingStatus(AppUiTokens tokens) {
    return Column(
      children: [
        // Animated progress indicator
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.brandColor.withOpacity(0.2),
                      width: 4,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.search,
                          size: 32,
                          color: tokens.brandColor.withOpacity(0.5),
                        ),
                      ),
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 3,
                          color: tokens.brandColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                Shimmer.fromColors(
                  baseColor: tokens.textMuted.withOpacity(0.5),
                  highlightColor: tokens.textMuted.withOpacity(0.8),
                  period: const Duration(milliseconds: 1200),
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        decoration: BoxDecoration(
                          color: tokens.cardColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Container(
                        width: 150,
                        height: 16,
                        decoration: BoxDecoration(
                          color: tokens.cardColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppConstants.spacing24),

        // Cancel button
        OutlinedButton.icon(
          onPressed: widget.onRetake,
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildExtractionResults(AppUiTokens tokens) {
    final items = widget.extractionResult!.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success header
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items Detected!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Found ${items.length} item(s) in your photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Extracted items list
        Text(
          'Detected Items',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),

        ...List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: DetectedItemDataCard(item: item, index: index + 1),
          );
        }),

        const SizedBox(height: AppConstants.spacing16),

        // Info text
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing12),
          decoration: BoxDecoration(
            color: tokens.brandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: tokens.brandColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Text(
                  'AI will now create catalog-style product images for each item',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.brandColor,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing24),

        // Action buttons
        ElevatedButton.icon(
          onPressed: widget.isSaving ? null : () => widget.onSaveExtracted(items),
          icon: widget.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: Text(widget.isSaving ? 'Saving...' : 'Add to Wardrobe'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: AppConstants.spacing8),

        OutlinedButton.icon(
          onPressed: widget.isSaving ? null : widget.onManualEntry,
          icon: const Icon(Icons.edit),
          label: const Text('Enter Manually Instead'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: AppConstants.spacing8),

        TextButton.icon(
          onPressed: widget.isSaving ? null : widget.onRetake,
          icon: const Icon(Icons.refresh),
          label: const Text('Start Over'),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedItemsResults(AppUiTokens tokens, ItemAddController controller) {
    final generatedItems = controller.generatedItems;
    final successfulItems = generatedItems.where((i) => i.generatedImageUrl != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success header with purple theme
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple[700]),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Images Generated!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${successfulItems.length} of ${generatedItems.length} images created',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.purple[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Generated items grid
        Text(
          'Generated Product Images',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),

        // Grid of generated images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppConstants.spacing12,
            crossAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 1,
          ),
          itemCount: generatedItems.length,
          itemBuilder: (context, index) {
            final item = generatedItems[index];
            return _GeneratedItemCard(item: item, index: index + 1);
          },
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Action buttons
        ElevatedButton.icon(
          onPressed: widget.isSaving ? null : widget.onSaveGenerated,
          icon: widget.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(widget.isSaving ? 'Saving...' : 'Save All Items to Wardrobe'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.purple,
          ),
        ),

        const SizedBox(height: AppConstants.spacing8),

        OutlinedButton.icon(
          onPressed: widget.isSaving ? null : widget.onRetake,
          icon: const Icon(Icons.refresh),
          label: const Text('Start Over'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults(AppUiTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.search_off,
          size: 64,
          color: tokens.textMuted,
        ),
        const SizedBox(height: AppConstants.spacing16),
        Text(
          'No Items Detected',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          'We couldn\'t detect any items in this photo. You can enter the details manually.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.textMuted,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacing24),

        ElevatedButton.icon(
          onPressed: widget.onManualEntry,
          icon: const Icon(Icons.edit),
          label: const Text('Enter Details Manually'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: AppConstants.spacing8),

        OutlinedButton.icon(
          onPressed: widget.onRetake,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Different Photo'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}

/// Card showing a single detected item (pre-generation)
class DetectedItemDataCard extends StatelessWidget {
  final DetectedItemData item;
  final int index;

  const DetectedItemDataCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tokens.brandColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subCategory ?? item.category,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    _buildChip(context, item.category, tokens),
                    if (item.colors != null && item.colors!.isNotEmpty) ...[
                      const SizedBox(width: AppConstants.spacing4),
                      _buildChip(context, item.colors!.first, tokens),
                    ],
                  ],
                ),
                if (item.material != null || item.pattern != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    '${item.material ?? ''}${item.material != null && item.pattern != null ? ' / ' : ''}${item.pattern ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),

          // Checkmark icon
          Icon(
            Icons.check_circle_outline,
            color: tokens.brandColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: AppConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: tokens.brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radius8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.brandColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// Card showing a generated item with product image
class _GeneratedItemCard extends StatelessWidget {
  final DetectedItemDataWithImage item;
  final int index;

  const _GeneratedItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    if (item.generatedImageUrl == null) {
      // Failed generation
      return Container(
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              item.name ?? item.subCategory ?? item.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (item.generationError != null) ...[
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'Failed to generate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontSize: 10,
                    ),
                ),
              ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Stack(
          children: [
            // Generated product image
            Positioned.fill(
              child: _buildGeneratedImage(tokens, item.generatedImageUrl!),
            ),

            // Gradient overlay at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Item info at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name ?? item.subCategory ?? item.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.colors != null && item.colors!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.colors!.take(2).join(', '),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Index badge at top
            Positioned(
              top: AppConstants.spacing8,
              left: AppConstants.spacing8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Checkmark at top right
            Positioned(
              top: AppConstants.spacing8,
              right: AppConstants.spacing8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an image widget that handles both data URLs and network URLs.
  Widget _buildGeneratedImage(AppUiTokens tokens, String url) {
    final isDataUrl = url.startsWith('data:image');

    Widget errorWidget() => Container(
      color: tokens.cardColor,
      child: Icon(
        Icons.broken_image,
        color: tokens.textMuted,
      ),
    );

    if (isDataUrl) {
      try {
        final base64Data = url.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => errorWidget(),
        );
      } catch (e) {
        return errorWidget();
      }
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => errorWidget(),
    );
  }
}
