import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitcheck_ai/core/network/api_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthRetryableFetchException;

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final int Function(RequestOptions) status;

  RecordingAdapter(this.status);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.copyWith(headers: Map.of(options.headers)));
    return ResponseBody.fromString(
      '{}',
      status(options),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  String token = 'old';
  int refreshes = 0;
  int signOuts = 0;
  int redirects = 0;
  late Future<void> Function() refresh;
  late Dio dio;

  setUp(() {
    token = 'old';
    refreshes = signOuts = redirects = 0;
    refresh = () async => token = 'new';
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
    dio.interceptors.addAll([
      AuthInterceptor(currentAccessToken: () => token),
      TokenRefreshInterceptor(
        dio,
        currentAccessToken: () => token,
        refreshSession: () async {
          refreshes++;
          await refresh();
        },
        signOut: () async {
          signOuts++;
        },
        onSessionRejected: () {
          redirects++;
        },
      ),
    ]);
  });
  tearDown(() => dio.close());

  test('trusted API and image origins receive the current token', () async {
    final adapter = RecordingAdapter((_) => 200);
    dio.httpClientAdapter = adapter;
    for (final url in [
      '/api/v1/items',
      'https://api.fitcheckaiapp.com/api/v1/items',
      'https://images.fitcheckaiapp.com/image.png',
    ]) {
      await dio.get(url);
    }
    expect(
      adapter.requests.map((r) => r.headers['Authorization']),
      everyElement('Bearer old'),
    );
  });

  test(
    'public 401s skip refresh and multipart requests are not replayed',
    () async {
      final adapter = RecordingAdapter((_) => 401);
      dio.httpClientAdapter = adapter;
      await expectLater(
        dio.get('/api/v1/auth/login'),
        throwsA(isA<DioException>()),
      );
      expect(refreshes, 0);
      expect(adapter.requests.single.headers['Authorization'], isNull);
      await expectLater(
        dio.post(
          '/api/v1/items/item-1/images',
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes([1, 2, 3], filename: 'photo.png'),
          }),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(2));
      expect(refreshes, 1);
    },
  );

  test(
    'foreign and presigned 401s never refresh or carry session auth',
    () async {
      final adapter = RecordingAdapter((_) => 401);
      dio.httpClientAdapter = adapter;
      for (final url in [
        'https://external.example/image.png',
        'https://images.fitcheckaiapp.com/image.png?X-Amz-Signature=abc',
        'https://images.fitcheckaiapp.com/image.png?x-amz-signature=abc',
        'https://fitcheckaiapp.com.external.example/image.png',
        'http://images.fitcheckaiapp.com/image.png',
      ]) {
        await expectLater(
          dio.get(
            url,
            options: Options(
              headers: {'authorization': 'Bearer accidental-session-token'},
            ),
          ),
          throwsA(isA<DioException>()),
        );
      }
      expect(refreshes, 0);
      expect(adapter.requests, hasLength(5));
      for (final request in adapter.requests) {
        expect(
          request.headers.keys.where((k) => k.toLowerCase() == 'authorization'),
          isEmpty,
        );
      }
    },
  );

  test(
    'concurrent trusted 401s share refresh and retry with the new token',
    () async {
      final gate = Completer<void>();
      refresh = () async {
        await gate.future;
        token = 'new';
      };
      final adapter = RecordingAdapter(
        (r) => r.headers['Authorization'] == 'Bearer new' ? 200 : 401,
      );
      dio.httpClientAdapter = adapter;
      final results = Future.wait([dio.get('/items'), dio.get('/outfits')]);
      while (adapter.requests.length < 2 || refreshes == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      gate.complete();
      expect((await results).map((r) => r.statusCode), [200, 200]);
      expect(refreshes, 1);
      expect(signOuts, 0);
    },
  );

  test('transient refresh failures do not trigger an extra sign-out', () async {
    dio.httpClientAdapter = RecordingAdapter((_) => 401);
    for (final error in [
      TimeoutException('offline'),
      AuthRetryableFetchException(statusCode: '503'),
      const AuthException('rate limited', statusCode: '429'),
      const AuthException('server unavailable', statusCode: '500'),
    ]) {
      refresh = () async => throw error;
      await expectLater(dio.get('/items'), throwsA(isA<DioException>()));
    }
    expect(signOuts, 0);
    expect(redirects, 0);
  });

  test('rejected credentials sign out once for concurrent failures', () async {
    final gate = Completer<void>();
    refresh = () async {
      await gate.future;
      throw const AuthException(
        'invalid refresh token',
        code: 'refresh_token_not_found',
        statusCode: '400',
      );
    };
    final adapter = RecordingAdapter((_) => 401);
    dio.httpClientAdapter = adapter;
    final requests = [
      expectLater(dio.get('/items'), throwsA(isA<DioException>())),
      expectLater(dio.get('/outfits'), throwsA(isA<DioException>())),
    ];
    while (adapter.requests.length < 2 || refreshes == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    gate.complete();
    await Future.wait(requests);
    expect(refreshes, 1);
    expect(signOuts, 1);
    expect(redirects, 1);
  });

  test('an old refresh rejection cannot sign out a newer login', () async {
    final started = Completer<void>();
    final rejected = Completer<void>();
    refresh = () async {
      started.complete();
      await rejected.future;
      throw const AuthException(
        'invalid refresh token',
        code: 'refresh_token_not_found',
        statusCode: '400',
      );
    };
    dio.httpClientAdapter = RecordingAdapter((_) => 401);
    final request = expectLater(
      dio.get('/items'),
      throwsA(isA<DioException>()),
    );
    await started.future;
    token = 'new-login';
    rejected.complete();
    await request;
    expect(signOuts, 0);
    expect(redirects, 0);
  });

  test(
    'a second 401 is terminal and replay errors keep their real status',
    () async {
      for (final replayStatus in [401, 503]) {
        token = 'old';
        final adapter = RecordingAdapter(
          (r) =>
              r.headers['Authorization'] == 'Bearer new' ? replayStatus : 401,
        );
        dio.httpClientAdapter = adapter;
        await expectLater(
          dio.get('/items'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              replayStatus,
            ),
          ),
        );
        expect(adapter.requests, hasLength(2));
      }
      expect(refreshes, 2);
      expect(signOuts, 0);
    },
  );
}
