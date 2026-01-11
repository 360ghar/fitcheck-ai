import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'analytics_service.dart';

/// Tracks screen transitions for analytics.
class AppRouteObserver extends GetObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _track(previousRoute);
    }
  }

  void _track(Route route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    AnalyticsService.instance.screen(name);
  }
}
