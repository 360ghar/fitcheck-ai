import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/persistence_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/network_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/ai_consent_service.dart';
import '../../features/wardrobe/services/wardrobe_sync_service.dart';
import '../../features/auth/services/user_initialization_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/services/referral_service.dart';
import '../../features/subscription/repositories/subscription_repository.dart';
import '../../features/subscription/services/purchase_recovery_service.dart';

/// Initial binding - sets up global services and singletons
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Supabase service (must be first)
    Get.put(SupabaseService.instance);

    // Register PersistenceService early — it wraps SharedPreferences and is
    // consumed by ThemeService, AiConsentService, and other features.
    // main() may have already registered it; don't replace that instance.
    if (!Get.isRegistered<PersistenceService>()) {
      Get.put(PersistenceService());
    }

    // ThemeService is registered in main() before runApp, since
    // FitCheckApp's GetMaterialApp reads it eagerly before this binding runs.

    // Initialize AiConsentService eagerly so Get.find never throws when an AI
    // feature checks third-party data-sharing consent.
    Get.put(AiConsentService());

    // Initialize NetworkService for connectivity monitoring
    Get.put(NetworkService());

    // Initialize NotificationService for centralized UI notifications
    Get.put(NotificationService());

    // Initialize other services
    ApiClient.instance.initialize();

    // Register subscription repository and user initialization service
    Get.put(SubscriptionRepository());
    Get.put(UserInitializationService(subscriptionRepo: Get.find<SubscriptionRepository>()));

    // App-lifetime purchase recovery: owns the in_app_purchase stream so a
    // purchase whose backend verification failed (e.g. a network drop right
    // after the store charged the user) is verified + completed even when
    // the subscription page never opens — Android has no webhook account
    // linkage without it. Permanent by design: Get.put inside InitialBinding
    // survives route disposal, like SupabaseService above. Must come after
    // SupabaseService (auth flag) and SubscriptionRepository.
    Get.put(
      PurchaseRecoveryService(repository: Get.find<SubscriptionRepository>()),
    );

    // Register wardrobe sync service
    Get.put(WardrobeSyncService());

    // Register auth services (FL7 extraction)
    Get.put(AuthService());
    Get.put(ReferralService(
      persistence: Get.find(),
      userInitService: Get.find(),
    ));

    // Register AuthController immediately (not lazy) for middleware access.
    // This ensures AuthController is always available for Get.find() calls.
    Get.put(AuthController());

    // Feature controllers are registered in their respective bindings.
  }
}
