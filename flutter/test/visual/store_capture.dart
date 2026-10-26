import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// App Store screenshot capture mode.
///
/// Normally the golden suite is a regression harness: it renders each screen in
/// English and compares against `test/visual/goldens/`. Store creative needs
/// something different from the same fixtures - the *same* demo data rendered in
/// a *specific* locale, written somewhere the Node renderer can pick it up.
///
/// Setting `--dart-define=STORE_CAPTURE_LOCALE=<asc>` turns those two behaviours
/// on without changing anything for a normal `flutter test` run:
///
///   * `pumpPhone` renders in the requested locale instead of English.
///   * every `matchesGoldenFile` target is redirected to
///     `build/store_capture/<asc>/<name>.png` instead of overwriting the
///     committed English goldens.
///
/// The default is the empty string, which leaves the regression suite untouched.
const String storeCaptureLocale = String.fromEnvironment('STORE_CAPTURE_LOCALE');

/// True when this test run is producing store creative rather than checking
/// regressions.
bool get isStoreCapture => storeCaptureLocale.isNotEmpty;

/// Where redirected goldens land. Relative to the `flutter/` package root.
Directory storeCaptureRoot() => Directory('build/store_capture');

/// Installs the redirecting comparator. Idempotent; call from `pumpPhone` so an
/// untouched golden test file needs no knowledge of capture mode.
void installStoreCaptureComparator() {
  if (!isStoreCapture) return;
  final current = goldenFileComparator;
  if (current is _StoreCaptureComparator) return;
  goldenFileComparator = _StoreCaptureComparator(storeCaptureRoot());
}

/// Writes `<root>/<locale>/<basename>` and always passes.
///
/// `update` is what the framework calls under `--update-goldens`, and `compare`
/// is what it calls otherwise; both write, so a capture run needs no flag.
class _StoreCaptureComparator extends GoldenFileComparator {
  _StoreCaptureComparator(this.root);

  final Directory root;

  @override
  Uri getTestUri(Uri key, int? version) => key;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    await _write(imageBytes, golden);
    return true;
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) => _write(imageBytes, golden);

  Future<void> _write(Uint8List imageBytes, Uri golden) async {
    final name = golden.pathSegments.last;
    final file = File('${root.path}/$storeCaptureLocale/$name');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(imageBytes);
  }
}

/// The single face a non-Latin capture must render with, or null when the
/// locale's script is already covered by the app's own Latin faces.
///
/// The Flutter test shell has no system font fallback, and it does **not**
/// fall back between faces registered under one family - the family's first
/// face wins, so adding a CJK face next to Roboto renders nothing but boxes
/// (verified). A non-Latin capture therefore has to register one face that
/// covers both the script *and* the Latin demo strings around it.
///
/// `Arial Unicode.ttf` is that face: a single 23 MB TTF covering CJK, Arabic,
/// Hebrew, Thai and the Indic scripts. The `.ttc` collections beside it are
/// deliberately unused - `FontLoader` accepts them and silently registers no
/// face.
///
/// English and the Latin/Greek/Cyrillic locales get `null`, so their captures
/// keep Basteleur headlines and Roboto body exactly as the regression suite
/// renders them.
String? scriptFallbackFontFor(String asc) {
  final lang = asc.split(RegExp('[-_]')).first.toLowerCase();
  const needsFallback = {
    'ar', 'ur', 'he', 'hi', 'mr', 'bn', 'gu', 'ta',
    'te', 'kn', 'ml', 'or', 'pa', 'th', 'ja', 'ko', 'zh',
  };
  if (!needsFallback.contains(lang)) return null;
  const universal = '/System/Library/Fonts/Supplemental/Arial Unicode.ttf';
  final file = File(universal);
  return file.existsSync() ? universal : null;
}

/// The `Locale` a capture should render in, or [fallback] outside capture mode.
///
/// Resolved through the app's own registry so `zh-Hant`, `pt-BR` and `en-GB`
/// pick up their script and region subtags exactly as the shipping app would.
T captureLocaleOr<T>(T fallback, T Function(String asc) resolve) =>
    isStoreCapture ? resolve(storeCaptureLocale) : fallback;
