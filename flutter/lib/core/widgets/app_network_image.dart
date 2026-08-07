import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registrable domain whose hosts may receive the session bearer token.
///
/// Only our own image-serving hosts are allowed (`images.fitcheckaiapp.com`,
/// `api.fitcheckaiapp.com`). Gating on "is not presigned" instead would attach
/// the user's live access token to ANY url rendered through these widgets — an
/// Instagram/Pinterest thumbnail from social import, an OAuth provider avatar —
/// which hands a third-party CDN a working session credential.
const String _authTokenDomain = 'fitcheckaiapp.com';

bool _isOurHost(Uri uri) {
  final host = uri.host.toLowerCase();
  return host == _authTokenDomain || host.endsWith('.$_authTokenDomain');
}

/// Authorization headers for authenticated image fetches.
///
/// Worker-mode serving (infra/images-worker, `IMAGE_SERVING_MODE=worker`)
/// serves stable path-only URLs that REQUIRE the Supabase access token.
/// Presigned S3/R2 URLs must NOT receive an `Authorization` header — the
/// signature validation rejects requests carrying any other auth mechanism
/// ("Only one auth mechanism allowed"). The presence of `X-Amz-` query
/// parameters distinguishes the two.
///
/// Returns null when signed out, when the URL is presigned, when the host is not
/// ours, or when the Supabase client is not initialized (widget tests), so
/// callers can always pass the result straight into `httpHeaders`.
Map<String, String>? authHeadersForUrl(String url) {
  if (!urlAcceptsAuthToken(url)) {
    return null;
  }
  try {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }
    return {'Authorization': 'Bearer $token'};
  } catch (_) {
    return null; // uninitialized client (widget tests)
  }
}

/// Whether [url] may carry the session bearer token — the URL-only half of
/// [authHeadersForUrl].
///
/// Split out because it is PURE (it depends on nothing but the URL) and so can be
/// computed once per URL, whereas the token read in [authHeadersForUrl]
/// deliberately cannot be cached: the Supabase session rotates, and a widget that
/// memoized its headers would keep presenting an expired token and start 401ing.
bool urlAcceptsAuthToken(String url) {
  if (url.contains('X-Amz-')) {
    return false; // presigned URL: a bearer header would break the signature
  }
  final uri = Uri.tryParse(url);
  // Never leak the session token to a third-party host.
  return uri != null && uri.hasScheme && _isOurHost(uri);
}

/// A disk-cache key that survives presigned-URL rotation.
///
/// `CachedNetworkImage` keys its cache on the full URL by default, and a
/// presigned URL embeds `X-Amz-Date` + `X-Amz-Signature` that change on EVERY
/// read-path materialization. Keyed that way, the disk cache never hits: each
/// wardrobe load writes fresh entries for images it already had and evicts
/// genuinely reusable ones against `flutter_cache_manager`'s object cap. That is
/// the same "rotating URLs bust every cache" problem the egress RCA is about —
/// on the client side.
///
/// Keying on host + path instead makes the entry stable across signature
/// rotation, which is what turns the disk cache on.
///
/// It is deliberately NOT stable across a change of serving host or bucket: a
/// presigned URL (`<account>.r2.../<bucket>/<key>`) and a worker URL
/// (`images.…/<key>`) key differently, so flipping `IMAGE_SERVING_MODE` or
/// migrating buckets invalidates the cache once and is stable thereafter. That is
/// the right trade — two different hosts could legitimately serve different bytes
/// for the same path, and a one-time refill is cheap.
///
/// Returns null for a data:/blob: style URL with no meaningful path, so the
/// caller falls back to the default (URL-keyed) behaviour.
String? stableCacheKey(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.path.isEmpty || uri.path == '/') {
    return null;
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return null;
  }
  // Host is included so two providers' identically-named keys cannot collide
  // (e.g. during a bucket migration when both hosts are briefly in play).
  return '${uri.host}${uri.path}';
}

/// The fallback worth retrying for [url], or null if there is none.
///
/// A fallback identical to the primary URL is dropped: the backend mirrors
/// `thumbnail_url` onto `image_url` when thumbnail serving is off or the key
/// carries no thumb, and retrying the same URL would just fail again after a
/// second request. Empty strings are treated as absent.
String? resolveFallbackUrl(String url, String? fallbackUrl) {
  if (fallbackUrl == null || fallbackUrl.isEmpty || fallbackUrl == url) {
    return null;
  }
  return fallbackUrl;
}

/// A `CachedNetworkImageProvider` for [url] with the cache key and auth headers
/// already applied.
///
/// Use this instead of constructing `CachedNetworkImageProvider` directly. The two
/// arguments are a pair and must never be applied by halves: omit `headers` and
/// every worker-mode image 404s for that surface, omit `cacheKey` and the disk
/// cache misses on every presigned load while still writing a fresh entry each
/// time — the exact client-side waste the egress work exists to remove. Neither
/// failure is visible in `presigned` mode, which is how the flag ships today, so
/// a half-applied call site would go unnoticed until the cutover.
CachedNetworkImageProvider appImageProvider(String url) {
  return CachedNetworkImageProvider(
    url,
    cacheKey: stableCacheKey(url),
    headers: authHeadersForUrl(url),
  );
}

/// Drop-in replacement for `Image.network` with disk caching + auth.
///
/// Renders exactly like `Image.network` (transparent background, no shimmer,
/// no tap-to-zoom — those belong to `AppImage`) while fetching through
/// `CachedNetworkImage` so bytes persist on disk across sessions, and
/// attaching the Supabase access token when the URL is an authenticated
/// worker-mode CDN URL (see [authHeadersForUrl]).
///
/// This is the disk-cache half of the egress RCA fix
/// (docs/exec-plans/active/2026-08-05-railway-egress-rca.md): stable URLs +
/// disk cache means a wardrobe screen renders without re-downloading.
class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.fallbackUrl,
  });

  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;

  /// Full-size URL to retry once if [url] fails.
  ///
  /// Read paths derive `thumbnail_url` as `{key}_thumb.webp` from the parent key
  /// with NO existence check (`materialize_image_urls`), and that object
  /// legitimately may not exist: `_upload_thumbnail` is best-effort and writes
  /// nothing when the bytes cannot be decoded or the upload fails, and the whole
  /// pre-feature corpus has no thumb until the backfill script has run. Clients
  /// pick `thumbnail_url ?? image_url`, which only falls back on an EMPTY field —
  /// never on a 404 — so a missing thumb left a permanently broken tile even
  /// though the full-size image was present and healthy. Pass `image_url` here
  /// wherever `thumbnail_url` is rendered.
  final String? fallbackUrl;

  /// Error widget builder, same signature as `CachedNetworkImage.errorWidget`
  /// (`(context, url, error)`) so call sites converting from
  /// `Image.network(errorBuilder: (context, error, stackTrace) => ...)` can
  /// pass their existing builder unchanged.
  final Widget Function(BuildContext, String, Object?)? errorWidget;

  /// Memory decode width/height (pixels); bounds decode memory for tiny tiles.
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  bool _usingFallback = false;

  // Derived from the active URL and cached, because `build` runs per frame for
  // every visible tile on a scrolling grid — which is precisely the surface this
  // widget was introduced for. Parsing the URL twice per frame per tile (once for
  // the cache key, once for the host check) is pure waste when the inputs only
  // change on a fallback swap or a new widget configuration.
  //
  // The bearer token is deliberately NOT cached here (see urlAcceptsAuthToken):
  // the Supabase session rotates, so it is read fresh each build and only when the
  // host actually accepts it.
  late String _activeUrl;
  String? _fallback;
  String? _cacheKey;
  bool _authEligible = false;

  @override
  void initState() {
    super.initState();
    _resolveActiveUrl();
  }

  @override
  void didUpdateWidget(AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A stale failure must never suppress a freshly-minted URL.
    if (oldWidget.url != widget.url || oldWidget.fallbackUrl != widget.fallbackUrl) {
      _usingFallback = false;
      _resolveActiveUrl();
    }
  }

  void _resolveActiveUrl() {
    _fallback = resolveFallbackUrl(widget.url, widget.fallbackUrl);
    _activeUrl = _usingFallback && _fallback != null ? _fallback! : widget.url;
    _cacheKey = stableCacheKey(_activeUrl);
    _authEligible = urlAcceptsAuthToken(_activeUrl);
  }

  @override
  Widget build(BuildContext context) {
    final fallback = _fallback;

    return CachedNetworkImage(
      imageUrl: _activeUrl,
      // Signature-stable key, or the disk cache misses on every load while
      // still writing a new entry each time (see stableCacheKey).
      cacheKey: _cacheKey,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: widget.cacheWidth,
      memCacheHeight: widget.cacheHeight,
      httpHeaders: _authEligible ? authHeadersForUrl(_activeUrl) : null,
      errorWidget: (context, failedUrl, error) {
        // Retry once with the full size before calling the tile broken. The
        // rebuild is scheduled rather than applied inline because errorWidget
        // runs during build.
        if (!_usingFallback && fallback != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_usingFallback) {
              setState(() {
                _usingFallback = true;
                _resolveActiveUrl();
              });
            }
          });
          return SizedBox(width: widget.width, height: widget.height);
        }
        final builder = widget.errorWidget;
        if (builder != null) {
          return builder(context, failedUrl, error);
        }
        return const Icon(Icons.broken_image_outlined);
      },
    );
  }
}
