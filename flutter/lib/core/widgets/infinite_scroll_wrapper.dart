import 'package:flutter/widgets.dart';

/// Calls [onLoadMore] when the wrapped scroll view nears its end.
///
/// Also checks after layout changes, so a first page shorter than the screen
/// (nothing to scroll) still loads the next page.
class InfiniteScrollWrapper extends StatelessWidget {
  const InfiniteScrollWrapper({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.canLoadMore,
    this.threshold = 400,
  });

  final Widget child;
  final VoidCallback onLoadMore;

  /// Read at the moment the end is reached, so a stale build value can never
  /// trigger a duplicate request.
  final bool Function() canLoadMore;

  /// Distance from the end, in pixels, at which the next page loads.
  final double threshold;

  bool _check(ScrollMetrics metrics) {
    if (metrics.axis == Axis.vertical &&
        metrics.extentAfter < threshold &&
        canLoadMore()) {
      onLoadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => n.depth == 0 && _check(n.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) => n.depth == 0 && _check(n.metrics),
        child: child,
      ),
    );
  }
}
