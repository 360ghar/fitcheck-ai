import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import 'paper.dart';

/// Bottom navigation: a torn strip of the active tab's paper with a paper
/// chip that slides under the selected tab.
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  /// Called with the tapped tab, including the open one.
  final void Function(int index) onTabChanged;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  /// Height of the bar above the bottom safe-area inset.
  static const double barHeight = 72;

  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: Routes.home,
    ),
    NavigationItem(
      icon: Icons.camera_outlined,
      activeIcon: Icons.camera_rounded,
      label: 'Photoshoot',
      route: Routes.photoshoot,
    ),
    NavigationItem(
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom_rounded,
      label: 'Closet',
      route: Routes.wardrobe,
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Outfits',
      route: Routes.outfits,
    ),
    NavigationItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'More',
      route: Routes.more,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: tabStocks[currentIndex],
      child: Builder(builder: _buildBar),
    );
  }

  Widget _buildBar(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final stock = tokens.stock;
    final count = navigationItems.length;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    final label = Theme.of(context).textTheme.labelSmall;

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      decoration: ShapeDecoration(
        color: stock.card,
        image: paperGrain(context),
        shape: const DeckleBorder(edge: PaperEdge.top, radius: 0, amplitude: 2),
        shadows: [BoxShadow(color: stock.shadow, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing8,
            AppConstants.spacing12,
            AppConstants.spacing8,
            AppConstants.spacing4,
          ),
          child: SizedBox(
            height: barHeight - AppConstants.spacing16,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(-1 + 2 * currentIndex / (count - 1), 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing4,
                      ),
                      child: PaperSurface(
                        color: stock.tint,
                        grain: false,
                        padding: EdgeInsets.zero,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final (index, item) in navigationItems.indexed)
                      Expanded(
                        child: _NavTab(
                          item: item,
                          selected: index == currentIndex,
                          labelStyle: label,
                          onTap: () => onTabChanged(index),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom bar for root-navigator pages that cover the shell tabs.
  /// Tapping a tab leaves the page for that tab's route.
  static Widget shellBar(BuildContext context, String route) =>
      AppBottomNavigationBar(
        currentIndex: getIndexForRoute(route),
        onTabChanged: (i) => context.go(navigationItems[i].route),
      );

  /// Get the current index based on the current route
  static int getIndexForRoute(String route) {
    final normalized = route.split('?').first;
    const moreRoutes = {
      Routes.tryOn,
      Routes.recommendations,
      Routes.calendar,
      Routes.gamification,
      Routes.profile,
      Routes.settings,
      Routes.help,
      Routes.legal,
      Routes.subscription,
      Routes.referral,
      Routes.feedback,
    };
    if (moreRoutes.contains(normalized) ||
        moreRoutes.any((item) => normalized.startsWith('$item/'))) {
      return navigationItems.indexWhere((item) => item.route == Routes.more);
    }
    for (int i = 0; i < navigationItems.length; i++) {
      final itemRoute = navigationItems[i].route;
      if (itemRoute == normalized || normalized.startsWith('$itemRoute/')) {
        return i;
      }
    }
    return 0;
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.labelStyle,
    required this.onTap,
  });

  final NavigationItem item;
  final bool selected;
  final TextStyle? labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final color = selected ? tokens.stock.accent : tokens.textSecondary;
    return Semantics(
      label: item.label,
      button: true,
      selected: selected,
      excludeSemantics: true,
      // excludeSemantics drops the InkResponse's tap action: without this
      // the node is announced as a button screen readers cannot activate.
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon, size: 24, color: color),
            const SizedBox(height: AppConstants.spacing4),
            // Scales down on ~320px screens so "Photoshoot" never wraps.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                style: labelStyle?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
