import 'dart:convert';

import 'package:fitcheck_ai/core/services/sse_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<List<ServerSentEvent>> parseChunks(List<List<int>> chunks) {
  final service = SSEService(
    clientFactory: () => MockClient.streaming(
      (_, _) async => http.StreamedResponse(Stream.fromIterable(chunks), 200),
    ),
  );
  return service.connect('/events', maxRetries: 1).toList();
}

void main() {
  test(
    'every byte boundary preserves CRLF framing and UTF-8 payloads',
    () async {
      final bytes = utf8.encode(
        'id: 7\r\nevent: job_complete\r\ndata: {"name":"café"}\r\n\r\n',
      );
      for (var split = 0; split <= bytes.length; split++) {
        final events = await parseChunks([
          bytes.sublist(0, split),
          bytes.sublist(split),
        ]);
        expect(events, hasLength(1), reason: 'split=$split');
        expect(events.single.type, 'job_complete', reason: 'split=$split');
        expect(events.single.id, 7, reason: 'split=$split');
        expect(events.single.data, {'name': 'café'}, reason: 'split=$split');
      }
      final oneByteChunks = await parseChunks(bytes.map((b) => [b]).toList());
      expect(oneByteChunks.single.data, {'name': 'café'});
    },
  );

  test('LF events, comments and multiline data remain supported', () async {
    final events = await parseChunks([
      utf8.encode(
        ': heartbeat\n\nevent: image_complete\nid: 1\ndata: {"id":\ndata: "image-1"}\n\n'
        'event: job_complete\ndata: {}\n\n',
      ),
    ]);
    expect(events.map((e) => e.type), ['image_complete', 'job_complete']);
    expect(events.first.data, {'id': 'image-1'});
  });

  test(
    'size limit applies to each event, not a burst of valid events',
    () async {
      final payload = 'a' * (2300 * 1024);
      final events = await parseChunks([
        utf8.encode(
          'event: image_complete\ndata: {"image":"$payload"}\n\n'
          'event: job_complete\ndata: {"image":"$payload"}\n\n',
        ),
      ]);
      expect(events.map((e) => e.type), ['image_complete', 'job_complete']);
    },
  );

  test('oversized unfinished or complete events fail once', () async {
    final payload = 'a' * (4 * 1024 * 1024);
    for (final ending in ['', '\n\n']) {
      final events = await parseChunks([
        utf8.encode('event: image_complete\ndata: $payload$ending'),
      ]);
      expect(events.map((e) => e.type), ['error']);
    }
  });
}
