import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Image utilities for compression, encoding, and thumbnail generation
class ImageUtils {
  ImageUtils._();

  /// Default max dimension for compression
  static const int defaultMaxDimension = 1024;

  /// Default quality for compression
  static const int defaultQuality = 80;

  /// Thumbnail size for preview
  static const int thumbnailSize = 200;

  /// Max file size in bytes (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Compress an image file
  ///
  /// [file] - The image file to compress
  /// [maxDimension] - Max width/height in pixels
  /// [quality] - JPEG quality (1-100)
  static Future<Uint8List?> compressImage(
    File file, {
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        keepExif: false,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Image compression error: $e');
      }
      return null;
    }
  }

  /// Compress and encode an image to base64
  ///
  /// [file] - The image file to process
  /// [maxDimension] - Max width/height in pixels
  /// [quality] - JPEG quality (1-100)
  static Future<String?> compressAndEncode(
    File file, {
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
  }) async {
    final compressed = await compressImage(
      file,
      maxDimension: maxDimension,
      quality: quality,
    );

    if (compressed == null) {
      // Fallback to raw file if compression fails
      try {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to read image file: $e');
        }
        return null;
      }
    }

    return base64Encode(compressed);
  }

  /// Generate a thumbnail for preview
  ///
  /// [file] - The image file
  /// [size] - Thumbnail size in pixels
  static Future<File?> generateThumbnail(
    File file, {
    int size = thumbnailSize,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath =
          '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        thumbnailPath,
        minWidth: size,
        minHeight: size,
        quality: 70,
        keepExif: false,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Thumbnail generation error: $e');
      }
      return null;
    }
  }

  /// Process multiple images in batches to manage memory
  ///
  /// [files] - List of image files
  /// [batchSize] - Number of images to process at once
  /// [onProgress] - Callback for progress updates
  static Future<List<String?>> batchCompressAndEncode(
    List<File> files, {
    int batchSize = 5,
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <String?>[];

    for (var i = 0; i < files.length; i += batchSize) {
      final batchEnd = (i + batchSize).clamp(0, files.length);
      final batch = files.sublist(i, batchEnd);

      // Process batch in parallel
      final batchResults = await Future.wait(
        batch.map((file) => compressAndEncode(
              file,
              maxDimension: maxDimension,
              quality: quality,
            )),
      );

      results.addAll(batchResults);

      // Report progress
      onProgress?.call(results.length, files.length);

      // Small delay to allow GC to clean up
      if (batchEnd < files.length) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    return results;
  }

  /// Validate an image file
  ///
  /// Returns null if valid, error message if invalid
  static Future<String?> validateImage(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      return 'File does not exist';
    }

    // Check file size
    final size = await file.length();
    if (size > maxFileSize) {
      return 'File too large (max ${maxFileSize ~/ (1024 * 1024)}MB)';
    }

    // Check extension
    final extension = file.path.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(extension)) {
      return 'Unsupported image format';
    }

    return null;
  }

  /// Generate a unique ID for a batch image
  static String generateImageId() {
    return 'img_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  static String _randomSuffix() {
    final random = DateTime.now().microsecond;
    return random.toString().padLeft(6, '0');
  }
}
