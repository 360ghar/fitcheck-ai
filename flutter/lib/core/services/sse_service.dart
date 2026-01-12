import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_constants.dart';

/// Server-Sent Events (SSE) service for real-time updates
/// Used for batch extraction progress updates
class SSEService {
  SSEService._();
  static final SSEService instance = SSEService._();

  /// Connect to an SSE endpoint and return a stream of events
  ///
  /// [path] - The API path (e.g., '/api/v1/ai/batch-extract/{id}/events')
  /// [headers] - Additional headers to include
  Stream<ServerSentEvent> connect(
    String path, {
    Map<String, String>? headers,
    int maxRetries = 3,
  }) async* {
    final url = '${ApiConstants.baseUrl}$path';
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await for (final event in _connectInternal(url, headers: headers)) {
          retryCount = 0; // Reset on successful event
          yield event;

          // Check for terminal events
          if (_isTerminalEvent(event.type)) {
            return;
          }
        }
        // Stream ended normally
        return;
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('SSE connection error (attempt $retryCount/$maxRetries): $e');
        }
        if (retryCount >= maxRetries) {
          yield ServerSentEvent(
            type: 'error',
            data: {'message': 'Connection failed after $maxRetries attempts'},
          );
          rethrow;
        }
        // Exponential backoff with jitter
        final delay = Duration(
          milliseconds: (pow(2, retryCount) * 1000 + Random().nextInt(500)).toInt(),
        );
        await Future.delayed(delay);
      }
    }
  }

  /// Check if the event type is terminal (no more events expected)
  bool _isTerminalEvent(String type) {
    return [
      'job_complete',
      'job_failed',
      'job_cancelled',
    ].contains(type);
  }

  /// Internal connection method
  Stream<ServerSentEvent> _connectInternal(
    String url, {
    Map<String, String>? headers,
  }) async* {
    final client = http.Client();

    try {
      final request = http.Request('GET', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        ...?headers,
        ..._getAuthHeaders(),
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw SSEException(
          'SSE connection failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      String buffer = '';

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // Parse SSE format: "event: type\ndata: {...}\n\n"
        while (buffer.contains('\n\n')) {
          final eventEnd = buffer.indexOf('\n\n');
          final eventStr = buffer.substring(0, eventEnd);
          buffer = buffer.substring(eventEnd + 2);

          final event = _parseServerSentEvent(eventStr);
          if (event != null) {
            yield event;
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// Parse a single SSE event string
  ServerSentEvent? _parseServerSentEvent(String eventStr) {
    String? eventType;
    String? dataStr;

    for (final line in eventStr.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataStr = line.substring(5).trim();
      }
    }

    if (eventType != null) {
      Map<String, dynamic>? data;
      if (dataStr != null && dataStr.isNotEmpty) {
        try {
          data = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (_) {
          // If data isn't JSON, store as message
          data = {'message': dataStr};
        }
      }
      return ServerSentEvent(type: eventType, data: data);
    }
    return null;
  }

  /// Get authentication headers from Supabase session
  Map<String, String> _getAuthHeaders() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        return {'Authorization': 'Bearer ${session.accessToken}'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('SSE: Failed to get auth headers: $e');
      }
    }
    return {};
  }
}

/// SSE Event data class
class ServerSentEvent {
  final String type;
  final Map<String, dynamic>? data;

  const ServerSentEvent({
    required this.type,
    this.data,
  });

  @override
  String toString() => 'ServerSentEvent(type: $type, data: $data)';
}

/// SSE connection exception
class SSEException implements Exception {
  final String message;
  final int? statusCode;

  SSEException(this.message, {this.statusCode});

  @override
  String toString() => 'SSEException: $message (statusCode: $statusCode)';
}
