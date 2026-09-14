import 'dart:async';
import 'dart:convert';

import 'package:fitcheck_ai/core/network/auth_refresh_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://project.example';

String _session(String token) => jsonEncode({
  'access_token': token,
  'refresh_token': 'synthetic-refresh',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': {'id': 'synthetic-user'},
});

void main() {
  test('only the configured refresh endpoint converts rate limits', () async {
    final client = AuthRefreshHttpClient(
      supabaseUrl: _supabaseUrl,
      client: MockClient((_) async => http.Response('rate limited', 429)),
    );
    addTearDown(client.close);
    await expectLater(
      client.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
      ),
      throwsA(isA<AuthRetryableFetchException>()),
    );
    for (final url in [
      '$_supabaseUrl/auth/v1/token?grant_type=password',
      '$_supabaseUrl/auth/v1/user?grant_type=refresh_token',
      'https://other.example/auth/v1/token?grant_type=refresh_token',
      'http://project.example/auth/v1/token?grant_type=refresh_token',
    ]) {
      final response = await client.post(Uri.parse(url));
      expect(response.statusCode, 429);
      expect(response.body, 'rate limited');
    }
    expect(
      (await client.get(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
      )).statusCode,
      429,
    );
  });

  test(
    'real SDK retains the session during a rate limit and then refreshes',
    () async {
      var requests = 0;
      final retryStarted = Completer<void>();
      final retriedResponse = Completer<http.Response>();
      final client = AuthRefreshHttpClient(
        supabaseUrl: _supabaseUrl,
        client: MockClient((_) async {
          requests++;
          if (requests == 1) {
            return http.Response('{"message":"rate limited"}', 429);
          }
          retryStarted.complete();
          return retriedResponse.future;
        }),
      );
      final auth = GoTrueClient(
        url: '$_supabaseUrl/auth/v1',
        autoRefreshToken: false,
        httpClient: client,
      );
      addTearDown(() {
        auth.dispose();
        client.close();
      });
      final events = <AuthChangeEvent>[];
      final subscription = auth.onAuthStateChange.listen(
        (state) => events.add(state.event),
        onError: (Object _, StackTrace _) {},
      );
      addTearDown(subscription.cancel);
      await auth.setInitialSession(_session('old'));
      final refresh = auth.refreshSession();
      await retryStarted.future;
      expect(auth.currentSession?.accessToken, 'old');
      expect(events, isNot(contains(AuthChangeEvent.signedOut)));
      retriedResponse.complete(http.Response(_session('refreshed'), 200));
      await refresh;
      expect(auth.currentSession?.accessToken, 'refreshed');
      expect(requests, 2);
    },
  );

  test('real SDK still rejects invalid refresh credentials', () async {
    final client = AuthRefreshHttpClient(
      supabaseUrl: _supabaseUrl,
      client: MockClient(
        (_) async => http.Response(
          '{"message":"invalid refresh token","error_code":"refresh_token_not_found"}',
          400,
        ),
      ),
    );
    final auth = GoTrueClient(
      url: '$_supabaseUrl/auth/v1',
      autoRefreshToken: false,
      httpClient: client,
    );
    addTearDown(() {
      auth.dispose();
      client.close();
    });
    await auth.setInitialSession(_session('old'));
    await expectLater(auth.refreshSession(), throwsA(isA<AuthException>()));
    expect(auth.currentSession, isNull);
  });

  test(
    'real SDK preserves a newer login after an old refresh is rejected',
    () async {
      final started = Completer<void>();
      final response = Completer<http.Response>();
      final client = MockClient((request) async {
        if (request.url.queryParameters['grant_type'] == 'refresh_token') {
          started.complete();
          return response.future;
        }
        return http.Response(_session('new-login'), 200);
      });
      final auth = GoTrueClient(
        url: '$_supabaseUrl/auth/v1',
        autoRefreshToken: false,
        httpClient: client,
      );
      addTearDown(() {
        auth.dispose();
        client.close();
      });
      await auth.setInitialSession(_session('old'));
      final refresh = expectLater(
        auth.refreshSession(),
        throwsA(isA<AuthException>()),
      );
      await started.future;
      await auth.signInWithPassword(
        email: 'synthetic@example.invalid',
        password: 'synthetic',
      );
      response.complete(
        http.Response(
          '{"message":"invalid refresh token","error_code":"refresh_token_not_found"}',
          400,
        ),
      );
      await refresh;
      expect(auth.currentSession?.accessToken, 'new-login');
    },
  );
}
