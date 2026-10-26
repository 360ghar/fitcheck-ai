import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../app/routes/app_routes.dart';

/// The custom URL scheme registered in `ios/Runner/Info.plist`
/// (`CFBundleURLSchemes`) and in the Android manifest.
const String kDeepLinkScheme = 'fitcheck.ai';

/// Owned by the social-import OAuth flow (`batch_extraction_provider.dart`),
/// which does session work rather than navigation. The generic router must
/// leave it alone in both directions: it does not resolve it, and it must not
/// navigate on it.
const String kSocialImportHost = 'social-import-callback';

/// Routes a campaign link may open, keyed by the URL path.
///
/// Deliberately a whitelist, not "whatever go_router matches": a custom
/// product page should be able to land on a real destination, and an arbitrary
/// path from an external URI reaching `go_router` is how an app ends up on a
/// blank screen (or a crash in a route that assumed arguments) because of a
/// typo in a marketing link.
const Map<String, String> _staticDestinations = {
  '/home': Routes.home,
  '/wardrobe': Routes.wardrobe,
  '/wardrobe/add': Routes.wardrobeAdd,
  '/wardrobe/batch-add': Routes.wardrobeBatchAdd,
  '/wardrobe/batch-add-social': Routes.wardrobeBatchAddSocial,
  '/wardrobe/jobs': Routes.wardrobeJobs,
  '/wardrobe/stats': Routes.wardrobeStats,
  '/outfits': Routes.outfits,
  '/outfits/build': Routes.outfitBuilder,
  '/outfits/collections': Routes.outfitCollections,
  '/calendar': Routes.calendar,
  '/photoshoot': Routes.photoshoot,
  '/try-on': Routes.tryOn,
  '/recommendations': Routes.recommendations,
  '/subscription': Routes.subscription,
  '/referral': Routes.referral,
  '/gifts': Routes.gifts,
  '/gamification': Routes.gamification,
  '/profile': Routes.profile,
  '/profile/body-profiles': Routes.bodyProfiles,
  '/settings': Routes.settings,
  '/settings/language': Routes.language,
  '/help': Routes.help,
  '/legal': Routes.legal,
  '/feedback': Routes.feedback,
  '/more': Routes.more,
};

/// Paths that carry one identifier segment. Case-insensitive on the prefix so
/// `fitcheck.ai://SHARED/abc` still resolves, but the id keeps its case.
final RegExp _sharedPattern = RegExp(
  r'^/shared/([^/]+)$',
  caseSensitive: false,
);
final RegExp _outfitPattern = RegExp(
  r'^/outfits/([^/]+)$',
  caseSensitive: false,
);
final RegExp _wardrobeItemPattern = RegExp(
  r'^/wardrobe/([^/]+)$',
  caseSensitive: false,
);

/// Resolves a `fitcheck.ai://<path>` link to a `go_router` location.
///
/// Returns `null` when the link is not ours to handle:
///  * a different scheme, or
///  * the social-import OAuth callback, which
///    `batch_extraction_provider.dart` consumes and which must keep working
///    exactly as it does today.
///
/// Returns [Routes.home] for our scheme with an unknown path, so a mistyped
/// campaign link lands on the app instead of a blank screen. The app never
/// crashes on an unrecognised deep link.
///
/// Accepted shapes, all equivalent:
///   fitcheck.ai://subscription
///   fitcheck.ai:///subscription
///   fitcheck.ai://subscription/
///   fitcheck.ai://outfits/abc123
/// Query strings and fragments are ignored: a campaign has no use for them,
/// and honouring them would mean allowing arbitrary route state from outside
/// the app.
String? resolveDeepLink(Uri uri) {
  if (uri.scheme.toLowerCase() != kDeepLinkScheme) return null;
  if (uri.host.toLowerCase() == kSocialImportHost) return null;

  // `fitcheck.ai://shared/abc` puts "shared" in host and "/abc" in path;
  // `fitcheck.ai:///shared/abc` puts "/shared/abc" in path. Normalise both to
  // one leading slash.
  final raw = uri.host.isEmpty ? uri.path : '/${uri.host}${uri.path}';
  final path = _normalise(raw);
  if (path.isEmpty) return Routes.home;

  final exact = _staticDestinations[path.toLowerCase()];
  if (exact != null) return exact;

  for (final entry in _parameterised) {
    final match = entry.pattern.firstMatch(path);
    if (match == null) continue;
    final id = Uri.decodeComponent(match.group(1)!);
    // An empty or path-like id is a broken link, not a destination.
    if (id.isEmpty || id.contains('/')) return Routes.home;
    return entry.build(id);
  }

  return Routes.home;
}

/// One-id destinations, checked after the exact table so `/outfits/build` and
/// `/wardrobe/stats` cannot be swallowed as ids.
final List<({RegExp pattern, String Function(String id) build})> _parameterised = [
  (
    pattern: _sharedPattern,
    build: (String id) => Routes.sharedOutfit.replaceFirst(':id', id),
  ),
  (pattern: _outfitPattern, build: Routes.outfit),
  (pattern: _wardrobeItemPattern, build: Routes.item),
];

/// Collapses `//`, drops a trailing slash, and ensures exactly one leading
/// slash. The path is left as it was otherwise: ids keep their case.
String _normalise(String raw) {
  var path = raw.replaceAll(RegExp(r'/{2,}'), '/');
  if (!path.startsWith('/')) path = '/$path';
  while (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path == '/' ? '' : path;
}

/// Listens for our custom-scheme links and navigates the router.
///
/// One listener for every campaign destination. The social-import callback is
/// filtered out by [resolveDeepLink] and keeps its existing handler, so this
/// cannot regress the OAuth flow.
///
/// `AppLinks()` is a singleton whose `uriLinkStream` is a broadcast stream
/// (app_links 6.4.1), so adding this listener does not displace the one in
/// `batch_extraction_provider.dart`: both receive every link.
class DeepLinkController {
  DeepLinkController({
    required this.onNavigate,
    this.navigateTo,
    AppLinks? links,
    this.enabled = true,
  }) : _links = links ?? AppLinks();

  /// The router's `go`.
  final void Function(String location) onNavigate;

  /// Where the app currently is, so a link to the current route does not
  /// push a duplicate. Optional: a null skips the check.
  final String? Function()? navigateTo;

  final AppLinks _links;

  /// False disables the controller entirely (tests, or a build that should
  /// ignore campaign links).
  final bool enabled;

  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  /// Starts listening. Idempotent, never throws: a link that cannot be read
  /// must not stop the app from starting.
  Future<void> start() async {
    if (!enabled || _started) return;
    _started = true;

    try {
      final initial = await _links.getInitialLink();
      if (initial != null) handle(initial);
    } catch (error) {
      // No launch link, or no platform implementation (tests, desktop).
      _debug(error);
    }

    try {
      _subscription = _links.uriLinkStream.listen(
        handle,
        onError: _debug,
      );
    } catch (error) {
      _debug(error);
    }
  }

  /// Navigates for [uri] when it is ours. Returns true when it navigated.
  ///
  /// Public so the mapping is testable without a platform channel.
  bool handle(Uri uri) {
    final location = resolveDeepLink(uri);
    if (location == null) return false;
    if (navigateTo?.call() == location) return false;
    onNavigate(location);
    return true;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _debug(Object error) {
    if (kDebugMode) debugPrint('DeepLinkController: $error');
  }
}

/// Starts [controller] the first time the root navigator pushes a route.
///
/// Deferred rather than started in `buildRouter` because `AppLinks` needs an
/// initialised binding: tests that only read the route table
/// (`appRouter.configuration.findMatch`) never push, so they never touch the
/// plugin.
class DeepLinkStarter extends NavigatorObserver {
  DeepLinkStarter(this._controller);

  final DeepLinkController _controller;
  bool _started = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_started) return;
    _started = true;
    unawaited(_controller.start());
  }
}
