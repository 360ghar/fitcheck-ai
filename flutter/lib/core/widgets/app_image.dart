import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'app_network_image.dart';
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
/// - Optional re-mint fallback: when [storagePath] and [remintUrl] are
///   provided and the primary URL fails (e.g. an expired presigned URL),
///   a fresh URL is requested and the image is retried once.
class AppImage extends StatefulWidget {
  const AppImage({
    super.key,
    this.imageUrl,
    this.fallbackUrl,
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
    this.semanticLabel,
    this.storagePath,
    this.remintUrl,
    this.cacheManager,
  });

  /// The URL of the image to display.
  final String? imageUrl;

  /// Full-size URL to retry once if [imageUrl] fails.
  ///
  /// Same contract as `AppNetworkImage.fallbackUrl`: read paths derive
  /// `thumbnail_url` with no existence check, so a missing thumb must fall
  /// back to the full size instead of rendering a broken tile. An empty
  /// string or a URL identical to [imageUrl] is dropped (see
  /// `resolveFallbackUrl`).
  final String? fallbackUrl;

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

  /// A concise description of the image for assistive technology.
  final String? semanticLabel;

  /// Durable bucket key for the object behind [imageUrl]. The API serves
  /// short-lived presigned URLs materialized from this key at read time, so
  /// a cached URL can expire while the object itself is perfectly healthy.
  /// When set together with [remintUrl], a failed load retries once with a
  /// freshly minted URL instead of rendering a permanent error tile.
  final String? storagePath;

  /// Re-mints a fresh client-fetchable URL for [storagePath] (e.g. via the
  /// backend's `/api/v1/images/presigned` endpoint). Returns null when no
  /// fresh URL could be obtained.
  final Future<String?> Function(String storagePath)? remintUrl;

  /// Optional cache manager for the network image. Defaults to the global
  /// [DefaultCacheManager]; injectable so tests can use an in-memory cache
  /// and a mock HTTP client instead of platform storage.
  final BaseCacheManager? cacheManager;

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  /// The URL currently being rendered. Starts as [AppImage.imageUrl]; after
  /// a failed load with a [AppImage.storagePath] it is swapped for a freshly
  /// minted URL once.
  String? _activeUrl;

  /// Whether the [AppImage.fallbackUrl] retry has already been attempted.
  bool _usingFallback = false;

  /// Whether the re-mint fallback has already been attempted. A single retry
  /// per URL is enough: if the fresh URL fails too, the object is genuinely
  /// unreadable and an error tile is the honest result.
  bool _reminted = false;
  int _sourceRevision = 0;

  @override
  void initState() {
    super.initState();
    _resolveActiveUrl();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl ||
        oldWidget.storagePath != widget.storagePath) {
      // A stale failure must never suppress a freshly-configured URL.
      _reminted = false;
      _usingFallback = false;
      _resolveActiveUrl();
    }
  }

  /// Picks the URL to render: the fallback once the primary has failed and a
  /// distinct fallback exists (identical/empty fallbacks are dropped — see
  /// [resolveFallbackUrl]).
  void _resolveActiveUrl() {
    _sourceRevision++;
    final fallback = resolveFallbackUrl(
      widget.imageUrl ?? '',
      widget.fallbackUrl,
    );
    if (_usingFallback && fallback != null) {
      _activeUrl = fallback;
    } else {
      _usingFallback = false;
      _activeUrl = widget.imageUrl;
    }
  }

  /// Retries the load once with [AppImage.fallbackUrl]. Mirrors
  /// AppNetworkImage's fallback swap: one retry per configuration, scheduled
  /// from the error builder because it runs during build.
  void _retryWithFallback() {
    if (!mounted || _usingFallback) return;
    setState(() {
      _usingFallback = true;
      _resolveActiveUrl();
    });
  }

  Future<void> _remintAndRetry() async {
    if (_reminted || widget.storagePath == null || widget.remintUrl == null) {
      return;
    }
    _reminted = true;
    final revision = _sourceRevision;
    try {
      final freshUrl = await widget.remintUrl!(widget.storagePath!);
      if (!mounted ||
          revision != _sourceRevision ||
          freshUrl == null ||
          freshUrl.isEmpty) {
        return;
      }
      setState(() {
        _activeUrl = freshUrl;
      });
    } catch (_) {
      // The error tile already stands; a re-mint failure must not crash or
      // loop. The failed load is surfaced through the error widget.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final bgColor =
        widget.backgroundColor ?? tokens.cardColor.withValues(alpha: 0.3);

    Widget imageWidget;

    if (_activeUrl == null || _activeUrl!.isEmpty) {
      imageWidget = _buildErrorWidget(context, tokens);
    } else if (_activeUrl!.startsWith('data:image')) {
      imageWidget = AppNetworkImage(
        _activeUrl!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        cacheWidth: widget.memCacheWidth,
        cacheHeight: widget.memCacheHeight,
        fallbackUrl: widget.fallbackUrl,
        errorWidget: (_, _, _) =>
            widget.errorWidget ?? _buildErrorWidget(context, tokens),
      );
    } else {
      final canRemint = widget.storagePath != null && widget.remintUrl != null;
      final revision = _sourceRevision;
      imageWidget = CachedNetworkImage(
        imageUrl: _activeUrl!,
        cacheManager: widget.cacheManager,
        // Key on origin+path so a rotating presigned signature does not make
        // every load a cache miss — see stableCacheKey in app_network_image.dart.
        cacheKey: stableCacheKey(_activeUrl!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        memCacheWidth: widget.memCacheWidth,
        memCacheHeight: widget.memCacheHeight,
        // Worker-mode CDN URLs require the bearer token; presigned URLs must
        // NOT receive one (signature validation rejects it) — see
        // authHeadersForUrl in app_network_image.dart.
        httpHeaders: authHeadersForUrl(_activeUrl!),
        placeholder: (context, url) =>
            widget.placeholder ?? _buildPlaceholder(context, tokens),
        errorWidget: (context, url, error) {
          // A distinct fallback URL gets one retry before the re-mint: a
          // missing `thumbnail_url` object is recovered by the full size.
          final fallback = resolveFallbackUrl(
            _activeUrl ?? '',
            widget.fallbackUrl,
          );
          if (!_usingFallback && fallback != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && revision == _sourceRevision) _retryWithFallback();
            });
            return widget.placeholder ?? _buildPlaceholder(context, tokens);
          }
          if (canRemint && !_reminted) {
            // errorWidget runs during build; schedule the re-mint + retry
            // instead of calling setState inline.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && revision == _sourceRevision) _remintAndRetry();
            });
          }
          return widget.errorWidget ?? _buildErrorWidget(context, tokens);
        },
        imageBuilder: (context, imageProvider) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: bgColor,
            child: Image(image: imageProvider, fit: widget.fit),
          );
        },
      );
    }

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    if (widget.enableZoom && _activeUrl != null && _activeUrl!.isNotEmpty) {
      imageWidget = Semantics(
        button: true,
        label: widget.semanticLabel == null
            ? 'View full image'
            : 'View full image: ${widget.semanticLabel}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: () => _openViewer(context),
            child: imageWidget,
          ),
        ),
      );
    } else {
      // No callsite currently passes a semanticLabel, so labeling every
      // thumbnail "Image" would just spam screen-reader navigation. Only add
      // image semantics when a meaningful label exists; otherwise exclude the
      // unlabeled image from the semantics tree entirely.
      imageWidget = widget.semanticLabel == null
          ? ExcludeSemantics(child: imageWidget)
          : Semantics(
              image: true,
              label: widget.semanticLabel,
              child: imageWidget,
            );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.borderRadius == null ? bgColor : null,
      decoration: widget.borderRadius != null
          ? BoxDecoration(color: bgColor, borderRadius: widget.borderRadius)
          : null,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(BuildContext context, AppUiTokens tokens) {
    final loadingSurface = Container(
      width: widget.width,
      height: widget.height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return ExcludeSemantics(child: loadingSurface);
    }

    return ExcludeSemantics(
      child: Shimmer.fromColors(
        baseColor: tokens.cardBorderColor,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        enabled: TickerMode.valuesOf(context).enabled,
        period: const Duration(milliseconds: 1200),
        child: loadingSurface,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, AppUiTokens tokens) {
    return Semantics(
      image: true,
      label: widget.semanticLabel == null
          ? 'Image unavailable'
          : '${widget.semanticLabel} is unavailable',
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(widget.errorIcon, size: 48, color: tokens.textMuted),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    final urls = List<String>.from(widget.galleryUrls ?? [_activeUrl!]);
    if (urls.isNotEmpty && widget.galleryUrls != null) {
      // The tile may have re-minted a fresh URL after the original failed
      // (presigned URLs expire after 1h); the viewer must zoom the URL the
      // tile is actually showing, not the stale gallery entry.
      final index = widget.initialGalleryIndex.clamp(0, urls.length - 1);
      urls[index] = _activeUrl!;
    }
    AppImageViewer.show(
      context,
      imageUrls: urls,
      initialIndex: widget.initialGalleryIndex,
    );
  }
}
