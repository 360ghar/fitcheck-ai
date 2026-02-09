import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';

/// Reusable shimmer/skeleton widgets for loading states

/// Basic shimmer box - a rectangular placeholder with shimmer effect
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: tokens.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConstants.radius8,
          ),
        ),
      ),
    );
  }
}

/// Shimmer card - matches the style of grid items (wardrobe, outfits)
class ShimmerGridItem extends StatelessWidget {
  const ShimmerGridItem({
    super.key,
    this.aspectRatio = 0.75,
  });

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: tokens.cardBorderColor),
        ),
      ),
    );
  }
}

/// Shimmer list tile - for list items with icon, title, subtitle
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  });

  final bool hasLeading;
  final bool hasSubtitle;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tokens.cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: AppConstants.spacing8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tokens.cardColor.withOpacity(0.6),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radius8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: AppConstants.spacing12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tokens.cardColor.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer card - for stat cards or info cards
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 100,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: tokens.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: tokens.cardBorderColor),
        ),
      ),
    );
  }
}

/// Sliver grid of shimmer items for loading grids
class ShimmerGridLoader extends StatelessWidget {
  const ShimmerGridLoader({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 0.75,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing ?? AppConstants.spacing12,
        crossAxisSpacing: crossAxisSpacing ?? AppConstants.spacing12,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ShimmerGridItem(),
        childCount: itemCount,
      ),
    );
  }
}

/// Sliver list of shimmer items for loading lists
class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  });

  final int itemCount;
  final bool hasLeading;
  final bool hasSubtitle;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ShimmerListTile(
          hasLeading: hasLeading,
          hasSubtitle: hasSubtitle,
          hasTrailing: hasTrailing,
        ),
        childCount: itemCount,
      ),
    );
  }
}

/// Non-sliver grid loader (for use in regular Column/ListView)
class ShimmerGridLoaderBox extends StatelessWidget {
  const ShimmerGridLoaderBox({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 0.75,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing ?? AppConstants.spacing12,
        crossAxisSpacing: crossAxisSpacing ?? AppConstants.spacing12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerGridItem(),
    );
  }
}

/// Profile header skeleton
class ShimmerProfileHeader extends StatelessWidget {
  const ShimmerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tokens.cardColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats row skeleton (for dashboard stats)
class ShimmerStatsRow extends StatelessWidget {
  const ShimmerStatsRow({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Row(
        children: List.generate(
          itemCount,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : AppConstants.spacing8,
                right: index == itemCount - 1 ? 0 : AppConstants.spacing8,
              ),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: tokens.cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  border: Border.all(color: tokens.cardBorderColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Detail page skeleton (image + info section)
class ShimmerDetailPage extends StatelessWidget {
  const ShimmerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: double.infinity,
              height: 300,
              color: tokens.cardColor.withOpacity(0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  // Subtitle
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  // Info cards
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading indicator for bottom of lists (for "load more")
class LoadingMoreIndicator extends StatelessWidget {
  const LoadingMoreIndicator({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Sliver loading more indicator
class SliverLoadingMoreIndicator extends StatelessWidget {
  const SliverLoadingMoreIndicator({
    super.key,
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LoadingMoreIndicator(isLoading: isLoading),
    );
  }
}
