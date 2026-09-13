import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_ui.dart';
import '../auth/controllers/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authController = Get.find<AuthController>();
    await authController.initializeAuth();
    if (!mounted) return;
    // `isAuthenticated` additionally requires the backend profile
    // (`user.value`) to have loaded. `_initializeAuth` swallows /users/me
    // errors, so an offline or 5xx start left a valid session with a null
    // profile — and routing that to onboarding signed the user out. A
    // restored Supabase session is enough to enter the shell, which
    // tolerates a late profile refresh.
    if (authController.isAuthenticated || authController.hasSession) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppCoreColors.editorialRose,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.checkroom_outlined,
                      color: AppCoreColors.editorialInk,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'FitCheck AI',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preparing your closet…',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
