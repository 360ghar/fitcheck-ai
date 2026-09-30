import 'package:fitcheck_ai/features/wardrobe/providers/extraction_jobs_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// The jobs registry persists across app kills, so the tracked-job shape
/// must survive a JSON round trip without losing the photo mapping (resume
/// rebuilds per-photo cards from it) or the notified flag (no double
/// shade alerts after restart).
void main() {
  TrackedJob job() => TrackedJob(
    jobId: 'job-1',
    kind: TrackedJobKind.batch,
    label: '3 photos',
    sourcePaths: const ['/a.jpg', '/b.jpg', '/c.jpg'],
    sourceIds: const ['img-1', 'img-2', 'img-3'],
    createdAt: DateTime.utc(2026, 9, 26),
    extracted: 2,
    generated: 1,
    total: 4,
  );

  test('TrackedJob survives a JSON round trip', () {
    final restored = TrackedJob.fromJson(job().toJson());

    expect(restored.jobId, 'job-1');
    expect(restored.kind, TrackedJobKind.batch);
    expect(restored.label, '3 photos');
    expect(restored.sourcePaths, hasLength(3));
    expect(restored.sourceIds, ['img-1', 'img-2', 'img-3']);
    expect(restored.extracted, 2);
    expect(restored.generated, 1);
    expect(restored.total, 4);
    expect(restored.isActive, isTrue);
  });

  test('the notified flag survives a JSON round trip', () {
    expect(TrackedJob.fromJson(job().toJson()).notified, isFalse);

    final restored = TrackedJob.fromJson(
      job().copyWith(notified: true).toJson(),
    );

    expect(restored.notified, isTrue);
  });

  test('progress falls back to photo counts when the total is unknown', () {
    final pending = job().copyWith(total: 0, extracted: 0, generated: 0);

    expect(pending.progress, 0);
    expect(pending.progressText, 'Looking at your photos');
  });

  test('progressText narrates each terminal state', () {
    expect(job().progressText, '1 of 4 studio photos');
    expect(
      job().copyWith(status: TrackedJobStatus.complete).progressText,
      'Ready to review',
    );
    expect(
      job()
          .copyWith(status: TrackedJobStatus.failed, error: 'Boom')
          .progressText,
      'Boom',
    );
    expect(
      job().copyWith(status: TrackedJobStatus.cancelled).progressText,
      'Cancelled',
    );
  });

  group('progress units (3 photos, 6 pieces)', () {
    TrackedJob at({int extracted = 0, int generated = 0, int total = 0}) =>
        job().copyWith(
          extracted: extracted,
          generated: generated,
          total: total,
        );

    test('reading photos alone stops at the first half', () {
      expect(at(extracted: 3, total: 6).progress, closeTo(0.5, 1e-9));
      expect(at(extracted: 3, total: 6).progressText, '6 pieces found so far');
    });

    test('half the studio photos after all photos read is 75 percent', () {
      final j = at(extracted: 3, generated: 3, total: 6);
      expect(j.progress, closeTo(0.75, 1e-9));
      expect(j.progressText, '3 of 6 studio photos');
    });

    test('photo count never reads as generated pieces', () {
      // Old math: (3 photos + 0 generated) / 6 pieces = 50 percent with
      // nothing generated; the text also claimed studio photos.
      final j = at(extracted: 1, total: 6);
      expect(j.progress, closeTo(1 / 6, 1e-9));
      expect(j.progressText, '6 pieces found so far');
    });

    test('a complete job is always full', () {
      expect(
        at(extracted: 1).copyWith(status: TrackedJobStatus.complete).progress,
        1,
      );
    });
  });
}
