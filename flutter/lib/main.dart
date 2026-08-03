import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/env_config.dart';
import 'core/services/analytics_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/persistence_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/route_observer.dart';
import 'core/utils/error_handler.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  await SupabaseService.instance.init();
  await AnalyticsService.instance.init();

  // PersistenceService must be registered before ThemeService (and any other
  // service that reads cached prefs in onInit), since ThemeService.onInit
  // calls Get.find<PersistenceService>().
  Get.put(PersistenceService());

  // Must be registered before FitCheckApp builds GetMaterialApp, since its
  // themeMode argument reads Get.find<ThemeService>() eagerly - InitialBinding
  // runs too late (inside GetMaterialApp's own initState).
  final themeService = Get.put(ThemeService());
  // Block until the persisted theme is read so the first frame never renders
  // the default light theme for a moment before switching to the user's saved
  // dark theme. (ThemeService.onInit kicks off the async load; ready resolves
  // when it lands.)
  await themeService.ready;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final sentryDsn = EnvConfig.sentryDsn;
  final bool sentryEnabled = sentryDsn.isNotEmpty;

  // Sentry captures go through ErrorHandler.captureToSentry, which guards on
  // Sentry.isEnabled so a capture before (or entirely without) SentryFlutter
  // .init is a safe no-op. One implementation, shared with every other capture
  // site in the app.
  //
  // NOTE on ownership: SentryFlutter.init installs its own FlutterError.onError
  // and PlatformDispatcher.onError integrations that capture the SAME errors
  // this handler forwards to. Routing them through captureToSentry as well
  // would double-report every framework/platform error. So those two paths
  // only record telemetry and preserve default presentation; the zone guard in
  // the appRunner below keeps captureToSentry because Sentry's outer
  // runZonedGuarded can never see errors the inner zone already consumed.

  // Capture framework errors (widget build, layout, gesture, animation).
  // Without this, FlutterError details are only printed in debug mode and
  // never reach PostHog telemetry in release builds. (Sentry's own
  // FlutterErrorIntegration captures these when Sentry is enabled.)
  FlutterError.onError = (FlutterErrorDetails details) {
    AnalyticsService.instance.recordError(
      details.exception,
      details.stack,
    );
    // Preserve default behaviour: dump full details in debug, minimal in
    // release, so developer ergonomics don't regress.
    FlutterError.presentError(details);
  };

  // Capture async / platform-dispatcher errors that escape the widget tree.
  // (Sentry's own OnErrorIntegration captures these when Sentry is enabled.)
  PlatformDispatcher.instance.onError = (error, stack) {
    AnalyticsService.instance.recordError(error, stack);
    return true;
  };

  if (sentryEnabled) {
    // Read the real version+build from the app bundle instead of a hardcoded
    // string, so it can't silently drift out of sync with pubspec.yaml on
    // the next release.
    final packageInfo = await PackageInfo.fromPlatform();
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = kDebugMode ? 'development' : 'production';
        options.release = '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
        options.debug = kDebugMode;
      },
      appRunner: () {
        runZonedGuarded(
          () => runApp(const FitCheckApp()),
          (error, stack) {
            AnalyticsService.instance.recordError(error, stack);
            ErrorHandler.captureToSentry(error, stackTrace: stack);
          },
        );
      },
    );
  } else {
    runZonedGuarded(
      () => runApp(const FitCheckApp()),
      (error, stack) {
        AnalyticsService.instance.recordError(error, stack);
      },
    );
  }
}

class FitCheckApp extends StatelessWidget {
  const FitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defensive: guarantees ThemeService (and its PersistenceService dep)
    // exist even if this widget is ever pumped without main() having run
    // first (e.g. widget tests), since initialBinding below only registers
    // dependencies after this build() call returns.
    if (!Get.isRegistered<PersistenceService>()) {
      Get.put(PersistenceService());
    }
    if (!Get.isRegistered<ThemeService>()) {
      Get.put(ThemeService());
    }
    return GetMaterialApp(
      title: 'Fit Check AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeService>().currentThemeMode,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: Routes.splash,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorObservers: [AppRouteObserver()],
    );
  }
}
