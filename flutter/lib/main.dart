import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/config/env_config.dart';
import 'core/services/analytics_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/route_observer.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  // Initialize Supabase first
  await SupabaseService.instance.init();
  await AnalyticsService.instance.init();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FitCheckApp());
}

class FitCheckApp extends StatelessWidget {
  const FitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fit Check AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: Routes.splash,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorObservers: [AppRouteObserver()],
    );
  }
}
