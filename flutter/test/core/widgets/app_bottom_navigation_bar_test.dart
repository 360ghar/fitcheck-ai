import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/widgets/app_bottom_navigation_bar.dart';

void main() {
  // Every destination linked from ProfileContent is pushed over the shell and
  // renders its own navbar, which asks getIndexForRoute which tab to highlight.
  // Miss a route here and that page highlights Home.
  const moreTab = 4;

  final expectedTab = <String, int>{
    // Explore
    Routes.tryOn: moreTab,
    Routes.recommendations: moreTab,
    Routes.calendar: moreTab,
    Routes.gamification: moreTab,
    // Account
    Routes.profile: moreTab,
    Routes.profileEdit: moreTab,
    Routes.bodyProfiles: moreTab,
    Routes.subscription: moreTab,
    Routes.referral: moreTab,
    Routes.settings: moreTab,
    Routes.aiSettings: moreTab,
    // Support
    Routes.help: moreTab,
    Routes.feedback: moreTab,
    Routes.legal: moreTab,
    // Stats strip taps belong to their own tabs, not More.
    Routes.wardrobeStats: 2,
    Routes.outfitCollections: 3,
  };

  test('every profile hub destination highlights the right tab', () {
    expect(
      AppBottomNavigationBar.navigationItems[moreTab].route,
      Routes.more,
      reason: 'moreTab index drifted',
    );

    expectedTab.forEach((route, tab) {
      expect(
        AppBottomNavigationBar.getIndexForRoute(route),
        tab,
        reason: '$route should highlight tab $tab',
      );
    });
  });

  test('query strings and unknown routes still resolve', () {
    expect(AppBottomNavigationBar.getIndexForRoute('/settings?section=ai'), moreTab);
    expect(AppBottomNavigationBar.getIndexForRoute('/nope'), 0);
  });
}
