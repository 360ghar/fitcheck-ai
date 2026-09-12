import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';

/// The main shell owns this navigation bar and its selected destination.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  static const navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: Routes.home,
    ),
    NavigationItem(
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom,
      label: 'Closet',
      route: Routes.wardrobe,
    ),
    NavigationItem(
      icon: Icons.style_outlined,
      activeIcon: Icons.style,
      label: 'Outfits',
      route: Routes.outfits,
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Studio',
      route: Routes.studio,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: Routes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTabChanged,
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in navigationItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
                tooltip: item.label,
              ),
          ],
        ),
      ),
    );
  }

  /// Includes legacy entry points and routes pushed from a destination.
  static int getIndexForRoute(String route) {
    final path = Uri.parse(route).path;
    if (path == Routes.photoshoot ||
        path == Routes.tryOn ||
        path == Routes.studio) {
      return 3;
    }
    if (path == Routes.wardrobe || path.startsWith('${Routes.wardrobe}/')) {
      return 1;
    }
    if (path == Routes.outfits || path.startsWith('${Routes.outfits}/')) {
      return 2;
    }
    const profileRoutes = [
      Routes.more,
      Routes.profile,
      Routes.settings,
      Routes.calendar,
      Routes.recommendations,
      Routes.gamification,
      Routes.subscription,
      Routes.referral,
      Routes.gifts,
      Routes.help,
      Routes.legal,
      Routes.feedback,
    ];
    if (profileRoutes.any(
      (prefix) => path == prefix || path.startsWith('$prefix/'),
    )) {
      return 4;
    }
    return 0;
  }
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
