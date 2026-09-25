import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';
import 'bounding_box_painter.dart';

/// A generated studio photo from a `data:` URI or a URL. A data URI is
/// decoded once per value, not on every rebuild.
class GeneratedImage extends StatefulWidget {
  const GeneratedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.cacheWidth = 480,
    this.fallback,
  });

  final String url;
  final BoxFit fit;
  final int cacheWidth;

  /// Shown when the image cannot be decoded or loaded.
  final Widget? fallback;

  @override
  State<GeneratedImage> createState() => _GeneratedImageState();
}

class _GeneratedImageState extends State<GeneratedImage> {
  Uint8List? _bytes;
  bool _badData = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(GeneratedImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _decode();
  }

  void _decode() {
    _bytes = null;
    _badData = false;
    if (!widget.url.startsWith('data:image')) return;
    try {
      _bytes = base64Decode(widget.url.split(',').last);
    } catch (_) {
      _badData = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallback =
        widget.fallback ??
        Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: PaperTokens.of(context).textMuted,
          ),
        );
    if (_badData) return fallback;
    final bytes = _bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return AppNetworkImage(
      widget.url,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

/// One found piece on the batch review page. Tapping the card includes or
/// skips it.
class ExtractedItemCard extends StatelessWidget {
  const ExtractedItemCard({
    super.key,
    required this.item,
    required this.sourceImagePath,
    this.onToggleSelection,
    this.onRemove,
  });

  final BatchExtractedItem item;
  final String sourceImagePath;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final included = item.includeInWardrobe && item.isSelected;
    final meta = [
      item.category.displayName,
      if (item.colors.isNotEmpty) item.colors.take(2).join(', '),
    ].join(' · ');
    final person = item.personLabel?.trim() ?? '';

    return PaperSurface(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      grain: false,
      lift: included ? 1 : 0.4,
      color: included ? tokens.stock.card : tokens.stock.sunk,
      onTap: onToggleSelection,
      semanticLabel: '${item.name}, ${included ? 'included' : 'skipped'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: included ? 1 : 0.5,
                  child: ColoredBox(
                    color: tokens.stock.sunk,
                    child: item.generatedImageUrl != null
                        ? GeneratedImage(
                            url: item.generatedImageUrl!,
                            fallback: _source(tokens),
                          )
                        : _source(tokens),
                  ),
                ),
                if (item.status == BatchItemStatus.generating)
                  const ColoredBox(
                    color: Colors.black45,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                if (onRemove != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      tooltip: 'Remove piece',
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing12,
              AppConstants.spacing8,
              AppConstants.spacing4,
              AppConstants.spacing8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      if (person.isNotEmpty)
                        Text(
                          item.isCurrentUserPerson &&
                                  person.toLowerCase() != 'you'
                              ? '$person (you)'
                              : person,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      if (item.status == BatchItemStatus.failed)
                        Text(
                          'No studio photo. Your photo is used.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: tokens.warning,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onToggleSelection != null)
                  SizedBox.square(
                    dimension: 44,
                    child: Checkbox(
                      value: included,
                      onChanged: (_) => onToggleSelection!(),
                      semanticLabel: included
                          ? 'Skip ${item.name}'
                          : 'Include ${item.name}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _source(PaperTokens tokens) {
    if (sourceImagePath.isEmpty) {
      return Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: tokens.textMuted,
        ),
      );
    }
    return BoundingBoxOverlay(
      boundingBoxes: [
        if (item.boundingBox != null)
          {...item.boundingBox!, 'label': item.name},
      ],
      showLabels: false,
      imageFilePath: sourceImagePath,
      child: Image.file(
        File(sourceImagePath),
        fit: BoxFit.contain,
        cacheWidth: 480,
        errorBuilder: (_, _, _) => Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: tokens.textMuted,
          ),
        ),
      ),
    );
  }
}
