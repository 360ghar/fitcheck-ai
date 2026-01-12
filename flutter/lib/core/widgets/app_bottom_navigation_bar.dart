import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import 'app_ui.dart';

/// Reusable bottom navigation bar for main app pages
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  /// Optional callback for tab changes. If provided, navigation is handled
  /// by the parent (MainShellPage). If null, uses Get.offAllNamed().
  final void Function(int index)? onTabChanged;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTabChanged,
  });

  // Bottom navigation items
  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      route: Routes.home,
    ),
    NavigationItem(
      icon: Icons.checkroom,
      activeIcon: Icons.checkroom,
      label: 'Wardrobe',
      route: Routes.wardrobe,
    ),
    NavigationItem(
      icon: Icons.auto_awesome,
      activeIcon: Icons.auto_awesome,
      label: 'Outfits',
      route: Routes.outfits,
    ),
    NavigationItem(
      icon: Icons.accessibility_new,
      activeIcon: Icons.accessibility_new,
      label: 'Try-On',
      route: Routes.tryOn,
    ),
    NavigationItem(
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      label: 'More',
      route: Routes.more,
    ),
  ];

  void _onTabTapped(int index) {
    // If already on this tab, don't do anything
    if (currentIndex == index) {
      return;
    }

    // Use callback if provided (IndexedStack mode in MainShellPage)
    if (onTabChanged != null) {
      onTabChanged!(index);
      return;
    }

    // Fallback to navigation (for pages outside the shell like "More" submenu)
    final route = navigationItems[index].route;
    if (Get.currentRoute != route) {
      Get.offAllNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: tokens.navBackground,
            borderRadius: BorderRadius.circular(AppConstants.radius24),
            border: Border.all(color: tokens.navBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(tokens.isDarkMode ? 0.4 : 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: AppConstants.animationDurationShort,
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tokens.brandColor.withOpacity(0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.radius16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? tokens.brandColor
                              : tokens.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? tokens.brandColor
                                : tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Get the current index based on the current route
  static int getIndexForRoute(String route) {
    final normalized = route.split('?').first;
    const moreRoutes = {
      Routes.recommendations,
      Routes.calendar,
      Routes.gamification,
      Routes.profile,
      Routes.settings,
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
