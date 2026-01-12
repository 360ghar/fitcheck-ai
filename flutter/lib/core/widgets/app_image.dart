import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'app_ui.dart';

/// A reusable image widget that displays images with consistent styling.
///
/// Features:
/// - Uses BoxFit.contain by default to preserve aspect ratio (no stretching)
/// - Centers image with configurable background color for empty space
/// - Shimmer placeholder during loading
/// - Consistent error widget
/// - Optional tap-to-zoom functionality
/// - Support for image galleries
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.enableZoom = true,
    this.backgroundColor,
    this.memCacheWidth,
    this.memCacheHeight,
    this.borderRadius,
    this.galleryUrls,
    this.initialGalleryIndex = 0,
    this.errorIcon = Icons.image_not_supported_outlined,
  });

  /// The URL of the image to display.
  final String? imageUrl;

  /// How the image should be inscribed into the box.
  /// Defaults to [BoxFit.contain] to preserve aspect ratio.
  final BoxFit fit;

  /// The width of the image container.
  final double? width;

  /// The height of the image container.
  final double? height;

  /// Custom placeholder widget to show while loading.
  final Widget? placeholder;

  /// Custom error widget to show on load failure.
  final Widget? errorWidget;

  /// Whether tapping the image opens the full-screen viewer.
  final bool enableZoom;

  /// Background color for empty space around the image.
  final Color? backgroundColor;

  /// Memory cache width for optimization.
  final int? memCacheWidth;

  /// Memory cache height for optimization.
  final int? memCacheHeight;

  /// Border radius for the image.
  final BorderRadius? borderRadius;

  /// List of image URLs for gallery mode.
  final List<String>? galleryUrls;

  /// Initial index when opening gallery.
  final int initialGalleryIndex;

  /// Icon to show on error.
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final bgColor = backgroundColor ?? tokens.cardColor.withOpacity(0.3);

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.isEmpty) {
      imageWidget = _buildErrorWidget(context, tokens);
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) =>
            placeholder ?? _buildPlaceholder(context, tokens),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(context, tokens),
        imageBuilder: (context, imageProvider) {
          return Container(
            width: width,
            height: height,
            color: bgColor,
            child: Image(
              image: imageProvider,
              fit: fit,
            ),
          );
        },
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (enableZoom && imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = GestureDetector(
        onTap: () => _openViewer(context),
        child: imageWidget,
      );
    }

    return Container(
      width: width,
      height: height,
      color: borderRadius == null ? bgColor : null,
      decoration: borderRadius != null
          ? BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            )
          : null,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(BuildContext context, AppUiTokens tokens) {
    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        color: tokens.cardColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, AppUiTokens tokens) {
    return Container(
      width: width,
      height: height,
      color: tokens.cardColor.withOpacity(0.3),
      child: Center(
        child: Icon(
          errorIcon,
          size: 48,
          color: tokens.textMuted,
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    final urls = galleryUrls ?? [imageUrl!];
    AppImageViewer.show(
      context,
      imageUrls: urls,
      initialIndex: initialGalleryIndex,
    );
  }
}

/// A variant of AppImage that fills its container while maintaining aspect ratio.
///
/// Uses BoxFit.cover but still supports zoom functionality.
class AppImageCover extends StatelessWidget {
  const AppImageCover({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.enableZoom = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.borderRadius,
    this.galleryUrls,
    this.initialGalleryIndex = 0,
    this.errorIcon = Icons.image_not_supported_outlined,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableZoom;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final BorderRadius? borderRadius;
  final List<String>? galleryUrls;
  final int initialGalleryIndex;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    return AppImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: placeholder,
      errorWidget: errorWidget,
      enableZoom: enableZoom,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      borderRadius: borderRadius,
      galleryUrls: galleryUrls,
      initialGalleryIndex: initialGalleryIndex,
      errorIcon: errorIcon,
    );
  }
}
