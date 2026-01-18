import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/splash/splash_page.dart';
import '../../features/auth/views/auth_entry_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/auth/views/forgot_password_page.dart';
import '../../features/wardrobe/views/item_add_page.dart';
import '../../features/wardrobe/views/item_detail_page.dart';
import '../../features/wardrobe/views/item_edit_page.dart';
import '../../features/wardrobe/views/wardrobe_stats_page.dart';
import '../../features/outfits/views/outfit_builder_page.dart';
import '../../features/outfits/views/outfit_detail_page.dart';
import '../../features/outfits/views/outfit_edit_page.dart';
import '../../features/outfits/views/outfit_collections_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/profile/views/profile_edit_page.dart';
import '../../features/profile/views/body_profiles_page.dart';
import '../../features/profile/views/help_page.dart';
import '../../features/calendar/views/calendar_page.dart';
import '../../features/settings/views/settings_page.dart';
import '../../features/settings/views/ai_settings_page.dart';
import '../../features/recommendations/views/recommendations_page.dart';
import '../../features/gamification/views/gamification_page.dart';
import '../../features/social/views/shared_outfit_page.dart';
import '../../features/shell/views/main_shell_page.dart';
import '../../features/shell/bindings/main_shell_binding.dart';
import '../../features/shell/controllers/main_shell_controller.dart';
import '../../features/tryon/views/tryon_page.dart';
import '../../features/tryon/bindings/tryon_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/wardrobe_binding.dart';
import '../bindings/outfit_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/calendar_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/ai_settings_binding.dart';
import '../bindings/batch_extraction_binding.dart';
import '../../features/recommendations/bindings/recommendations_binding.dart';
import '../../features/gamification/bindings/gamification_binding.dart';
import '../../features/subscription/views/subscription_page.dart';
import '../../features/subscription/views/referral_page.dart';
import '../../features/subscription/bindings/subscription_binding.dart';
import '../../features/feedback/views/feedback_page.dart';
import '../../features/feedback/bindings/feedback_binding.dart';
import '../../features/wardrobe/views/batch_image_selector_page.dart';
import '../../features/wardrobe/views/batch_extraction_progress_page.dart';
import '../../features/wardrobe/views/batch_item_review_page.dart';
import 'app_routes.dart';

/// Route pages configuration
class AppPages {
  static final routes = [
    // Splash/Welcome
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const AuthEntryPage(),
    ),

    // Authentication
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),

    // Main App (Protected Routes) - Shell with IndexedStack for main tabs
    GetPage(
      name: Routes.home,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Deep link routes - redirect to shell with correct tab
    GetPage(
      name: Routes.photoshoot,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware(), TabRedirectMiddleware(1)],
    ),
    GetPage(
      name: Routes.wardrobe,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware(), TabRedirectMiddleware(2)],
    ),
    GetPage(
      name: Routes.outfits,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware(), TabRedirectMiddleware(3)],
    ),
    GetPage(
      name: Routes.tryOn,
      page: () => const TryOnPage(),
      binding: TryOnBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.more,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware(), TabRedirectMiddleware(4)],
    ),
    // Sub-routes that push on top of shell
    GetPage(
      name: Routes.wardrobeAdd,
      page: () => const ItemAddPage(),
      binding: WardrobeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Batch extraction routes
    GetPage(
      name: Routes.wardrobeBatchAdd,
      page: () => const BatchImageSelectorPage(),
      binding: BatchExtractionBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.wardrobeBatchProgress,
      page: () => const BatchExtractionProgressPage(),
      binding: BatchExtractionBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.wardrobeBatchReview,
      page: () => const BatchItemReviewPage(),
      binding: BatchExtractionBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.wardrobeItemDetail,
      page: () => ItemDetailPage(itemId: Get.parameters['id'] ?? ''),
      binding: WardrobeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.wardrobeItemEdit,
      page: () => ItemEditPage(itemId: Get.parameters['id'] ?? ''),
      binding: WardrobeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.wardrobeStats,
      page: () => const WardrobeStatsPage(),
      binding: WardrobeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.outfitBuilder,
      page: () => const OutfitBuilderPage(),
      binding: OutfitBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.outfitDetail,
      page: () => OutfitDetailPage(outfitId: Get.parameters['id'] ?? ''),
      binding: OutfitBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.outfitEdit,
      page: () => OutfitEditPage(outfitId: Get.parameters['id'] ?? ''),
      binding: OutfitBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.outfitCollections,
      page: () => const OutfitCollectionsPage(),
      binding: OutfitBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // "More" submenu pages (keep their own navbar)
    GetPage(
      name: Routes.calendar,
      page: () => const CalendarPage(),
      binding: CalendarBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.aiSettings,
      page: () => const AiSettingsPage(),
      binding: AiSettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.recommendations,
      page: () => const RecommendationsPage(),
      binding: RecommendationsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.gamification,
      page: () => const GamificationPage(),
      binding: GamificationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.subscription,
      page: () => const SubscriptionPage(),
      binding: SubscriptionBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.referral,
      page: () => const ReferralPage(),
      binding: SubscriptionBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.profileEdit,
      page: () => const ProfileEditPage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.bodyProfiles,
      page: () => const BodyProfilesPage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.help,
      page: () => const HelpPage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.sharedOutfit,
      page: () => SharedOutfitPage(shareId: Get.parameters['id'] ?? ''),
    ),
  ];
}

/// Authentication middleware - protects routes
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isInitialized.value) {
      return const RouteSettings(name: Routes.splash);
    }

    // If accessing protected route and not authenticated
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: Routes.onboarding);
    }

    // If accessing auth route and already authenticated
    if (authController.isAuthenticated &&
        (route == Routes.login ||
            route == Routes.onboarding ||
            route == Routes.register ||
            route == Routes.forgotPassword)) {
      return const RouteSettings(name: Routes.home);
    }

    return null;
  }
}

/// Middleware to set initial tab index for deep links to main tabs
class TabRedirectMiddleware extends GetMiddleware {
  final int tabIndex;

  TabRedirectMiddleware(this.tabIndex);

  @override
  GetPage? onPageCalled(GetPage? page) {
    // After page loads, set the correct tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<MainShellController>()) {
        Get.find<MainShellController>().changeTab(tabIndex);
      }
    });
    return page;
  }
}
