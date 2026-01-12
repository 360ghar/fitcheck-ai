import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';

/// Represents the current state of async data
enum AsyncStatus {
  initial,
  loading,
  success,
  error,
  empty,
}

/// A widget that displays different UI states for async operations
/// Handles loading, error, empty, and success states consistently
class AsyncStateWidget<T> extends StatelessWidget {
  /// The current data (null if loading/error/initial)
  final T? data;

  /// Current loading state
  final bool isLoading;

  /// Error message (null if no error)
  final String? error;

  /// Builder for success state with data
  final Widget Function(BuildContext context, T data) builder;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Optional custom error widget builder
  final Widget Function(BuildContext context, String error, VoidCallback? retry)?
      errorBuilder;

  /// Optional custom empty state widget
  final Widget? emptyWidget;

  /// Callback for retry action on error
  final VoidCallback? onRetry;

  /// Check if data is considered empty
  final bool Function(T data)? isEmpty;

  /// Message to show when data is empty
  final String emptyMessage;

  /// Whether to show shimmer loading effect
  final bool useShimmer;

  /// Number of shimmer items to show
  final int shimmerItemCount;

  const AsyncStateWidget({
    super.key,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'No data available',
    this.useShimmer = true,
    this.shimmerItemCount = 3,
  });

  AsyncStatus get status {
    if (isLoading && data == null) return AsyncStatus.loading;
    if (error != null && error!.isNotEmpty) return AsyncStatus.error;
    if (data == null) return AsyncStatus.initial;
    if (isEmpty?.call(data as T) ?? false) return AsyncStatus.empty;
    return AsyncStatus.success;
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AsyncStatus.initial:
      case AsyncStatus.loading:
        return loadingWidget ?? _buildDefaultLoading(context);

      case AsyncStatus.error:
        return errorBuilder?.call(context, error!, onRetry) ??
            _buildDefaultError(context);

      case AsyncStatus.empty:
        return emptyWidget ?? _buildDefaultEmpty(context);

      case AsyncStatus.success:
        return builder(context, data as T);
    }
  }

  Widget _buildDefaultLoading(BuildContext context) {
    if (!useShimmer) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor,
      highlightColor: tokens.cardBorderColor,
      child: Column(
        children: List.generate(
          shimmerItemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: tokens.textMuted,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacing16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: tokens.textMuted,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for list-specific async state handling
class AsyncListWidget<T> extends StatelessWidget {
  final List<T>? data;
  final bool isLoading;
  final String? error;
  final Widget Function(BuildContext context, List<T> data) builder;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final Widget? emptyWidget;
  final Widget? loadingWidget;

  const AsyncListWidget({
    super.key,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.builder,
    this.onRetry,
    this.emptyMessage = 'No items found',
    this.emptyWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncStateWidget<List<T>>(
      data: data,
      isLoading: isLoading,
      error: error,
      builder: builder,
      onRetry: onRetry,
      isEmpty: (list) => list.isEmpty,
      emptyMessage: emptyMessage,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
    );
  }
}

/// Overlay loading indicator for refresh operations
class AsyncRefreshOverlay extends StatelessWidget {
  final bool isRefreshing;
  final Widget child;

  const AsyncRefreshOverlay({
    super.key,
    required this.isRefreshing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isRefreshing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
