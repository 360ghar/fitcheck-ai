@Tags(['golden'])
library;

import 'dart:io';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/widgets/paper.dart';
import 'package:fitcheck_ai/features/photoshoot/models/photoshoot_models.dart';
import 'package:fitcheck_ai/features/photoshoot/providers/photoshoot_provider.dart';
import 'package:fitcheck_ai/features/photoshoot/repositories/photoshoot_repository.dart';
import 'package:fitcheck_ai/features/photoshoot/views/photoshoot_content.dart';
import 'package:fitcheck_ai/features/tryon/providers/tryon_provider.dart';
import 'package:fitcheck_ai/features/tryon/repositories/tryon_repository.dart';
import 'package:fitcheck_ai/features/tryon/views/tryon_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

/// Small tonal PNGs standing in for generated portraits.
const _pixels = [
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANklEQVR4nGM4sqAJDTHsnFaJhhjW9RSgIYbFTRloiGFGRTwaYujNC0dDDE0pfmiIoSLKDQ0BAHstR61P2he0AAAAAElFTkSuQmCC',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANUlEQVR4nGOoaJ+Ghhjya3vQEENaSTMaYojLrkJDDKGJBWiIwTciHQ0xuPjHoSEGG7dQNAQAKQI567jy3/8AAAAASUVORK5CYII=',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAANUlEQVR4nGOYtqACDTH0TMtHQwxNPWloiKGiKQ4NMeRVhKIhhpQ8XzTEEJXigoYYAqJs0BAAddU9z6CqP88AAAAASUVORK5CYII=',
  'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAIAAABVpBlvAAAAN0lEQVR4nGO4tG8VGmI4sWk+GmLYt3wKGmLYMrsTDTGsmlCPhhgWtJSgIYZplZloiKEnLx4NAQDQhVWlMSVSOQAAAABJRU5ErkJggg==',
];

GeneratedImage _image(int i) =>
    GeneratedImage(id: 'g$i', index: i, imageBase64: _pixels[i % 4]);

class _Repo extends PhotoshootRepository {
  @override
  Future<PhotoshootUsage> getUsage() async =>
      const PhotoshootUsage(remaining: 8, limitToday: 10);
}

/// Starts the tab in a fixed state.
class _Preset extends PhotoshootNotifier {
  _Preset(this.initial);

  final PhotoshootState initial;

  @override
  PhotoshootState build() => initial;
}

class _TryOnRepo extends TryOnRepository {
  @override
  Future<String?> fetchAvatarUrl() async => null;
}

const _usage = PhotoshootUsage(remaining: 8, limitToday: 10);

final _presets = <String, PhotoshootState>{
  'photoshoot_generating': PhotoshootState(
    step: PhotoshootStep.generating,
    jobId: 'job-1',
    numImages: 6,
    usage: _usage,
    progress: 55,
    status: '3 of 6 done',
    etaSeconds: 48,
    sceneLabel: 'Sunlit cafe, seated upper body',
    images: [_image(0), _image(1), _image(2)],
  ),
  'photoshoot_results': PhotoshootState(
    step: PhotoshootStep.results,
    numImages: 4,
    usage: _usage,
    images: [_image(0), _image(1), _image(3)],
    failedIndices: const [2],
    failedCount: 1,
    partialSuccess: true,
  ),
  'photoshoot_configure': PhotoshootState(
    step: PhotoshootStep.configure,
    photos: [File('photo.jpg')],
    usage: _usage,
    numImages: 6,
    useCase: PhotoshootUseCase.custom,
    customPrompt: 'Golden hour on a rooftop',
  ),
  'photoshoot_error': PhotoshootState(
    step: PhotoshootStep.configure,
    photos: [File('photo.jpg')],
    usage: _usage,
    numImages: 8,
    useCase: PhotoshootUseCase.datingApp,
    error: const ServerException(
      message: 'The studio is busy. Please try again.',
      statusCode: 503,
    ),
  ),
};

Future<void> _snap(
  WidgetTester tester,
  String file, {
  bool scrollToEnd = false,
}) async {
  // Let image codecs finish, then paint.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump(const Duration(milliseconds: 100));
  if (scrollToEnd) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pump(const Duration(milliseconds: 500));
  }
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$file.png'),
  );
}

const _tab = PaperStockScope(
  stock: PaperStockId.clay,
  child: Scaffold(body: PhotoshootContent()),
);

void main() {
  setUpAll(loadAppFonts);

  for (final dark in [false, true]) {
    final file = 'photoshoot_upload_${dark ? 'dark' : 'light'}';
    testWidgets(file, (tester) async {
      await pumpPhone(
        tester,
        _tab,
        dark: dark,
        overrides: [photoshootRepositoryProvider.overrideWithValue(_Repo())],
      );
      await _snap(tester, file);
    });
  }

  for (final MapEntry(key: name, value: preset) in _presets.entries) {
    for (final dark in name == 'photoshoot_results' ? [false, true] : [false]) {
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          _tab,
          dark: dark,
          overrides: [
            photoshootRepositoryProvider.overrideWithValue(_Repo()),
            photoshootProvider.overrideWith(() => _Preset(preset)),
          ],
        );
        await _snap(tester, file, scrollToEnd: name == 'photoshoot_configure');
      });
    }
  }

  for (final dark in [false, true]) {
    final file = 'tryon_${dark ? 'dark' : 'light'}';
    testWidgets(file, (tester) async {
      await pumpPhone(
        tester,
        const TryOnPage(),
        dark: dark,
        overrides: [tryOnRepositoryProvider.overrideWithValue(_TryOnRepo())],
      );
      await _snap(tester, file);
    });
  }
}
