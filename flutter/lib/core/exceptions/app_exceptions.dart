import 'dart:io';
import 'package:dio/dio.dart';

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const AppException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    int? statusCode,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection. Please check your network.',
      errorCode: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timed out. Please try again.',
      errorCode: 'TIMEOUT',
    );
  }

  factory NetworkException.serverError({int? statusCode}) {
    return NetworkException(
      message: statusCode == 503
          ? 'Service temporarily unavailable. Please try again later.'
          : 'Server error. Please try again later.',
      statusCode: statusCode,
      errorCode: 'SERVER_ERROR',
    );
  }
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    int? statusCode,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'Please login to continue',
      statusCode: 401,
      errorCode: 'UNAUTHORIZED',
    );
  }

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Invalid email or password',
      statusCode: 401,
      errorCode: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthException.sessionExpired() {
    return const AuthException(
      message: 'Your session has expired. Please login again.',
      statusCode: 401,
      errorCode: 'SESSION_EXPIRED',
    );
  }

  factory AuthException.tokenRefreshFailed() {
    return const AuthException(
      message: 'Failed to refresh session. Please login again.',
      errorCode: 'TOKEN_REFRESH_FAILED',
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: 422,
          errorCode: errorCode ?? 'VALIDATION_ERROR',
        );

  factory ValidationException.invalidInput({Map<String, String>? fieldErrors}) {
    return ValidationException(
      message: fieldErrors != null
          ? 'Please check your input and try again.'
          : 'Invalid input provided.',
      fieldErrors: fieldErrors,
    );
  }
}

/// Resource not found exception
class NotFoundException extends AppException {
  const NotFoundException({
    required String message,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: 404,
          errorCode: errorCode ?? 'NOT_FOUND',
        );

  factory NotFoundException.item(String itemId) {
    return NotFoundException(
      message: 'Item not found',
      errorCode: 'ITEM_NOT_FOUND',
    );
  }

  factory NotFoundException.outfit(String outfitId) {
    return NotFoundException(
      message: 'Outfit not found',
      errorCode: 'OUTFIT_NOT_FOUND',
    );
  }

  factory NotFoundException.user() {
    return const NotFoundException(
      message: 'User not found',
      errorCode: 'USER_NOT_FOUND',
    );
  }
}

/// Rate limit exception
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  const RateLimitException({
    required String message,
    this.retryAfterSeconds,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: 429,
          errorCode: errorCode ?? 'RATE_LIMIT_EXCEEDED',
        );

  factory RateLimitException.defaultError({int? retryAfter}) {
    return RateLimitException(
      message: retryAfter != null
          ? 'Too many requests. Please try again in $retryAfter seconds.'
          : 'Too many requests. Please try again later.',
      retryAfterSeconds: retryAfter,
    );
  }
}

/// Server/API exceptions
class ServerException extends AppException {
  const ServerException({
    required String message,
    required int statusCode,
    String? errorCode,
  }) : super(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

  factory ServerException.internalError() {
    return const ServerException(
      message: 'An internal server error occurred. Please try again later.',
      statusCode: 500,
      errorCode: 'INTERNAL_ERROR',
    );
  }

  factory ServerException.badGateway() {
    return const ServerException(
      message: 'Bad gateway. Please try again later.',
      statusCode: 502,
      errorCode: 'BAD_GATEWAY',
    );
  }

  factory ServerException.serviceUnavailable() {
    return const ServerException(
      message: 'Service temporarily unavailable. Please try again later.',
      statusCode: 503,
      errorCode: 'SERVICE_UNAVAILABLE',
    );
  }
}

/// File upload exceptions
class FileUploadException extends AppException {
  const FileUploadException({
    required String message,
    String? errorCode,
  }) : super(
          message: message,
          errorCode: errorCode ?? 'FILE_UPLOAD_ERROR',
        );

  factory FileUploadException.fileTooLarge(int maxSizeMB) {
    return FileUploadException(
      message: 'File is too large. Maximum size is $maxSizeMB MB.',
      errorCode: 'FILE_TOO_LARGE',
    );
  }

  factory FileUploadException.invalidFormat() {
    return const FileUploadException(
      message: 'Invalid file format. Please upload a valid image.',
      errorCode: 'INVALID_FORMAT',
    );
  }

  factory FileUploadException.uploadFailed() {
    return const FileUploadException(
      message: 'Failed to upload file. Please try again.',
      errorCode: 'UPLOAD_FAILED',
    );
  }
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? errorCode,
  }) : super(
          message: message,
          errorCode: errorCode ?? 'CACHE_ERROR',
        );

  factory CacheException.notFound() {
    return const CacheException(
      message: 'Cached data not found',
      errorCode: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheException.corrupted() {
    return const CacheException(
      message: 'Cached data is corrupted',
      errorCode: 'CACHE_CORRUPTED',
    );
  }
}

/// Utility function to convert DioException to AppException
AppException handleDioException(DioException error) {
  String? responseMessage() {
    final data = error.response?.data;
    if (data is Map) {
      if (data['message'] != null) {
        return data['message']?.toString();
      }
      if (data['error'] != null) {
        return data['error']?.toString();
      }
      if (data['detail'] != null) {
        return data['detail']?.toString();
      }
    }
    return null;
  }

  String? responseCode() {
    final data = error.response?.data;
    if (data is Map && data['code'] != null) {
      return data['code']?.toString();
    }
    return null;
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException.timeout();

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;

      switch (statusCode) {
        case 401:
          return AuthException.unauthorized();
        case 403:
          return const AuthException(
            message: "You don't have permission to perform this action",
            statusCode: 403,
            errorCode: 'FORBIDDEN',
          );
        case 404:
          return NotFoundException(
            message: responseMessage() ?? 'Resource not found',
          );
        case 422:
          return ValidationException(
            message: responseMessage() ?? 'Validation error',
          );
        case 429:
          final retryAfter = error.response?.headers['retry-after']?.first;
          return RateLimitException.defaultError(
            retryAfter: retryAfter != null ? int.tryParse(retryAfter) : null,
          );
        case 500:
          return ServerException(
            message: responseMessage() ??
                'An internal server error occurred. Please try again later.',
            statusCode: 500,
            errorCode: responseCode() ?? 'INTERNAL_ERROR',
          );
        case 502:
          return ServerException(
            message: responseMessage() ?? 'Bad gateway. Please try again later.',
            statusCode: 502,
            errorCode: responseCode() ?? 'BAD_GATEWAY',
          );
        case 503:
          return ServerException(
            message: responseMessage() ??
                'Service temporarily unavailable. Please try again later.',
            statusCode: 503,
            errorCode: responseCode() ?? 'SERVICE_UNAVAILABLE',
          );
        default:
          final fallback = responseMessage();
          if (fallback != null && fallback.isNotEmpty) {
            return NetworkException(
              message: fallback,
              statusCode: statusCode,
              errorCode: responseCode(),
            );
          }
          return NetworkException.serverError(statusCode: statusCode);
      }

    case DioExceptionType.cancel:
      return const NetworkException(
        message: 'Request was cancelled',
        errorCode: 'REQUEST_CANCELLED',
      );

    case DioExceptionType.connectionError:
      final rootError = error.error;
      if (rootError is SocketException) {
        final message = rootError.message.toLowerCase();
        if (message.contains('connection refused')) {
          return const NetworkException(
            message: 'Unable to reach server. Please try again shortly.',
            errorCode: 'CONNECTION_REFUSED',
          );
        }
        if (message.contains('failed host lookup') ||
            message.contains('name or service not known')) {
          return const NetworkException(
            message: 'Server address unavailable. Please try again.',
            errorCode: 'HOST_LOOKUP_FAILED',
          );
        }
      }
      return NetworkException.noConnection();

    case DioExceptionType.unknown:
    default:
      return NetworkException(
        message: error.message ?? 'An unexpected error occurred',
      );
  }
}
