import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/env_config.dart';
import 'core/services/analytics_service.dart';
import 'core/providers.dart';
import 'core/services/code_push_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'core/utils/image_utils.dart';
import 'app/themes/app_theme.dart';
import 'app/router.dart';
import 'core/network/api_client.dart';
import 'features/subscription/providers/subscription_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  final themeService = ThemeService.instance;
  // The patch number reaches the Sentry options below. The read is local,
  // time-bounded and falls back to null.
  final codePushService = CodePushService.instance..start();

  // Independent startup work runs in parallel. The theme is awaited so the
  // first frame never flashes the default theme before the saved one.
  final startup = await Future.wait<Object?>([
    SupabaseService.instance.init(),
    AnalyticsService.instance.init(),
    themeService.ready,
    codePushService.loadCurrentPatch(),
    PackageInfo.fromPlatform(),
  ]);
  final packageInfo = startup[4]! as PackageInfo;
  ApiClient.instance.initialize();
  // App-lifetime purchase recovery: owns the store stream, so a purchase
  // whose backend verification failed is verified even when the paywall
  // never opens (Android has no webhook account linkage without it).
  appContainer.read(purchaseRecoveryServiceProvider);

  // Best-effort cleanup of stale generated thumbnails (fire-and-forget; the
  // method swallows its own errors and must never delay startup).
  unawaited(ImageUtils.pruneThumbnails());

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
  // only record telemetry and preserve default presentation. No
  // runZonedGuarded: PlatformDispatcher.onError already receives uncaught
  // async errors, and a zone around runApp caused a zone-mismatch warning.

  // Capture framework errors (widget build, layout, gesture, animation).
  // Without this, FlutterError details are only printed in debug mode and
  // never reach PostHog telemetry in release builds. (Sentry's own
  // FlutterErrorIntegration captures these when Sentry is enabled.)
  FlutterError.onError = (FlutterErrorDetails details) {
    AnalyticsService.instance.recordError(details.exception, details.stack);
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

  final app = UncontrolledProviderScope(
    container: appContainer,
    child: const FitCheckApp(),
  );
  if (!sentryEnabled) {
    runApp(app);
    return;
  }
  await SentryFlutter.init((options) {
    options.dsn = sentryDsn;
    options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
    options.environment = kDebugMode ? 'development' : 'production';
    options.release =
        '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
    // A Shorebird patch ships new Dart code under an UNCHANGED version and
    // build number, so `release` alone cannot tell a crash in patch 3 from
    // one in the original store build. `dist` is Sentry's own
    // "distribution within a release" field. Null on an unpatched build.
    options.dist = codePushService.currentPatchNumber.value?.toString();
    options.debug = kDebugMode;
  }, appRunner: () => runApp(app));
}

class FitCheckApp extends StatelessWidget {
  const FitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return ValueListenableBuilder(
      valueListenable: theme.themeMode,
      builder: (context, _, _) => MaterialApp.router(
        title: 'Fit Check AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme.currentThemeMode,
        routerConfig: appRouter,
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    );
  }
}
