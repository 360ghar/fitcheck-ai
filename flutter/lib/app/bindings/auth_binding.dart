import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Auth binding - provides auth controller to auth screens
///
/// DECISION (kept deliberately): InitialBinding already runs an EAGER
/// `Get.put(AuthController())`, which takes precedence over this
/// registration, so on normal startup this lazyPut is a no-op — it neither
/// creates a second instance nor replaces the eager one. It stays because of
/// its `fenix: true`: if the controller is ever disposed after logout (e.g.
/// a future cleanup calling Get.delete during `offAllNamed(splash)`), the
/// next visit to login/register must still resolve `Get.find<AuthController>`
/// (used by pages and GuestMiddleware) without crashing. Fenix recreates it
/// lazily at that point. Removing either registration would change that
/// fallback behavior, so both exist by design.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}
