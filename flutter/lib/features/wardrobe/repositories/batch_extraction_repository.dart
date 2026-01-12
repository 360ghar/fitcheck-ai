import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/sse_service.dart';
import '../models/batch_extraction_models.dart';

/// Repository for batch extraction operations
class BatchExtractionRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SSEService _sseService = SSEService.instance;

  /// Start a batch extraction job
  ///
  /// [images] - List of images with their base64 data
  /// [autoGenerate] - Whether to automatically generate product images
  /// [generationBatchSize] - Number of items to generate in parallel (max 5)
  Future<BatchExtractionResponse> startBatchExtraction({
    required List<BatchImageInput> images,
    bool autoGenerate = true,
    int generationBatchSize = 5,
  }) async {
    try {
      final payload = {
        'images': images.map((img) => img.toJson()).toList(),
        'auto_generate': autoGenerate,
        'generation_batch_size': generationBatchSize.clamp(1, 5),
      };

      final response = await _apiClient.post(
        ApiConstants.aiBatchExtract,
        data: payload,
      );

      return BatchExtractionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Subscribe to SSE events for a batch extraction job
  ///
  /// Returns a stream of SSE events for real-time progress updates
  Stream<SSEEvent> subscribeToEvents(String jobId) {
    final path = ApiConstants.aiBatchExtractEvents(jobId);
    return _sseService.connect(path).map(
      (event) => SSEEvent(type: event.type, data: event.data),
    );
  }

  /// Cancel a batch extraction job
  Future<void> cancelJob(String jobId) async {
    try {
      await _apiClient.post(
        ApiConstants.aiBatchExtractCancel(jobId),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get the current status of a batch extraction job
  ///
  /// Can be used as a fallback if SSE connection fails
  Future<BatchJobStatusResponse> getJobStatus(String jobId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.aiBatchExtractStatus(jobId),
      );
      return BatchJobStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Parse SSE event data into extracted items
  ///
  /// Helper method to parse the extracted items from SSE events
  List<BatchExtractedItem> parseExtractedItems(
    Map<String, dynamic> eventData,
    String sourceImageId,
  ) {
    final items = <BatchExtractedItem>[];

    if (eventData['items'] != null) {
      final itemsList = eventData['items'] as List;
      for (final itemData in itemsList) {
        try {
          final item = BatchExtractedItem.fromJson({
            ...itemData as Map<String, dynamic>,
            'id': itemData['id'] ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
            'sourceImageId': sourceImageId,
          });
          items.add(item);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse extracted item: $e');
          }
        }
      }
    }

    return items;
  }
}
