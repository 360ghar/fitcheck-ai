import 'package:flutter/material.dart';

/// A wrapper widget that provides infinite scroll functionality for CustomScrollView
/// Triggers the [onLoadMore] callback when scrolling near the bottom of the list
class InfiniteScrollWrapper extends StatefulWidget {
  const InfiniteScrollWrapper({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoadingMore,
    this.threshold = 200.0,
  });

  /// The scroll view to wrap (typically a CustomScrollView)
  final Widget child;

  /// Callback triggered when user scrolls near the bottom
  final VoidCallback onLoadMore;

  /// Whether there's more data to load
  final bool hasMore;

  /// Whether we're currently loading more data
  final bool isLoadingMore;

  /// Distance from the bottom to trigger load more (in pixels)
  final double threshold;

  @override
  State<InfiniteScrollWrapper> createState() => _InfiniteScrollWrapperState();
}

class _InfiniteScrollWrapperState extends State<InfiniteScrollWrapper> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final metrics = notification.metrics;

    // Check if we're near the bottom
    if (metrics.pixels >= metrics.maxScrollExtent - widget.threshold) {
      // Only trigger if:
      // 1. We have more data to load
      // 2. We're not already loading
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }

    return false;
  }
}

/// A mixin that provides scroll controller management for infinite scroll
/// Can be used with StatefulWidgets that need infinite scroll functionality
mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;

  /// Override this to provide the load more callback
  void onLoadMore();

  /// Override this to check if there's more data
  bool get hasMore;

  /// Override this to check if currently loading
  bool get isLoadingMore;

  /// Distance from bottom to trigger load more
  double get loadMoreThreshold => 200.0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - loadMoreThreshold) {
      if (hasMore && !isLoadingMore) {
        onLoadMore();
      }
    }
  }
}

/// Extension on ScrollController to easily check if near bottom
extension ScrollControllerExtension on ScrollController {
  bool isNearBottom({double threshold = 200.0}) {
    if (!hasClients) return false;
    return position.pixels >= position.maxScrollExtent - threshold;
  }
}
