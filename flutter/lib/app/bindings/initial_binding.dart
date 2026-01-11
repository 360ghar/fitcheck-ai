import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/network_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/offline_queue_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Initial binding - sets up global services and singletons
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Supabase service (must be first)
    Get.put(SupabaseService.instance);

    // Initialize NetworkService for connectivity monitoring
    Get.put(NetworkService());

    // Initialize CacheService for API response caching
    Get.put(CacheService());

    // Initialize OfflineQueueService for offline operation queuing
    Get.put(OfflineQueueService());

    // Initialize NotificationService for centralized UI notifications
    Get.put(NotificationService());

    // Initialize other services
    ApiClient.instance.initialize();

    // Register AuthController immediately (not lazy) for middleware access
    // This ensures AuthController is always available for Get.find() calls
    Get.put(AuthController());

    // Feature controllers are registered in their respective bindings.
  }
}
