import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/item_model.dart';
import '../utils/extraction_image_utils.dart';

/// Widget showing AI extraction progress and results
class AIExtractionWidget extends StatefulWidget {
  final File imageFile;
  final ExtractionResponse? extractionResult;
  final bool isProcessing;
  final bool isSaving;
  final VoidCallback onRetake;
  final Function(List<ExtractedItem>) onSaveExtracted;
  final VoidCallback onManualEntry;

  const AIExtractionWidget({
    super.key,
    required this.imageFile,
    required this.extractionResult,
    required this.isProcessing,
    required this.isSaving,
    required this.onRetake,
    required this.onSaveExtracted,
    required this.onManualEntry,
  });

  @override
  State<AIExtractionWidget> createState() => _AIExtractionWidgetState();
}

class _AIExtractionWidgetState extends State<AIExtractionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  final Set<int> _selectedIndices = <int>{};
  final Map<String, Future<Uint8List?>> _previewFutures = {};
  Future<img.Image?>? _decodedImageFuture;
  String? _decodedImagePath;

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
    _syncSelection();
  }

  @override
  void didUpdateWidget(covariant AIExtractionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path ||
        oldWidget.extractionResult?.id != widget.extractionResult?.id) {
      _resetPreviewCache();
      _syncSelection();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _syncSelection() {
    final items = widget.extractionResult?.items;
    _selectedIndices
      ..clear()
      ..addAll(
        items == null ? const [] : List<int>.generate(items.length, (i) => i),
      );
  }

  void _resetPreviewCache() {
    _previewFutures.clear();
    _decodedImageFuture = null;
    _decodedImagePath = null;
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  Future<img.Image?> _getDecodedImage() {
    if (_decodedImageFuture != null &&
        _decodedImagePath == widget.imageFile.path) {
      return _decodedImageFuture!;
    }
    _decodedImagePath = widget.imageFile.path;
    _decodedImageFuture = widget.imageFile
        .readAsBytes()
        .then(ExtractionImageUtils.decodeImage);
    return _decodedImageFuture!;
  }

  String _previewKey(ExtractedItem item, int index) {
    final box = item.boundingBox;
    final boxKey = box == null
        ? 'full'
        : '${box['x']}-${box['y']}-${box['width']}-${box['height']}';
    return '${widget.imageFile.path}::$index::$boxKey';
  }

  Future<Uint8List?> _getPreviewFuture(ExtractedItem item, int index) {
    final key = _previewKey(item, index);
    return _previewFutures.putIfAbsent(
      key,
      () => _buildPreviewBytes(item),
    );
  }

  Future<Uint8List?> _buildPreviewBytes(ExtractedItem item) async {
    if (item.boundingBox == null || item.boundingBox!.isEmpty) {
      return null;
    }
    final decoded = await _getDecodedImage();
    if (decoded == null) {
      return null;
    }
    final cropped = ExtractionImageUtils.cropImage(decoded, item.boundingBox);
    if (cropped == null) {
      return null;
    }
    final resized = ExtractionImageUtils.resizeIfNeeded(
      cropped,
      ExtractionImageUtils.defaultPreviewMaxSide,
    );
    return ExtractionImageUtils.encodeJpg(resized, quality: 85);
  }

  Widget _buildItemPreview(
    ExtractedItem item,
    int index,
    AppUiTokens tokens,
  ) {
    const previewSize = 72.0;

    return SizedBox(
      width: previewSize,
      height: previewSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              child: FutureBuilder<Uint8List?>(
                future: _getPreviewFuture(item, index),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildPreviewPlaceholder(tokens);
                  }
                  final bytes = snapshot.data;
                  if (bytes != null) {
                    return Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                    );
                  }
                  return Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPreviewPlaceholder(tokens, showIcon: true),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: _buildIndexBadge(index + 1, tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPlaceholder(AppUiTokens tokens, {bool showIcon = false}) {
    return Container(
      color: tokens.cardColor.withOpacity(0.4),
      child: showIcon
          ? Icon(
              Icons.image_outlined,
              color: tokens.textMuted,
              size: 24,
            )
          : null,
    );
  }

  Widget _buildIndexBadge(int index, AppUiTokens tokens) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: tokens.brandColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

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
          if (widget.isProcessing)
            _buildProcessingStatus(tokens)
          else if (widget.extractionResult?.items != null &&
              widget.extractionResult!.items!.isNotEmpty)
            _buildExtractionResults(tokens)
          else
            _buildNoResults(tokens),
        ],
      ),
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
                          Icons.auto_awesome,
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
    final items = widget.extractionResult!.items!;
    final selectedItems = items
        .asMap()
        .entries
        .where((entry) => _selectedIndices.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    final selectedCount = selectedItems.length;

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
                    if (selectedCount != items.length)
                      Text(
                        '$selectedCount selected',
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
        const SizedBox(height: AppConstants.spacing4),
        Text(
          'Tap items to include or exclude before saving',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),

        ...List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: ExtractedItemCard(
              item: item,
              index: index + 1,
              isSelected: _selectedIndices.contains(index),
              onTap: () => _toggleSelection(index),
              preview: _buildItemPreview(item, index, tokens),
            ),
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
                Icons.info_outline,
                color: tokens.brandColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Text(
                  'You can edit item details after saving',
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
          onPressed: selectedCount == 0 || widget.isSaving
              ? null
              : () => widget.onSaveExtracted(selectedItems),
          icon: widget.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(
            widget.isSaving
                ? 'Saving...'
                : selectedCount == items.length
                    ? 'Add to Wardrobe'
                    : selectedCount == 1
                        ? 'Add 1 Item'
                        : 'Add $selectedCount Items',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: AppConstants.spacing8),

        OutlinedButton.icon(
          onPressed: widget.isSaving ? null : widget.onManualEntry,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Details Manually'),
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

/// Card showing a single extracted item
class ExtractedItemCard extends StatelessWidget {
  final ExtractedItem item;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? preview;

  const ExtractedItemCard({
    super.key,
    required this.item,
    required this.index,
    this.isSelected = true,
    this.onTap,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final selectionColor = isSelected ? tokens.brandColor : tokens.textMuted;
    final contentOpacity = isSelected ? 1.0 : 0.55;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        child: AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing12),
          child: Row(
            children: [
              Opacity(
                opacity: contentOpacity,
                child: preview ?? _buildIndexBadge(context, tokens),
              ),

              const SizedBox(width: AppConstants.spacing12),

              // Item details
              Expanded(
                child: Opacity(
                  opacity: contentOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Row(
                        children: [
                          _buildChip(context, item.category.displayName, tokens),
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
              ),

              // Selection icon
              Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selectionColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndexBadge(BuildContext context, AppUiTokens tokens) {
    return Container(
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
