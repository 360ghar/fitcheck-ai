// Tests for the two pure helpers behind every network image in the app.
//
// WHAT THESE PIN, and why each one is a real bug and not a hypothetical:
//
// stableCacheKey — `CachedNetworkImage` keys its disk cache on the full URL by
// default. Presigned URLs embed `X-Amz-Date` + `X-Amz-Signature`, both of which
// change on EVERY read-path materialization, so a URL-keyed cache never hits: a
// wardrobe screen re-downloads images it already has AND writes a fresh entry
// each time, evicting reusable ones against flutter_cache_manager's object cap.
// Keying on host+path makes the entry survive signature rotation, and makes the
// same object share one entry across presigned and worker-mode URLs.
//
// authHeadersForUrl — gating only on "is not presigned" attached the user's live
// Supabase access token to ANY url passed to these widgets, including
// third-party image hosts (social-import thumbnails, OAuth provider avatars).
// That hands a working session credential to someone else's CDN. The guard is
// now a host allowlist.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitcheck_ai/core/widgets/app_network_image.dart';

const _user = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _name = '0123456789abcdef0123456789abcdef';

/// A valid 1x1 transparent PNG.
const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

String _presigned(String signature) =>
    'https://acct.r2.cloudflarestorage.com/bucket/$_user/items/$_name.webp'
    '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20260805T120000Z'
    '&X-Amz-Expires=3600&X-Amz-Signature=$signature';

void main() {
  _fallbackTests();
  group('stableCacheKey', () {
    test('is identical across presigned signature rotation', () {
      // The whole point: two materializations of the SAME object must share one
      // cache entry.
      final first = stableCacheKey(_presigned('aaa111'));
      final second = stableCacheKey(_presigned('bbb222'));

      expect(first, isNotNull);
      expect(first, second);
      expect(first, contains('$_user/items/$_name.webp'));
      expect(first, isNot(contains('X-Amz')));
    });

    test('drops the query string entirely', () {
      expect(
        stableCacheKey('https://images.fitcheckaiapp.com/a/items/b.webp?v=1&t=2'),
        'images.fitcheckaiapp.com/a/items/b.webp',
      );
    });

    test('includes the host so two providers cannot collide mid-migration', () {
      final railway = stableCacheKey(
        'https://t3.storageapi.dev/bucket/$_user/items/$_name.webp',
      );
      final r2 = stableCacheKey(
        'https://acct.r2.cloudflarestorage.com/bucket/$_user/items/$_name.webp',
      );
      expect(railway, isNot(r2));
    });

    test('distinguishes an object from its thumbnail sibling', () {
      final full = stableCacheKey('https://h/x/items/$_name.webp');
      final thumb = stableCacheKey('https://h/x/items/${_name}_thumb.webp');
      expect(full, isNot(thumb));
    });

    test('returns null when there is no meaningful path to key on', () {
      expect(stableCacheKey(''), isNull);
      expect(stableCacheKey('not a url'), isNull);
      expect(stableCacheKey('https://example.com'), isNull);
      expect(stableCacheKey('https://example.com/'), isNull);
      // data:/blob: have no cacheable identity — fall back to default keying.
      expect(stableCacheKey('data:image/png;base64,AAAA'), isNull);
      expect(stableCacheKey('blob:https://x/abc'), isNull);
    });
  });

  group('authHeadersForUrl', () {
    test('never attaches a token to a presigned URL', () {
      // S3/R2 reject a request carrying both a signature and another auth
      // mechanism ("Only one auth mechanism allowed").
      expect(authHeadersForUrl(_presigned('aaa111')), isNull);
    });

    test('never attaches a token to a third-party host', () {
      // The token-leak case: these all render through the same widgets.
      const foreign = [
        'https://scontent.cdninstagram.com/v/t51/abc.jpg',
        'https://i.pinimg.com/originals/ab/cd.jpg',
        'https://lh3.googleusercontent.com/a/ACw8oPics=w96-h96',
        'https://proj.supabase.co/storage/v1/object/public/img/a.png',
        // Look-alike domains must not match the allowlist suffix check.
        'https://fitcheckaiapp.com.evil.example/x/items/y.webp',
        'https://notfitcheckaiapp.com/x/items/y.webp',
      ];
      for (final url in foreign) {
        expect(authHeadersForUrl(url), isNull, reason: 'must not send a token to $url');
      }
    });

    test('returns null for our own host when there is no session', () {
      // Supabase is uninitialized under `flutter test`, which is the same code
      // path as signed-out: the helper must degrade to null, never throw.
      expect(
        authHeadersForUrl('https://images.fitcheckaiapp.com/$_user/items/$_name.webp'),
        isNull,
      );
    });

    test('returns null for malformed input instead of throwing', () {
      expect(authHeadersForUrl(''), isNull);
      expect(authHeadersForUrl('://'), isNull);
      expect(authHeadersForUrl('/relative/path.webp'), isNull);
    });
  });

  group('AppNetworkImage data-URI rendering', () {
    // The AI generation flows preview live output as data URIs until the
    // durable URL arrives. CachedNetworkImage cannot decode those, so the
    // widget must route them through Image.memory instead — these pin that
    // routing and the decode-failure fallback.

    testWidgets('renders a valid data URI from its embedded bytes', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage('data:image/png;base64,$_tinyPngBase64'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(
        find.byType(CachedNetworkImage),
        findsNothing,
        reason:
            'a data URI must never reach CachedNetworkImage, which cannot '
            'decode it',
      );
    });

    testWidgets('surfaces the error widget for a malformed data URI', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              'data:image/png;base64,@@@not-base64@@@',
              errorWidget: (context, url, error) => const Text('broken-tile'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('broken-tile'), findsOneWidget);
      expect(
        find.byType(CachedNetworkImage),
        findsNothing,
        reason: 'a malformed data URI must fail fast without a network round '
            'trip',
      );
    });

    testWidgets('falls back to the broken-image icon without an errorWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage('data:image/png;base64,@@@not-base64@@@'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(
        find.byType(CachedNetworkImage),
        findsNothing,
      );
    });
  });
}

// resolveFallbackUrl — a derived `thumbnail_url` (`{key}_thumb.webp`) is emitted
// by `materialize_image_urls` with NO existence check, and the object
// legitimately may not exist: `_upload_thumbnail` is best-effort and writes
// nothing when the bytes cannot be decoded or the upload fails, and the whole
// pre-feature corpus has none until the backfill script runs. Clients pick
// `thumbnail_url ?? image_url`, which only falls back on an EMPTY field — never
// on a 404 — so a missing thumb left a permanently broken tile while the
// full-size image was present and healthy. AppNetworkImage retries the full size
// once; this pins which fallbacks are worth retrying at all.
void _fallbackTests() {
  group('resolveFallbackUrl', () {
    const thumb = 'https://images.fitcheckaiapp.com/$_user/items/${_name}_thumb.webp';
    const full = 'https://images.fitcheckaiapp.com/$_user/items/$_name.webp';

    test('keeps a distinct full-size fallback', () {
      expect(resolveFallbackUrl(thumb, full), full);
    });

    test('drops a fallback identical to the primary URL', () {
      // The backend mirrors thumbnail_url onto image_url when thumbnail serving
      // is off; retrying the same URL only burns a second request.
      expect(resolveFallbackUrl(full, full), isNull);
    });

    test('treats null and empty as no fallback', () {
      expect(resolveFallbackUrl(thumb, null), isNull);
      expect(resolveFallbackUrl(thumb, ''), isNull);
    });
  });
}
