import 'package:dio/dio.dart';
import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException hierarchy', () {
    test('NetworkException is an AppException', () {
      final e = NetworkException.noConnection();
      expect(e, isA<AppException>());
      expect(e, isA<NetworkException>());
    });

    test('AuthException is an AppException', () {
      final e = AuthException.unauthorized();
      expect(e, isA<AppException>());
      expect(e, isA<AuthException>());
    });

    test('ValidationException is an AppException', () {
      final e = ValidationException.invalidInput();
      expect(e, isA<AppException>());
      expect(e, isA<ValidationException>());
      expect(e.statusCode, 422);
    });

    test('NotFoundException is an AppException', () {
      final e = NotFoundException.item('abc');
      expect(e, isA<AppException>());
      expect(e, isA<NotFoundException>());
      expect(e.statusCode, 404);
    });

    test('RateLimitException is an AppException', () {
      final e = RateLimitException.defaultError(retryAfter: 30);
      expect(e, isA<AppException>());
      expect(e, isA<RateLimitException>());
      expect(e.statusCode, 429);
      expect(e.retryAfterSeconds, 30);
    });

    test('ServerException is an AppException', () {
      final e = ServerException.internalError();
      expect(e, isA<AppException>());
      expect(e, isA<ServerException>());
      expect(e.statusCode, 500);
    });

    test('FileUploadException is an AppException', () {
      final e = FileUploadException.fileTooLarge(10);
      expect(e, isA<AppException>());
      expect(e, isA<FileUploadException>());
      expect(e.message, contains('10'));
    });

    test('CacheException is an AppException', () {
      final e = CacheException.corrupted();
      expect(e, isA<AppException>());
      expect(e, isA<CacheException>());
    });

    test('toString returns the message', () {
      final e = NetworkException.timeout();
      expect(e.toString(), e.message);
    });
  });

  group('Named constructors carry correct error codes', () {
    test('noConnection has NO_CONNECTION code', () {
      expect(NetworkException.noConnection().errorCode, 'NO_CONNECTION');
    });

    test('timeout has TIMEOUT code', () {
      expect(NetworkException.timeout().errorCode, 'TIMEOUT');
    });

    test('unauthorized has UNAUTHORIZED code', () {
      expect(AuthException.unauthorized().errorCode, 'UNAUTHORIZED');
    });

    test('sessionExpired has SESSION_EXPIRED code', () {
      expect(AuthException.sessionExpired().errorCode, 'SESSION_EXPIRED');
    });

    test('internalError has INTERNAL_ERROR code', () {
      expect(ServerException.internalError().errorCode, 'INTERNAL_ERROR');
    });

    test('serviceUnavailable has SERVICE_UNAVAILABLE code', () {
      expect(
        ServerException.serviceUnavailable().errorCode,
        'SERVICE_UNAVAILABLE',
      );
    });

    test('validation fieldErrors are preserved', () {
      final e = ValidationException.invalidInput(fieldErrors: {
        'email': 'Invalid email',
        'password': 'Too short',
      });
      expect(e.fieldErrors, isNotNull);
      expect(e.fieldErrors!['email'], 'Invalid email');
      expect(e.fieldErrors!['password'], 'Too short');
    });
  });

  group('handleDioException', () {
    RequestOptions reqOptions() => RequestOptions(path: '/test');

    DioException dioError({
      required DioExceptionType type,
      int? statusCode,
      Map<String, dynamic>? responseData,
    }) {
      return DioException(
        requestOptions: reqOptions(),
        type: type,
        response: statusCode != null
            ? Response(
                requestOptions: reqOptions(),
                statusCode: statusCode,
                data: responseData,
              )
            : null,
      );
    }

    test('connectionTimeout maps to NetworkException.timeout', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.connectionTimeout),
      );
      expect(result, isA<NetworkException>());
      expect(result.errorCode, 'TIMEOUT');
    });

    test('sendTimeout maps to NetworkException.timeout', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.sendTimeout),
      );
      expect(result.errorCode, 'TIMEOUT');
    });

    test('receiveTimeout maps to NetworkException.timeout', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.receiveTimeout),
      );
      expect(result.errorCode, 'TIMEOUT');
    });

    test('connectionError maps to NetworkException.noConnection', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.connectionError),
      );
      expect(result, isA<NetworkException>());
      expect(result.errorCode, 'NO_CONNECTION');
    });

    test('401 maps to AuthException.unauthorized', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 401),
      );
      expect(result, isA<AuthException>());
      expect(result.statusCode, 401);
    });

    test('403 maps to AuthException with FORBIDDEN code', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 403),
      );
      expect(result, isA<AuthException>());
      expect(result.errorCode, 'FORBIDDEN');
    });

    test('404 maps to NotFoundException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 404),
      );
      expect(result, isA<NotFoundException>());
    });

    test('422 maps to ValidationException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 422),
      );
      expect(result, isA<ValidationException>());
    });

    test('429 maps to RateLimitException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 429),
      );
      expect(result, isA<RateLimitException>());
    });

    test('429 with SERVER_BUSY code preserves code and message', () {
      // Server capacity is NOT the user's plan limit: the backend code +
      // message must survive the Dio mapping so the UI routes it to the
      // "AI busy" dialog, never the paywall CTA (2026-08-04).
      final result = handleDioException(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: 429,
          responseData: {
            'code': 'SERVER_BUSY',
            'error':
                "We're processing a lot of requests right now. Please try again in a minute.",
          },
        ),
      );
      expect(result, isA<RateLimitException>());
      expect(result.errorCode, 'SERVER_BUSY');
      expect(result.message, contains('try again in a minute'));
    });

    test('500 maps to ServerException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 500),
      );
      expect(result, isA<ServerException>());
      expect(result.statusCode, 500);
    });

    test('502 maps to ServerException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 502),
      );
      expect(result, isA<ServerException>());
      expect(result.statusCode, 502);
    });

    test('503 maps to ServerException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 503),
      );
      expect(result, isA<ServerException>());
      expect(result.statusCode, 503);
    });

    test('cancel maps to NetworkException with REQUEST_CANCELLED', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.cancel),
      );
      expect(result.errorCode, 'REQUEST_CANCELLED');
    });

    test('unknown maps to NetworkException', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.unknown),
      );
      expect(result, isA<NetworkException>());
    });

    test('response message is extracted from data map', () {
      final result = handleDioException(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          responseData: {'message': 'Custom server error'},
        ),
      );
      expect(result.message, 'Custom server error');
    });

    test('response code is extracted from data map', () {
      final result = handleDioException(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          responseData: {'code': 'CUSTOM_CODE'},
        ),
      );
      expect(result.errorCode, 'CUSTOM_CODE');
    });

    test('unmapped bad response status falls back to serverError', () {
      final result = handleDioException(
        dioError(type: DioExceptionType.badResponse, statusCode: 418),
      );
      expect(result, isA<NetworkException>());
      expect(result.errorCode, 'SERVER_ERROR');
    });
  });
}
