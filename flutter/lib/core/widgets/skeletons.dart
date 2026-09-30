import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'paper.dart';

/// Loading skeletons: flat cut-outs in the stock's recessed tone.
///
/// Each composite skeleton owns one [SkeletonPulse] that slowly shifts the
/// tone between recessed and raised paper. No opacity is animated, so a
/// skeleton is always visible, and it holds still under reduced motion.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  static Animation<double>? _of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PulseScope>()
      ?.notifier;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _PulseScope(notifier: _controller, child: widget.child);
}

class _PulseScope extends InheritedNotifier<Animation<double>> {
  const _PulseScope({required super.notifier, required super.child});
}

/// One skeleton block. Pulses when inside a [SkeletonPulse].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.circle = false,
  });

  final double? width;
  final double? height;
  final double? borderRadius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final stock = PaperTokens.of(context).stock;
    final t = SkeletonPulse._of(context)?.value ?? 0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.lerp(stock.sunk, stock.tint, Curves.easeInOut.transform(t)),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle
            ? null
            : BorderRadius.circular(borderRadius ?? AppConstants.radius8),
      ),
    );
  }
}

/// Grid tile skeleton.
class SkeletonGridItem extends StatelessWidget {
  const SkeletonGridItem({super.key});

  @override
  Widget build(BuildContext context) =>
      const SkeletonBox(borderRadius: AppConstants.radius16);
}

/// List row skeleton: leading tile, title, subtitle, trailing dot.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
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
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: AppConstants.radius12,
            ),
            const SizedBox(width: AppConstants.spacing12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: double.infinity, height: 16),
                if (hasSubtitle) ...[
                  const SizedBox(height: AppConstants.spacing8),
                  const SkeletonBox(width: 120, height: 12),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: AppConstants.spacing12),
            const SkeletonBox(width: 24, height: 24, circle: true),
          ],
        ],
      ),
    );
    return SkeletonPulse._of(context) == null ? SkeletonPulse(child: row) : row;
  }
}

/// Card skeleton.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    final box = SkeletonBox(height: height, borderRadius: AppConstants.radius16);
    return SkeletonPulse._of(context) == null ? SkeletonPulse(child: box) : box;
  }
}

/// Sliver grid of skeleton tiles.
class SkeletonGridLoader extends StatelessWidget {
  const SkeletonGridLoader({
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
  Widget build(BuildContext context) => SkeletonPulse(
    child: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing ?? AppConstants.spacing12,
        crossAxisSpacing: crossAxisSpacing ?? AppConstants.spacing12,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const SkeletonGridItem(),
        childCount: itemCount,
      ),
    ),
  );
}

/// Box (non-sliver) list of skeleton rows.
class SkeletonListLoaderBox extends StatelessWidget {
  const SkeletonListLoaderBox({
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
  Widget build(BuildContext context) => SkeletonPulse(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (_) => SkeletonListTile(
          hasLeading: hasLeading,
          hasSubtitle: hasSubtitle,
          hasTrailing: hasTrailing,
        ),
      ),
    ),
  );
}

/// Box (non-sliver) grid of skeleton tiles.
class SkeletonGridLoaderBox extends StatelessWidget {
  const SkeletonGridLoaderBox({
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
  Widget build(BuildContext context) => SkeletonPulse(
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing ?? AppConstants.spacing12,
        crossAxisSpacing: crossAxisSpacing ?? AppConstants.spacing12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonGridItem(),
    ),
  );
}

/// Profile header skeleton.
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonPulse(
    child: Padding(
      padding: EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          SkeletonBox(width: 80, height: 80, circle: true),
          SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 20),
                SizedBox(height: AppConstants.spacing8),
                SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Row of stat card skeletons.
class SkeletonStatsRow extends StatelessWidget {
  const SkeletonStatsRow({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
    child: Row(
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          if (i > 0) const SizedBox(width: AppConstants.spacing12),
          const Expanded(
            child: SkeletonBox(height: 80, borderRadius: AppConstants.radius12),
          ),
        ],
      ],
    ),
  );
}

/// Detail page skeleton: image, title, subtitle, two info cards.
class SkeletonDetailPage extends StatelessWidget {
  const SkeletonDetailPage({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonPulse(
    child: SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 300, borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 200, height: 24),
                SizedBox(height: AppConstants.spacing12),
                SkeletonBox(width: 150, height: 16),
                SizedBox(height: AppConstants.spacing24),
                SkeletonBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: AppConstants.radius12,
                ),
                SizedBox(height: AppConstants.spacing12),
                SkeletonBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: AppConstants.radius12,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Footer for a paged list: a spinner while the next page loads, or the
/// load-more error with a retry.
class SliverLoadingMoreIndicator extends StatelessWidget {
  const SliverLoadingMoreIndicator({
    super.key,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (error != null && error!.isNotEmpty) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load more.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PaperTokens.of(context).textSecondary,
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      );
    } else if (isLoading) {
      child = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Center(child: child),
      ),
    );
  }
}
