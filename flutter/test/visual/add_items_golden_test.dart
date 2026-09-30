@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/batch_extraction_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/item_add_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_extraction_progress_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_image_selector_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/batch_item_review_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_add_page.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/ai_extraction_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

/// Small tonal PNGs standing in for photos.
const _pixels = [
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANklEQVR4nGM4sqAJDTHsnFaJhhjW9RSgIYbFTRloiGFGRTwaYujNC0dDDE0pfmiIoSLKDQ0BAHstR61P2he0AAAAAElFTkSuQmCC',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANUlEQVR4nGOoaJ+Ghhjya3vQEENaSTMaYojLrkJDDKGJBWiIwTciHQ0xuPjHoSEGG7dQNAQAKQI567jy3/8AAAAASUVORK5CYII=',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANUlEQVR4nGOYtqACDTH0TMtHQwxNPWloiKGiKQ4NMeRVhKIhhpQ8XzTEEJXigoYYAqJs0BAAddU9z6CqP88AAAAASUVORK5CYII=',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAAN0lEQVR4nGO4tG8VGmI4sWk+GmLYt3wKGmLYMrsTDTGsmlCPhhgWtJSgIYZplZloiKEnLx4NAQDQhVWlMSVSOQAAAABJRU5ErkJggg==',
];

late List<String> _photoPaths;

class _Memory extends PersistenceService {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<int?> getInt(String key) async => null;

  @override
  Future<bool> setString(String key, String value) async => true;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  Future<bool> remove(String key) async => true;
}

/// Starts the batch session in a fixed state.
class _BatchPreset extends BatchExtractionNotifier {
  _BatchPreset(this.initial);

  final BatchState initial;

  @override
  BatchState build() {
    super.build();
    return initial;
  }
}

List _batch(BatchState state) => [
  persistenceServiceProvider.overrideWithValue(_Memory()),
  socialCallbackLinksProvider.overrideWithValue(const Stream<Uri>.empty()),
  batchExtractionProvider.overrideWith(() => _BatchPreset(state)),
];

List<BatchImage> _images(
  List<BatchImageStatus> statuses, {
  int piecesEach = 0,
}) => [
  for (final (i, s) in statuses.indexed)
    BatchImage(
      id: 'p$i',
      filePath: _photoPaths[i % _photoPaths.length],
      status: s,
      extractedItems: [
        for (
          var k = 0;
          k < (s == BatchImageStatus.extracted ? piecesEach : 0);
          k++
        )
          BatchExtractedItem(
            id: 'x$i$k',
            sourceImageId: 'p$i',
            name: 'x',
            category: Category.tops,
          ),
      ],
      error: s == BatchImageStatus.failed
          ? 'No pieces found in this photo.'
          : null,
    ),
];

final _pieces = [
  for (final (i, (name, c, colors, person)) in [
    ('Ecru oxford shirt', Category.tops, ['Ecru'], 'You'),
    ('Charcoal trousers', Category.bottoms, ['Charcoal'], 'You'),
    ('Tobacco loafers', Category.shoes, ['Brown'], 'Person 2'),
    ('Sage overshirt', Category.outerwear, ['Sage', 'Olive'], 'Person 2'),
  ].indexed)
    BatchExtractedItem(
      id: 't$i',
      sourceImageId: 'p${i % 3}',
      name: name,
      category: c,
      colors: colors,
      personId: person == 'You' ? 'me' : 'p2',
      personLabel: person,
      isCurrentUserPerson: person == 'You',
      status: i == 3 ? BatchItemStatus.failed : BatchItemStatus.generated,
      generatedImageUrl: i == 3 ? null : 'data:image/png;base64,${_pixels[i]}',
      isSelected: i != 2,
      includeInWardrobe: i != 2,
    ),
];

Future<void> _snap(WidgetTester tester, String file) async {
  // File images must load outside the fake clock: precache them at every
  // decode width the views use, then let the codecs finish.
  final context = tester.element(find.byType(Scaffold).first);
  await tester.runAsync(() async {
    for (final path in _photoPaths) {
      for (final width in const [168, 312, 360, 480, 1080]) {
        await precacheImage(
          ResizeImage(FileImage(File(path)), width: width),
          context,
        );
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump(const Duration(milliseconds: 100));
  // Button colours ease between states; let them land.
  await tester.pump(const Duration(milliseconds: 400));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$file.png'),
  );
}

/// Hosts one of the single-add views for [session] with a seeded state.
class _AddHost extends ConsumerWidget {
  const _AddHost({
    required this.session,
    required this.title,
    required this.child,
  });

  final int session;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PaperStockScope(
    stock: PaperStockId.moss,
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppPageBackground(child: child),
    ),
  );
}

Future<void> _seedAdd(
  WidgetTester tester,
  int session,
  ItemAddState state,
) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(_AddHost)),
  );
  container.read(itemAddProvider(session).notifier).debugSetState(state);
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    final dir = Directory.systemTemp.createTempSync('add_items_golden');
    _photoPaths = [
      for (final (i, px) in _pixels.indexed)
        (File(
          '${dir.path}/photo$i.png',
        )..writeAsBytesSync(base64Decode(px))).path,
    ];
  });

  for (final dark in [false, true]) {
    final file = 'add_start_${dark ? 'dark' : 'light'}';
    testWidgets(file, (tester) async {
      await pumpPhone(tester, const ItemAddPage(), dark: dark);
      await _snap(tester, file);
    });
  }

  testWidgets('add_manual_light', (tester) async {
    await pumpPhone(tester, const ItemAddPage());
    await tester.tap(find.text('Enter details yourself'));
    await tester.pump(const Duration(milliseconds: 300));
    await _snap(tester, 'add_manual_light');
  });

  testWidgets('add_processing_light', (tester) async {
    const session = 9001;
    await pumpPhone(
      tester,
      const _AddHost(
        session: session,
        title: 'Scanning',
        child: ExtractionProcessingView(session: session),
      ),
    );
    await _seedAdd(
      tester,
      session,
      ItemAddState(
        image: File(_photoPaths[0]),
        processing: true,
        phase: 'analyzing',
        progress: 35,
        secondsLeft: 40,
      ),
    );
    await _snap(tester, 'add_processing_light');
  });

  testWidgets('add_results_light', (tester) async {
    const session = 9002;
    await pumpPhone(
      tester,
      const _AddHost(
        session: session,
        title: 'Review pieces',
        child: ExtractionResultsView(session: session),
      ),
    );
    await _seedAdd(
      tester,
      session,
      ItemAddState(
        image: File(_photoPaths[1]),
        phase: 'review',
        items: [
          DetectedItemDataWithImage(
            tempId: 'a',
            category: 'tops',
            name: 'Ecru oxford shirt',
            colors: const ['Ecru'],
            confidence: 0.9,
            generatedImageUrl: 'data:image/png;base64,${_pixels[0]}',
          ),
          const DetectedItemDataWithImage(
            tempId: 'b',
            category: 'bottoms',
            name: 'Charcoal trousers',
            confidence: 0.9,
          ),
          const DetectedItemDataWithImage(
            tempId: 'c',
            category: 'shoes',
            name: 'Tobacco loafers',
            confidence: 0.9,
            includeInWardrobe: false,
            generationError: 'failed',
          ),
        ],
      ),
    );
    await _snap(tester, 'add_results_light');
  });

  testWidgets('add_failure_light', (tester) async {
    const session = 9003;
    await pumpPhone(
      tester,
      const _AddHost(
        session: session,
        title: 'Add a piece',
        child: ExtractionFailureView(session: session),
      ),
    );
    await _seedAdd(
      tester,
      session,
      ItemAddState(
        image: File(_photoPaths[2]),
        failure: const ItemAddFailure(
          ItemAddFailureKind.connection,
          'Connection was lost.',
        ),
      ),
    );
    await _snap(tester, 'add_failure_light');
  });

  testWidgets('batch_selector_empty_light', (tester) async {
    await pumpPhone(
      tester,
      const BatchImageSelectorPage(),
      overrides: _batch(const BatchState()),
    );
    await _snap(tester, 'batch_selector_empty_light');
  });

  testWidgets('batch_social_light', (tester) async {
    await pumpPhone(
      tester,
      const BatchImageSelectorPage(),
      overrides: _batch(const BatchState(mode: BatchInputMode.social)),
    );
    await _snap(tester, 'batch_social_light');
  });

  for (final dark in [false, true]) {
    final file = 'batch_selector_photos_${dark ? 'dark' : 'light'}';
    testWidgets(file, (tester) async {
      await pumpPhone(
        tester,
        const BatchImageSelectorPage(),
        dark: dark,
        overrides: _batch(
          BatchState(images: _images(List.filled(5, BatchImageStatus.pending))),
        ),
      );
      await _snap(tester, file);
    });
  }

  testWidgets('batch_progress_light', (tester) async {
    await pumpPhone(
      tester,
      const BatchExtractionProgressPage(),
      overrides: _batch(
        BatchState(
          status: BatchJobStatus.extracting,
          jobId: 'job-1',
          extractedCount: 2,
          failedCount: 1,
          items: _pieces.take(3).toList(),
          images: _images([
            BatchImageStatus.extracted,
            BatchImageStatus.failed,
            BatchImageStatus.extracted,
            BatchImageStatus.extracting,
            BatchImageStatus.pending,
          ], piecesEach: 2),
        ),
      ),
    );
    await _snap(tester, 'batch_progress_light');
  });

  testWidgets('batch_progress_failed_light', (tester) async {
    await pumpPhone(
      tester,
      const BatchExtractionProgressPage(),
      overrides: _batch(
        BatchState(
          status: BatchJobStatus.failed,
          error: 'We lost the connection while working. Try again.',
          images: _images([BatchImageStatus.failed, BatchImageStatus.failed]),
        ),
      ),
    );
    await _snap(tester, 'batch_progress_failed_light');
  });

  for (final dark in [false, true]) {
    final file = 'batch_review_${dark ? 'dark' : 'light'}';
    testWidgets(file, (tester) async {
      await pumpPhone(
        tester,
        const BatchItemReviewPage(),
        dark: dark,
        overrides: _batch(
          BatchState(
            status: BatchJobStatus.complete,
            items: _pieces,
            images: _images(List.filled(3, BatchImageStatus.generated)),
          ),
        ),
      );
      await _snap(tester, file);
    });
  }

  testWidgets('batch_review_empty_light', (tester) async {
    await pumpPhone(
      tester,
      const BatchItemReviewPage(),
      overrides: _batch(
        BatchState(
          status: BatchJobStatus.complete,
          images: _images(List.filled(3, BatchImageStatus.generated)),
        ),
      ),
    );
    await _snap(tester, 'batch_review_empty_light');
  });
}
