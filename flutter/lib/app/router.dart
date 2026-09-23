import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/services/analytics_service.dart';
import '../core/services/supabase_service.dart';
import '../core/widgets/paper.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/views/auth_entry_page.dart';
import '../features/auth/views/forgot_password_page.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_page.dart';
import '../features/calendar/views/calendar_page.dart';
import '../features/dashboard/views/dashboard_content.dart';
import '../features/feedback/views/feedback_page.dart';
import '../features/gamification/views/gamification_page.dart';
import '../features/gifts/models/gift_models.dart';
import '../features/gifts/views/gift_vouchers_page.dart';
import '../features/legal/views/legal_page.dart';
import '../features/outfits/views/outfit_builder_page.dart';
import '../features/outfits/views/outfit_collections_page.dart';
import '../features/outfits/views/outfit_detail_page.dart';
import '../features/outfits/views/outfit_edit_page.dart';
import '../features/outfits/views/outfits_content.dart';
import '../features/photoshoot/views/photoshoot_content.dart';
import '../features/profile/views/body_profiles_page.dart';
import '../features/profile/views/help_page.dart';
import '../features/profile/views/profile_content.dart';
import '../features/profile/views/profile_edit_page.dart';
import '../features/profile/views/profile_page.dart';
import '../features/recommendations/views/recommendations_page.dart';
import '../features/settings/views/ai_settings_page.dart';
import '../features/settings/views/settings_page.dart';
import '../features/shell/views/main_shell_page.dart';
import '../features/social/views/shared_outfit_page.dart';
import '../features/splash/splash_page.dart';
import '../features/subscription/views/referral_page.dart';
import '../features/subscription/views/subscription_page.dart';
import '../features/tryon/views/tryon_page.dart';
import '../features/wardrobe/views/batch_extraction_progress_page.dart';
import '../features/wardrobe/views/batch_image_selector_page.dart';
import '../features/wardrobe/views/batch_item_review_page.dart';
import '../features/wardrobe/views/item_add_page.dart';
import '../features/wardrobe/views/item_detail_page.dart';
import '../features/wardrobe/views/item_edit_page.dart';
import '../features/wardrobe/views/wardrobe_content.dart';
import '../features/wardrobe/views/wardrobe_stats_page.dart';
import 'routes/app_routes.dart';

export 'package:go_router/go_router.dart';
export 'routes/app_routes.dart';

const _guestRoutes = {
  Routes.onboarding,
  Routes.login,
  Routes.register,
  Routes.forgotPassword,
};

/// Sends each location to the screen the auth state allows:
/// - before the stored session is restored, the splash;
/// - signed out, the guest pages;
/// - signed in, anything but the guest pages and the splash.
///
/// The policy pages and shared outfits are public (App Review needs the
/// policy links reachable without signing in, Guideline 1.2).
String? authRedirect(ProviderContainer container, String path) {
  if (path == Routes.legal || path.startsWith('/shared/')) return null;
  if (!container.read(authProvider).initialized) {
    return path == Routes.splash ? null : Routes.splash;
  }
  // A restored session is enough to enter the shell even when the profile
  // failed to load (offline start); the shell refreshes it later.
  if (container.read(authProvider.notifier).hasSession) {
    return path == Routes.splash || _guestRoutes.contains(path)
        ? Routes.home
        : null;
  }
  if (path == Routes.splash) return Routes.onboarding;
  return _guestRoutes.contains(path) ? null : Routes.onboarding;
}

GoRoute _page(String path, Widget Function(GoRouterState state) build) =>
    GoRoute(
      path: path,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => build(state),
    );

StatefulShellBranch _tab(String path, Widget page) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => page)],
);

/// Builds the app router. Tests pass their own [container].
GoRouter buildRouter({ProviderContainer? container}) {
  final c = container ?? appContainer;
  final initialized = ValueNotifier(c.read(authProvider).initialized);
  c.listen(
    authProvider.select((s) => s.initialized),
    (_, value) => initialized.value = value,
  );
  String id(GoRouterState s) => s.pathParameters['id'] ?? '';

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: Listenable.merge([
      initialized,
      SupabaseService.instance.isAuthenticated,
    ]),
    redirect: (context, state) => authRedirect(c, state.matchedLocation),
    observers: [_ScreenTracker()],
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const AuthEntryPage(),
      ),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute(
        builder: (context, state, shell) => MainShellPage(shell: shell),
        navigatorContainerBuilder: (context, shell, children) => IndexedStack(
          index: shell.currentIndex,
          children: [
            for (var i = 0; i < children.length; i++)
              // Offstage tabs keep their state but stop animating.
              TickerMode(
                enabled: i == shell.currentIndex,
                child: PaperStockScope(stock: tabStocks[i], child: children[i]),
              ),
          ],
        ),
        branches: [
          _tab(Routes.home, const DashboardContent()),
          _tab(Routes.photoshoot, const PhotoshootContent()),
          _tab(Routes.wardrobe, const WardrobeContent()),
          _tab(Routes.outfits, const OutfitsContent()),
          _tab(Routes.more, const ProfileContent()),
        ],
      ),
      // Pages open over the shell on the root navigator. Static paths come
      // before `:id`: the first match wins.
      _page(Routes.wardrobeAdd, (_) => const ItemAddPage()),
      _page(Routes.wardrobeBatchAdd, (_) => const BatchImageSelectorPage()),
      _page(
        Routes.wardrobeBatchAddSocial,
        (_) => const BatchImageSelectorPage(launchInSocialMode: true),
      ),
      _page(
        Routes.wardrobeBatchProgress,
        (_) => const BatchExtractionProgressPage(),
      ),
      _page(Routes.wardrobeBatchReview, (_) => const BatchItemReviewPage()),
      _page(Routes.wardrobeStats, (_) => const WardrobeStatsPage()),
      _page('/wardrobe/edit/:id', (s) => ItemEditPage(itemId: id(s))),
      _page('/wardrobe/:id', (s) => ItemDetailPage(itemId: id(s))),
      _page(Routes.outfitBuilder, (_) => const OutfitBuilderPage()),
      _page(Routes.outfitCollections, (_) => const OutfitCollectionsPage()),
      _page('/outfits/edit/:id', (s) => OutfitEditPage(outfitId: id(s))),
      _page('/outfits/:id', (s) => OutfitDetailPage(outfitId: id(s))),
      _page(Routes.tryOn, (_) => const TryOnPage()),
      _page(Routes.calendar, (_) => const CalendarPage()),
      _page(Routes.recommendations, (_) => const RecommendationsPage()),
      _page(Routes.profile, (_) => const ProfilePage()),
      _page(Routes.profileEdit, (_) => const ProfileEditPage()),
      _page(Routes.bodyProfiles, (_) => const BodyProfilesPage()),
      _page(Routes.settings, (_) => const SettingsPage()),
      _page(Routes.aiSettings, (_) => const AiSettingsPage()),
      _page(Routes.gamification, (_) => const GamificationPage()),
      _page(Routes.subscription, (_) => const SubscriptionPage()),
      _page(Routes.referral, (_) => const ReferralPage()),
      _page(
        Routes.gifts,
        (s) => GiftVouchersPage(intent: s.extra as GiftRouteIntent?),
      ),
      _page(Routes.help, (_) => const HelpPage()),
      _page(Routes.feedback, (_) => const FeedbackPage()),
      _page(Routes.legal, (_) => const LegalPage()),
      _page(Routes.sharedOutfit, (s) => SharedOutfitPage(shareId: id(s))),
    ],
  );
}

/// The app's router.
final appRouter = buildRouter();

/// Reports each shown screen to analytics by its route pattern (no ids).
class _ScreenTracker extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _track(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    AnalyticsService.instance.screen(name);
  }
}
