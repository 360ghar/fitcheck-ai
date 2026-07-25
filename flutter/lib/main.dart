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
import 'core/services/theme_service.dart';
import 'core/services/route_observer.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  await SupabaseService.instance.init();
  await AnalyticsService.instance.init();

  // Must be registered before FitCheckApp builds GetMaterialApp, since its
  // themeMode argument reads Get.find<ThemeService>() eagerly - InitialBinding
  // runs too late (inside GetMaterialApp's own initState).
  Get.put(ThemeService());

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

  // Helper to report errors to Sentry only when it has been initialised.
  // Calling Sentry.captureException before SentryFlutter.init completes is a
  // no-op at best and can throw at worst, so every capture site is guarded.
  void reportToSentry(Object error, StackTrace stack) {
    if (sentryEnabled) {
      Sentry.captureException(error, stackTrace: stack);
    }
  }

  // Capture framework errors (widget build, layout, gesture, animation).
  // Without this, FlutterError details are only printed in debug mode and
  // never reach Sentry/telemetry in release builds.
  FlutterError.onError = (FlutterErrorDetails details) {
    AnalyticsService.instance.recordError(
      details.exception,
      details.stack,
    );
    reportToSentry(details.exception, details.stack ?? StackTrace.current);
    // Preserve default behaviour: dump full details in debug, minimal in
    // release, so developer ergonomics don't regress.
    FlutterError.presentError(details);
  };

  // Capture async / platform-dispatcher errors that escape the widget tree.
  PlatformDispatcher.instance.onError = (error, stack) {
    AnalyticsService.instance.recordError(error, stack);
    reportToSentry(error, stack);
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
            reportToSentry(error, stack);
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
    // Defensive: guarantees ThemeService exists even if this widget is ever
    // pumped without main() having run first (e.g. widget tests), since
    // initialBinding below only registers dependencies after this build()
    // call returns.
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
