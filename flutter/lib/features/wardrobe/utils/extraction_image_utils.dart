import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Helpers for cropping extracted items from a source image.
class ExtractionImageUtils {
  ExtractionImageUtils._();

  static const double defaultPaddingFraction = 0.06;
  static const int defaultPreviewMaxSide = 240;

  static img.Image? decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  static img.Image? cropImage(
    img.Image source,
    Map<String, dynamic>? boundingBox, {
    double paddingFraction = defaultPaddingFraction,
  }) {
    if (boundingBox == null || boundingBox.isEmpty) {
      return null;
    }

    final boxX = _clampPercent(
      _normalizePercent(_coerceDouble(boundingBox['x'], 0)),
    );
    final boxY = _clampPercent(
      _normalizePercent(_coerceDouble(boundingBox['y'], 0)),
    );
    final boxWidth = _clampPercent(
      _normalizePercent(_coerceDouble(boundingBox['width'], 100)),
    );
    final boxHeight = _clampPercent(
      _normalizePercent(_coerceDouble(boundingBox['height'], 100)),
    );

    if (boxWidth <= 0 || boxHeight <= 0) {
      return null;
    }

    final imageWidth = source.width.toDouble();
    final imageHeight = source.height.toDouble();

    final x = boxX / 100 * imageWidth;
    final y = boxY / 100 * imageHeight;
    final width = boxWidth / 100 * imageWidth;
    final height = boxHeight / 100 * imageHeight;

    final padX = width * paddingFraction;
    final padY = height * paddingFraction;

    final left = (x - padX).clamp(0.0, imageWidth - 1);
    final top = (y - padY).clamp(0.0, imageHeight - 1);
    final right = (x + width + padX).clamp(left + 1, imageWidth);
    final bottom = (y + height + padY).clamp(top + 1, imageHeight);

    final cropX = left.round();
    final cropY = top.round();
    final cropWidth = (right - left).round().clamp(1, source.width - cropX);
    final cropHeight =
        (bottom - top).round().clamp(1, source.height - cropY);

    return img.copyCrop(
      source,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );
  }

  static img.Image resizeIfNeeded(img.Image image, int maxSide) {
    final maxDimension =
        image.width > image.height ? image.width : image.height;
    if (maxDimension <= maxSide) {
      return image;
    }
    final scale = maxSide / maxDimension;
    final width = (image.width * scale).round().clamp(1, maxSide);
    final height = (image.height * scale).round().clamp(1, maxSide);
    return img.copyResize(image, width: width, height: height);
  }

  static Uint8List encodeJpg(img.Image image, {int quality = 85}) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  static Future<File?> cropToTempFile(
    File originalImage,
    Map<String, dynamic>? boundingBox, {
    double paddingFraction = defaultPaddingFraction,
    int quality = 90,
    String? filenameSuffix,
  }) async {
    if (boundingBox == null || boundingBox.isEmpty) {
      return null;
    }

    final bytes = await originalImage.readAsBytes();
    final decoded = decodeImage(bytes);
    if (decoded == null) {
      return null;
    }

    final cropped = cropImage(
      decoded,
      boundingBox,
      paddingFraction: paddingFraction,
    );
    if (cropped == null) {
      return null;
    }

    final tempDir = await getTemporaryDirectory();
    final suffix = filenameSuffix ?? DateTime.now().millisecondsSinceEpoch.toString();
    final tempFile = File('${tempDir.path}/item_crop_$suffix.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(cropped, quality: quality));
    return tempFile;
  }

  static double _coerceDouble(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double _normalizePercent(double value) {
    if (value > 0 && value <= 1) {
      return value * 100;
    }
    return value;
  }

  static double _clampPercent(double value) {
    return value.clamp(0.0, 100.0);
  }
}
