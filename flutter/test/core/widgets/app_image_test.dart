// Tests for AppImage's re-mint-on-error fallback.
//
// WHY THIS EXISTS: the API serves short-lived presigned image URLs (1h TTL)
// materialized from a durable `storage_path` at read time. A URL cached in a
// model can therefore expire while the object is healthy, and with a disk
// cache miss the user is left staring at a permanent error tile. When the
// widget is given `storagePath` + `remintUrl`, a failed load must re-mint a
// fresh URL and retry exactly once — and never loop, crash, or re-mint when
// the caller provided no storage key.
//
// The widget under test uses CachedNetworkImage, whose default cache manager
// needs path_provider + sqflite (no test-host implementations). The tests
// therefore inject a channel-free CacheManager: a no-disk file system, a
// non-storing info repository, and a mock HTTP client that answers every
// request with 400 — the exact failure mode an expired presigned URL
// produces. All of it resolves on microtasks, so plain pumps drive it.

import 'dart:io' show HttpStatus;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' as fs;
import 'package:fitcheck_ai/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A [CacheManager] that never touches the platform: every HTTP request
/// fails with 400 (like an expired presigned URL) and any file write would
/// be a bug, so the file system throws if it is ever asked to create one.
CacheManager _failingImageCacheManager() {
  return CacheManager(
    Config(
      'app-image-test',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 100,
      repo: NonStoringObjectProvider(),
      fileSystem: _NoDiskFileSystem(),
      fileService: HttpFileService(
        httpClient: MockClient(
          (_) async => http.Response('expired', HttpStatus.badRequest),
        ),
      ),
    ),
  );
}

class _NoDiskFileSystem implements FileSystem {
  @override
  Future<fs.File> createFile(String name) {
    throw UnsupportedError(
      'app-image tests never write images to disk: every request 400s',
    );
  }
}

Widget _appImageHarness(AppImage image) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: AppImage(
          imageUrl: image.imageUrl,
          storagePath: image.storagePath,
          remintUrl: image.remintUrl,
          cacheManager: _failingImageCacheManager(),
        ),
      ),
    ),
  );
}

/// Fires the cache manager's one-shot cleanup timer (10s) so no timer is
/// left pending when the widget tree is torn down.
Future<void> flushCacheManagerTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppImage re-mint fallback', () {
    testWidgets(
      're-mints a fresh URL once when the primary URL fails and retries it',
      (tester) async {
        final remintCalls = <String>[];
        await tester.pumpWidget(
          _appImageHarness(
            AppImage(
              imageUrl: 'https://cdn.example.com/expired/1.png',
              storagePath: 'users/u/items/1.png',
              remintUrl: (storagePath) async {
                remintCalls.add(storagePath);
                return 'https://cdn.example.com/fresh/1.png';
              },
            ),
          ),
        );

        // First load fails (mock client 400s); the errorWidget renders and
        // schedules the post-frame re-mint.
        await tester.pump();
        await tester.pump();

        // Post-frame re-mint resolves; setState swaps in the fresh URL.
        await tester.pump();
        await tester.pump();

        // The fresh URL 400s too; the one-shot guard must not re-mint again.
        await tester.pump();
        await tester.pump();

        expect(
          remintCalls,
          ['users/u/items/1.png'],
          reason: 'the failed load must trigger exactly one re-mint of the '
              'durable storage key',
        );

        CachedNetworkImage renderedImage() =>
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(
          renderedImage().imageUrl,
          'https://cdn.example.com/fresh/1.png',
          reason: 'the widget must retry with the freshly minted URL, not the '
              'expired one',
        );
        expect(
          remintCalls,
          hasLength(1),
          reason: 'a second failure must not start an endless re-mint loop',
        );
        expect(
          find.byIcon(Icons.image_not_supported_outlined),
          findsOneWidget,
          reason: 'with both URLs unreadable the honest result is an error '
              'tile',
        );

        await flushCacheManagerTimers(tester);
      },
    );

    testWidgets('does not re-mint without a storagePath', (tester) async {
      var remintCalls = 0;
      await tester.pumpWidget(
        _appImageHarness(
          AppImage(
            imageUrl: 'https://cdn.example.com/expired/1.png',
            remintUrl: (_) async {
              remintCalls++;
              return 'https://cdn.example.com/fresh/1.png';
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        remintCalls,
        0,
        reason: 'without a durable storage key there is nothing safe to '
            're-mint from',
      );
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);

      await flushCacheManagerTimers(tester);
    });

    testWidgets('renders the error tile when re-minting returns null', (
      tester,
    ) async {
      final remintCalls = <String>[];
      await tester.pumpWidget(
        _appImageHarness(
          AppImage(
            imageUrl: 'https://cdn.example.com/expired/1.png',
            storagePath: 'users/u/items/1.png',
            remintUrl: (storagePath) async {
              remintCalls.add(storagePath);
              return null;
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        remintCalls,
        ['users/u/items/1.png'],
        reason: 'the re-mint must be attempted even when the backend cannot '
            'serve a fresh URL',
      );
      expect(remintCalls, hasLength(1));
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);

      await flushCacheManagerTimers(tester);
    });
  });
}
