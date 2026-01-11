import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../constants/app_constants.dart';

/// A full-screen image viewer with zoom and pan capabilities.
///
/// Features:
/// - Pinch-to-zoom using PhotoView
/// - Pan/drag support
/// - Swipe down to dismiss
/// - Tap outside to dismiss
/// - Close button
/// - Gallery mode with page indicators
class AppImageViewer extends StatefulWidget {
  const AppImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  /// List of image URLs to display.
  final List<String> imageUrls;

  /// Initial index when opening gallery.
  final int initialIndex;

  /// Shows the image viewer as a modal dialog.
  static void show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    if (imageUrls.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image Viewer',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  double _dragDistance = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Set status bar to light content for dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragDistance += details.delta.dy;
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    // Dismiss if dragged down more than 100 pixels or with high velocity
    if (_dragDistance > 100 || details.primaryVelocity! > 300) {
      _close();
    } else {
      setState(() {
        _dragDistance = 0;
      });
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isGallery = widget.imageUrls.length > 1;
    final opacity = (1 - (_dragDistance.abs() / 300)).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: _close,
      onVerticalDragStart: _handleVerticalDragStart,
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Image gallery
            Transform.translate(
              offset: Offset(0, _dragDistance),
              child: Opacity(
                opacity: opacity,
                child: isGallery
                    ? _buildGallery()
                    : _buildSingleImage(widget.imageUrls.first),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + AppConstants.spacing8,
              right: AppConstants.spacing16,
              child: Opacity(
                opacity: opacity,
                child: _buildCloseButton(),
              ),
            ),

            // Page indicator for galleries
            if (isGallery)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom +
                    AppConstants.spacing24,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: opacity,
                  child: _buildPageIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return Center(
      child: GestureDetector(
        onTap: () {}, // Prevent tap from propagating to dismiss
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? null
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
              color: Colors.white,
            ),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return GestureDetector(
      onTap: () {}, // Prevent tap from propagating to dismiss
      child: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        onPageChanged: _onPageChanged,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider:
                CachedNetworkImageProvider(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _close,
        padding: const EdgeInsets.all(AppConstants.spacing8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imageUrls.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? Colors.white
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
