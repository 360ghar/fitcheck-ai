// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_extraction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BatchImage _$BatchImageFromJson(Map<String, dynamic> json) {
  return _BatchImage.fromJson(json);
}

/// @nodoc
mixin _$BatchImage {
  String get id => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String? get base64Data => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  BatchImageStatus get status => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<BatchExtractedItem> get extractedItems =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchImageCopyWith<BatchImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchImageCopyWith<$Res> {
  factory $BatchImageCopyWith(
          BatchImage value, $Res Function(BatchImage) then) =
      _$BatchImageCopyWithImpl<$Res, BatchImage>;
  @useResult
  $Res call(
      {String id,
      String filePath,
      String? base64Data,
      String? thumbnailPath,
      BatchImageStatus status,
      String? error,
      List<BatchExtractedItem> extractedItems});
}

/// @nodoc
class _$BatchImageCopyWithImpl<$Res, $Val extends BatchImage>
    implements $BatchImageCopyWith<$Res> {
  _$BatchImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? base64Data = freezed,
    Object? thumbnailPath = freezed,
    Object? status = null,
    Object? error = freezed,
    Object? extractedItems = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      base64Data: freezed == base64Data
          ? _value.base64Data
          : base64Data // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchImageStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      extractedItems: null == extractedItems
          ? _value.extractedItems
          : extractedItems // ignore: cast_nullable_to_non_nullable
              as List<BatchExtractedItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchImageImplCopyWith<$Res>
    implements $BatchImageCopyWith<$Res> {
  factory _$$BatchImageImplCopyWith(
          _$BatchImageImpl value, $Res Function(_$BatchImageImpl) then) =
      __$$BatchImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String filePath,
      String? base64Data,
      String? thumbnailPath,
      BatchImageStatus status,
      String? error,
      List<BatchExtractedItem> extractedItems});
}

/// @nodoc
class __$$BatchImageImplCopyWithImpl<$Res>
    extends _$BatchImageCopyWithImpl<$Res, _$BatchImageImpl>
    implements _$$BatchImageImplCopyWith<$Res> {
  __$$BatchImageImplCopyWithImpl(
      _$BatchImageImpl _value, $Res Function(_$BatchImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? base64Data = freezed,
    Object? thumbnailPath = freezed,
    Object? status = null,
    Object? error = freezed,
    Object? extractedItems = null,
  }) {
    return _then(_$BatchImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      base64Data: freezed == base64Data
          ? _value.base64Data
          : base64Data // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchImageStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      extractedItems: null == extractedItems
          ? _value._extractedItems
          : extractedItems // ignore: cast_nullable_to_non_nullable
              as List<BatchExtractedItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchImageImpl implements _BatchImage {
  const _$BatchImageImpl(
      {required this.id,
      required this.filePath,
      this.base64Data,
      this.thumbnailPath,
      this.status = BatchImageStatus.pending,
      this.error,
      final List<BatchExtractedItem> extractedItems = const []})
      : _extractedItems = extractedItems;

  factory _$BatchImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchImageImplFromJson(json);

  @override
  final String id;
  @override
  final String filePath;
  @override
  final String? base64Data;
  @override
  final String? thumbnailPath;
  @override
  @JsonKey()
  final BatchImageStatus status;
  @override
  final String? error;
  final List<BatchExtractedItem> _extractedItems;
  @override
  @JsonKey()
  List<BatchExtractedItem> get extractedItems {
    if (_extractedItems is EqualUnmodifiableListView) return _extractedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_extractedItems);
  }

  @override
  String toString() {
    return 'BatchImage(id: $id, filePath: $filePath, base64Data: $base64Data, thumbnailPath: $thumbnailPath, status: $status, error: $error, extractedItems: $extractedItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.base64Data, base64Data) ||
                other.base64Data == base64Data) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._extractedItems, _extractedItems));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      filePath,
      base64Data,
      thumbnailPath,
      status,
      error,
      const DeepCollectionEquality().hash(_extractedItems));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImageImplCopyWith<_$BatchImageImpl> get copyWith =>
      __$$BatchImageImplCopyWithImpl<_$BatchImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchImageImplToJson(
      this,
    );
  }
}

abstract class _BatchImage implements BatchImage {
  const factory _BatchImage(
      {required final String id,
      required final String filePath,
      final String? base64Data,
      final String? thumbnailPath,
      final BatchImageStatus status,
      final String? error,
      final List<BatchExtractedItem> extractedItems}) = _$BatchImageImpl;

  factory _BatchImage.fromJson(Map<String, dynamic> json) =
      _$BatchImageImpl.fromJson;

  @override
  String get id;
  @override
  String get filePath;
  @override
  String? get base64Data;
  @override
  String? get thumbnailPath;
  @override
  BatchImageStatus get status;
  @override
  String? get error;
  @override
  List<BatchExtractedItem> get extractedItems;
  @override
  @JsonKey(ignore: true)
  _$$BatchImageImplCopyWith<_$BatchImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchExtractionJob _$BatchExtractionJobFromJson(Map<String, dynamic> json) {
  return _BatchExtractionJob.fromJson(json);
}

/// @nodoc
mixin _$BatchExtractionJob {
  String get jobId => throw _privateConstructorUsedError;
  BatchJobStatus get status => throw _privateConstructorUsedError;
  int get totalImages => throw _privateConstructorUsedError;
  int get extractedCount => throw _privateConstructorUsedError;
  int get generatedCount => throw _privateConstructorUsedError;
  int get failedCount => throw _privateConstructorUsedError;
  int get currentBatch => throw _privateConstructorUsedError;
  int get totalBatches => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchExtractionJobCopyWith<BatchExtractionJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchExtractionJobCopyWith<$Res> {
  factory $BatchExtractionJobCopyWith(
          BatchExtractionJob value, $Res Function(BatchExtractionJob) then) =
      _$BatchExtractionJobCopyWithImpl<$Res, BatchExtractionJob>;
  @useResult
  $Res call(
      {String jobId,
      BatchJobStatus status,
      int totalImages,
      int extractedCount,
      int generatedCount,
      int failedCount,
      int currentBatch,
      int totalBatches,
      String? error,
      DateTime? startedAt,
      DateTime? completedAt});
}

/// @nodoc
class _$BatchExtractionJobCopyWithImpl<$Res, $Val extends BatchExtractionJob>
    implements $BatchExtractionJobCopyWith<$Res> {
  _$BatchExtractionJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? extractedCount = null,
    Object? generatedCount = null,
    Object? failedCount = null,
    Object? currentBatch = null,
    Object? totalBatches = null,
    Object? error = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchJobStatus,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      extractedCount: null == extractedCount
          ? _value.extractedCount
          : extractedCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedCount: null == generatedCount
          ? _value.generatedCount
          : generatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentBatch: null == currentBatch
          ? _value.currentBatch
          : currentBatch // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatches: null == totalBatches
          ? _value.totalBatches
          : totalBatches // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchExtractionJobImplCopyWith<$Res>
    implements $BatchExtractionJobCopyWith<$Res> {
  factory _$$BatchExtractionJobImplCopyWith(_$BatchExtractionJobImpl value,
          $Res Function(_$BatchExtractionJobImpl) then) =
      __$$BatchExtractionJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String jobId,
      BatchJobStatus status,
      int totalImages,
      int extractedCount,
      int generatedCount,
      int failedCount,
      int currentBatch,
      int totalBatches,
      String? error,
      DateTime? startedAt,
      DateTime? completedAt});
}

/// @nodoc
class __$$BatchExtractionJobImplCopyWithImpl<$Res>
    extends _$BatchExtractionJobCopyWithImpl<$Res, _$BatchExtractionJobImpl>
    implements _$$BatchExtractionJobImplCopyWith<$Res> {
  __$$BatchExtractionJobImplCopyWithImpl(_$BatchExtractionJobImpl _value,
      $Res Function(_$BatchExtractionJobImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? extractedCount = null,
    Object? generatedCount = null,
    Object? failedCount = null,
    Object? currentBatch = null,
    Object? totalBatches = null,
    Object? error = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$BatchExtractionJobImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchJobStatus,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      extractedCount: null == extractedCount
          ? _value.extractedCount
          : extractedCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedCount: null == generatedCount
          ? _value.generatedCount
          : generatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentBatch: null == currentBatch
          ? _value.currentBatch
          : currentBatch // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatches: null == totalBatches
          ? _value.totalBatches
          : totalBatches // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchExtractionJobImpl implements _BatchExtractionJob {
  const _$BatchExtractionJobImpl(
      {required this.jobId,
      required this.status,
      required this.totalImages,
      this.extractedCount = 0,
      this.generatedCount = 0,
      this.failedCount = 0,
      this.currentBatch = 0,
      this.totalBatches = 0,
      this.error,
      this.startedAt,
      this.completedAt});

  factory _$BatchExtractionJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchExtractionJobImplFromJson(json);

  @override
  final String jobId;
  @override
  final BatchJobStatus status;
  @override
  final int totalImages;
  @override
  @JsonKey()
  final int extractedCount;
  @override
  @JsonKey()
  final int generatedCount;
  @override
  @JsonKey()
  final int failedCount;
  @override
  @JsonKey()
  final int currentBatch;
  @override
  @JsonKey()
  final int totalBatches;
  @override
  final String? error;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'BatchExtractionJob(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, error: $error, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchExtractionJobImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalImages, totalImages) ||
                other.totalImages == totalImages) &&
            (identical(other.extractedCount, extractedCount) ||
                other.extractedCount == extractedCount) &&
            (identical(other.generatedCount, generatedCount) ||
                other.generatedCount == generatedCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount) &&
            (identical(other.currentBatch, currentBatch) ||
                other.currentBatch == currentBatch) &&
            (identical(other.totalBatches, totalBatches) ||
                other.totalBatches == totalBatches) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      status,
      totalImages,
      extractedCount,
      generatedCount,
      failedCount,
      currentBatch,
      totalBatches,
      error,
      startedAt,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchExtractionJobImplCopyWith<_$BatchExtractionJobImpl> get copyWith =>
      __$$BatchExtractionJobImplCopyWithImpl<_$BatchExtractionJobImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchExtractionJobImplToJson(
      this,
    );
  }
}

abstract class _BatchExtractionJob implements BatchExtractionJob {
  const factory _BatchExtractionJob(
      {required final String jobId,
      required final BatchJobStatus status,
      required final int totalImages,
      final int extractedCount,
      final int generatedCount,
      final int failedCount,
      final int currentBatch,
      final int totalBatches,
      final String? error,
      final DateTime? startedAt,
      final DateTime? completedAt}) = _$BatchExtractionJobImpl;

  factory _BatchExtractionJob.fromJson(Map<String, dynamic> json) =
      _$BatchExtractionJobImpl.fromJson;

  @override
  String get jobId;
  @override
  BatchJobStatus get status;
  @override
  int get totalImages;
  @override
  int get extractedCount;
  @override
  int get generatedCount;
  @override
  int get failedCount;
  @override
  int get currentBatch;
  @override
  int get totalBatches;
  @override
  String? get error;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$BatchExtractionJobImplCopyWith<_$BatchExtractionJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchExtractedItem _$BatchExtractedItemFromJson(Map<String, dynamic> json) {
  return _BatchExtractedItem.fromJson(json);
}

/// @nodoc
mixin _$BatchExtractedItem {
  String get id => throw _privateConstructorUsedError;
  String get sourceImageId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Category get category => throw _privateConstructorUsedError;
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox => throw _privateConstructorUsedError;
  @JsonKey(name: 'cropped_image_base64')
  String? get croppedImageBase64 => throw _privateConstructorUsedError;
  @JsonKey(name: 'generated_image_url')
  String? get generatedImageUrl => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  BatchItemStatus get status => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchExtractedItemCopyWith<BatchExtractedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchExtractedItemCopyWith<$Res> {
  factory $BatchExtractedItemCopyWith(
          BatchExtractedItem value, $Res Function(BatchExtractedItem) then) =
      _$BatchExtractedItemCopyWithImpl<$Res, BatchExtractedItem>;
  @useResult
  $Res call(
      {String id,
      String sourceImageId,
      String name,
      Category category,
      List<String>? colors,
      String? material,
      String? pattern,
      String? description,
      @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,
      @JsonKey(name: 'cropped_image_base64') String? croppedImageBase64,
      @JsonKey(name: 'generated_image_url') String? generatedImageUrl,
      double? confidence,
      BatchItemStatus status,
      bool isSelected,
      String? error});
}

/// @nodoc
class _$BatchExtractedItemCopyWithImpl<$Res, $Val extends BatchExtractedItem>
    implements $BatchExtractedItemCopyWith<$Res> {
  _$BatchExtractedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceImageId = null,
    Object? name = null,
    Object? category = null,
    Object? colors = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? description = freezed,
    Object? boundingBox = freezed,
    Object? croppedImageBase64 = freezed,
    Object? generatedImageUrl = freezed,
    Object? confidence = freezed,
    Object? status = null,
    Object? isSelected = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceImageId: null == sourceImageId
          ? _value.sourceImageId
          : sourceImageId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      croppedImageBase64: freezed == croppedImageBase64
          ? _value.croppedImageBase64
          : croppedImageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      generatedImageUrl: freezed == generatedImageUrl
          ? _value.generatedImageUrl
          : generatedImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchItemStatus,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchExtractedItemImplCopyWith<$Res>
    implements $BatchExtractedItemCopyWith<$Res> {
  factory _$$BatchExtractedItemImplCopyWith(_$BatchExtractedItemImpl value,
          $Res Function(_$BatchExtractedItemImpl) then) =
      __$$BatchExtractedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sourceImageId,
      String name,
      Category category,
      List<String>? colors,
      String? material,
      String? pattern,
      String? description,
      @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,
      @JsonKey(name: 'cropped_image_base64') String? croppedImageBase64,
      @JsonKey(name: 'generated_image_url') String? generatedImageUrl,
      double? confidence,
      BatchItemStatus status,
      bool isSelected,
      String? error});
}

/// @nodoc
class __$$BatchExtractedItemImplCopyWithImpl<$Res>
    extends _$BatchExtractedItemCopyWithImpl<$Res, _$BatchExtractedItemImpl>
    implements _$$BatchExtractedItemImplCopyWith<$Res> {
  __$$BatchExtractedItemImplCopyWithImpl(_$BatchExtractedItemImpl _value,
      $Res Function(_$BatchExtractedItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceImageId = null,
    Object? name = null,
    Object? category = null,
    Object? colors = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? description = freezed,
    Object? boundingBox = freezed,
    Object? croppedImageBase64 = freezed,
    Object? generatedImageUrl = freezed,
    Object? confidence = freezed,
    Object? status = null,
    Object? isSelected = null,
    Object? error = freezed,
  }) {
    return _then(_$BatchExtractedItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceImageId: null == sourceImageId
          ? _value.sourceImageId
          : sourceImageId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value._boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      croppedImageBase64: freezed == croppedImageBase64
          ? _value.croppedImageBase64
          : croppedImageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      generatedImageUrl: freezed == generatedImageUrl
          ? _value.generatedImageUrl
          : generatedImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BatchItemStatus,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchExtractedItemImpl implements _BatchExtractedItem {
  const _$BatchExtractedItemImpl(
      {required this.id,
      required this.sourceImageId,
      required this.name,
      required this.category,
      final List<String>? colors,
      this.material,
      this.pattern,
      this.description,
      @JsonKey(name: 'bounding_box') final Map<String, dynamic>? boundingBox,
      @JsonKey(name: 'cropped_image_base64') this.croppedImageBase64,
      @JsonKey(name: 'generated_image_url') this.generatedImageUrl,
      this.confidence,
      this.status = BatchItemStatus.pending,
      this.isSelected = true,
      this.error})
      : _colors = colors,
        _boundingBox = boundingBox;

  factory _$BatchExtractedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchExtractedItemImplFromJson(json);

  @override
  final String id;
  @override
  final String sourceImageId;
  @override
  final String name;
  @override
  final Category category;
  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? material;
  @override
  final String? pattern;
  @override
  final String? description;
  final Map<String, dynamic>? _boundingBox;
  @override
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox {
    final value = _boundingBox;
    if (value == null) return null;
    if (_boundingBox is EqualUnmodifiableMapView) return _boundingBox;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'cropped_image_base64')
  final String? croppedImageBase64;
  @override
  @JsonKey(name: 'generated_image_url')
  final String? generatedImageUrl;
  @override
  final double? confidence;
  @override
  @JsonKey()
  final BatchItemStatus status;
  @override
  @JsonKey()
  final bool isSelected;
  @override
  final String? error;

  @override
  String toString() {
    return 'BatchExtractedItem(id: $id, sourceImageId: $sourceImageId, name: $name, category: $category, colors: $colors, material: $material, pattern: $pattern, description: $description, boundingBox: $boundingBox, croppedImageBase64: $croppedImageBase64, generatedImageUrl: $generatedImageUrl, confidence: $confidence, status: $status, isSelected: $isSelected, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchExtractedItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceImageId, sourceImageId) ||
                other.sourceImageId == sourceImageId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._boundingBox, _boundingBox) &&
            (identical(other.croppedImageBase64, croppedImageBase64) ||
                other.croppedImageBase64 == croppedImageBase64) &&
            (identical(other.generatedImageUrl, generatedImageUrl) ||
                other.generatedImageUrl == generatedImageUrl) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sourceImageId,
      name,
      category,
      const DeepCollectionEquality().hash(_colors),
      material,
      pattern,
      description,
      const DeepCollectionEquality().hash(_boundingBox),
      croppedImageBase64,
      generatedImageUrl,
      confidence,
      status,
      isSelected,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchExtractedItemImplCopyWith<_$BatchExtractedItemImpl> get copyWith =>
      __$$BatchExtractedItemImplCopyWithImpl<_$BatchExtractedItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchExtractedItemImplToJson(
      this,
    );
  }
}

abstract class _BatchExtractedItem implements BatchExtractedItem {
  const factory _BatchExtractedItem(
      {required final String id,
      required final String sourceImageId,
      required final String name,
      required final Category category,
      final List<String>? colors,
      final String? material,
      final String? pattern,
      final String? description,
      @JsonKey(name: 'bounding_box') final Map<String, dynamic>? boundingBox,
      @JsonKey(name: 'cropped_image_base64') final String? croppedImageBase64,
      @JsonKey(name: 'generated_image_url') final String? generatedImageUrl,
      final double? confidence,
      final BatchItemStatus status,
      final bool isSelected,
      final String? error}) = _$BatchExtractedItemImpl;

  factory _BatchExtractedItem.fromJson(Map<String, dynamic> json) =
      _$BatchExtractedItemImpl.fromJson;

  @override
  String get id;
  @override
  String get sourceImageId;
  @override
  String get name;
  @override
  Category get category;
  @override
  List<String>? get colors;
  @override
  String? get material;
  @override
  String? get pattern;
  @override
  String? get description;
  @override
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox;
  @override
  @JsonKey(name: 'cropped_image_base64')
  String? get croppedImageBase64;
  @override
  @JsonKey(name: 'generated_image_url')
  String? get generatedImageUrl;
  @override
  double? get confidence;
  @override
  BatchItemStatus get status;
  @override
  bool get isSelected;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$BatchExtractedItemImplCopyWith<_$BatchExtractedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SSEEvent _$SSEEventFromJson(Map<String, dynamic> json) {
  return _SSEEvent.fromJson(json);
}

/// @nodoc
mixin _$SSEEvent {
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SSEEventCopyWith<SSEEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SSEEventCopyWith<$Res> {
  factory $SSEEventCopyWith(SSEEvent value, $Res Function(SSEEvent) then) =
      _$SSEEventCopyWithImpl<$Res, SSEEvent>;
  @useResult
  $Res call({String type, Map<String, dynamic>? data});
}

/// @nodoc
class _$SSEEventCopyWithImpl<$Res, $Val extends SSEEvent>
    implements $SSEEventCopyWith<$Res> {
  _$SSEEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SSEEventImplCopyWith<$Res>
    implements $SSEEventCopyWith<$Res> {
  factory _$$SSEEventImplCopyWith(
          _$SSEEventImpl value, $Res Function(_$SSEEventImpl) then) =
      __$$SSEEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, Map<String, dynamic>? data});
}

/// @nodoc
class __$$SSEEventImplCopyWithImpl<$Res>
    extends _$SSEEventCopyWithImpl<$Res, _$SSEEventImpl>
    implements _$$SSEEventImplCopyWith<$Res> {
  __$$SSEEventImplCopyWithImpl(
      _$SSEEventImpl _value, $Res Function(_$SSEEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_$SSEEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SSEEventImpl implements _SSEEvent {
  const _$SSEEventImpl({required this.type, final Map<String, dynamic>? data})
      : _data = data;

  factory _$SSEEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SSEEventImplFromJson(json);

  @override
  final String type;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SSEEvent(type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SSEEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SSEEventImplCopyWith<_$SSEEventImpl> get copyWith =>
      __$$SSEEventImplCopyWithImpl<_$SSEEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SSEEventImplToJson(
      this,
    );
  }
}

abstract class _SSEEvent implements SSEEvent {
  const factory _SSEEvent(
      {required final String type,
      final Map<String, dynamic>? data}) = _$SSEEventImpl;

  factory _SSEEvent.fromJson(Map<String, dynamic> json) =
      _$SSEEventImpl.fromJson;

  @override
  String get type;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$SSEEventImplCopyWith<_$SSEEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchExtractionRequest _$BatchExtractionRequestFromJson(
    Map<String, dynamic> json) {
  return _BatchExtractionRequest.fromJson(json);
}

/// @nodoc
mixin _$BatchExtractionRequest {
  List<BatchImageInput> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_generate')
  bool get autoGenerate => throw _privateConstructorUsedError;
  @JsonKey(name: 'generation_batch_size')
  int get generationBatchSize => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchExtractionRequestCopyWith<BatchExtractionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchExtractionRequestCopyWith<$Res> {
  factory $BatchExtractionRequestCopyWith(BatchExtractionRequest value,
          $Res Function(BatchExtractionRequest) then) =
      _$BatchExtractionRequestCopyWithImpl<$Res, BatchExtractionRequest>;
  @useResult
  $Res call(
      {List<BatchImageInput> images,
      @JsonKey(name: 'auto_generate') bool autoGenerate,
      @JsonKey(name: 'generation_batch_size') int generationBatchSize});
}

/// @nodoc
class _$BatchExtractionRequestCopyWithImpl<$Res,
        $Val extends BatchExtractionRequest>
    implements $BatchExtractionRequestCopyWith<$Res> {
  _$BatchExtractionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? autoGenerate = null,
    Object? generationBatchSize = null,
  }) {
    return _then(_value.copyWith(
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<BatchImageInput>,
      autoGenerate: null == autoGenerate
          ? _value.autoGenerate
          : autoGenerate // ignore: cast_nullable_to_non_nullable
              as bool,
      generationBatchSize: null == generationBatchSize
          ? _value.generationBatchSize
          : generationBatchSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchExtractionRequestImplCopyWith<$Res>
    implements $BatchExtractionRequestCopyWith<$Res> {
  factory _$$BatchExtractionRequestImplCopyWith(
          _$BatchExtractionRequestImpl value,
          $Res Function(_$BatchExtractionRequestImpl) then) =
      __$$BatchExtractionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BatchImageInput> images,
      @JsonKey(name: 'auto_generate') bool autoGenerate,
      @JsonKey(name: 'generation_batch_size') int generationBatchSize});
}

/// @nodoc
class __$$BatchExtractionRequestImplCopyWithImpl<$Res>
    extends _$BatchExtractionRequestCopyWithImpl<$Res,
        _$BatchExtractionRequestImpl>
    implements _$$BatchExtractionRequestImplCopyWith<$Res> {
  __$$BatchExtractionRequestImplCopyWithImpl(
      _$BatchExtractionRequestImpl _value,
      $Res Function(_$BatchExtractionRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? autoGenerate = null,
    Object? generationBatchSize = null,
  }) {
    return _then(_$BatchExtractionRequestImpl(
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<BatchImageInput>,
      autoGenerate: null == autoGenerate
          ? _value.autoGenerate
          : autoGenerate // ignore: cast_nullable_to_non_nullable
              as bool,
      generationBatchSize: null == generationBatchSize
          ? _value.generationBatchSize
          : generationBatchSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchExtractionRequestImpl implements _BatchExtractionRequest {
  const _$BatchExtractionRequestImpl(
      {required final List<BatchImageInput> images,
      @JsonKey(name: 'auto_generate') this.autoGenerate = true,
      @JsonKey(name: 'generation_batch_size') this.generationBatchSize = 5})
      : _images = images;

  factory _$BatchExtractionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchExtractionRequestImplFromJson(json);

  final List<BatchImageInput> _images;
  @override
  List<BatchImageInput> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey(name: 'auto_generate')
  final bool autoGenerate;
  @override
  @JsonKey(name: 'generation_batch_size')
  final int generationBatchSize;

  @override
  String toString() {
    return 'BatchExtractionRequest(images: $images, autoGenerate: $autoGenerate, generationBatchSize: $generationBatchSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchExtractionRequestImpl &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.autoGenerate, autoGenerate) ||
                other.autoGenerate == autoGenerate) &&
            (identical(other.generationBatchSize, generationBatchSize) ||
                other.generationBatchSize == generationBatchSize));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_images),
      autoGenerate,
      generationBatchSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchExtractionRequestImplCopyWith<_$BatchExtractionRequestImpl>
      get copyWith => __$$BatchExtractionRequestImplCopyWithImpl<
          _$BatchExtractionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchExtractionRequestImplToJson(
      this,
    );
  }
}

abstract class _BatchExtractionRequest implements BatchExtractionRequest {
  const factory _BatchExtractionRequest(
      {required final List<BatchImageInput> images,
      @JsonKey(name: 'auto_generate') final bool autoGenerate,
      @JsonKey(name: 'generation_batch_size')
      final int generationBatchSize}) = _$BatchExtractionRequestImpl;

  factory _BatchExtractionRequest.fromJson(Map<String, dynamic> json) =
      _$BatchExtractionRequestImpl.fromJson;

  @override
  List<BatchImageInput> get images;
  @override
  @JsonKey(name: 'auto_generate')
  bool get autoGenerate;
  @override
  @JsonKey(name: 'generation_batch_size')
  int get generationBatchSize;
  @override
  @JsonKey(ignore: true)
  _$$BatchExtractionRequestImplCopyWith<_$BatchExtractionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BatchImageInput _$BatchImageInputFromJson(Map<String, dynamic> json) {
  return _BatchImageInput.fromJson(json);
}

/// @nodoc
mixin _$BatchImageInput {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_base64')
  String get imageBase64 => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchImageInputCopyWith<BatchImageInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchImageInputCopyWith<$Res> {
  factory $BatchImageInputCopyWith(
          BatchImageInput value, $Res Function(BatchImageInput) then) =
      _$BatchImageInputCopyWithImpl<$Res, BatchImageInput>;
  @useResult
  $Res call({String id, @JsonKey(name: 'image_base64') String imageBase64});
}

/// @nodoc
class _$BatchImageInputCopyWithImpl<$Res, $Val extends BatchImageInput>
    implements $BatchImageInputCopyWith<$Res> {
  _$BatchImageInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageBase64 = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: null == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchImageInputImplCopyWith<$Res>
    implements $BatchImageInputCopyWith<$Res> {
  factory _$$BatchImageInputImplCopyWith(_$BatchImageInputImpl value,
          $Res Function(_$BatchImageInputImpl) then) =
      __$$BatchImageInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, @JsonKey(name: 'image_base64') String imageBase64});
}

/// @nodoc
class __$$BatchImageInputImplCopyWithImpl<$Res>
    extends _$BatchImageInputCopyWithImpl<$Res, _$BatchImageInputImpl>
    implements _$$BatchImageInputImplCopyWith<$Res> {
  __$$BatchImageInputImplCopyWithImpl(
      _$BatchImageInputImpl _value, $Res Function(_$BatchImageInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageBase64 = null,
  }) {
    return _then(_$BatchImageInputImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: null == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchImageInputImpl implements _BatchImageInput {
  const _$BatchImageInputImpl(
      {required this.id,
      @JsonKey(name: 'image_base64') required this.imageBase64});

  factory _$BatchImageInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchImageInputImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'image_base64')
  final String imageBase64;

  @override
  String toString() {
    return 'BatchImageInput(id: $id, imageBase64: $imageBase64)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImageInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageBase64);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImageInputImplCopyWith<_$BatchImageInputImpl> get copyWith =>
      __$$BatchImageInputImplCopyWithImpl<_$BatchImageInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchImageInputImplToJson(
      this,
    );
  }
}

abstract class _BatchImageInput implements BatchImageInput {
  const factory _BatchImageInput(
          {required final String id,
          @JsonKey(name: 'image_base64') required final String imageBase64}) =
      _$BatchImageInputImpl;

  factory _BatchImageInput.fromJson(Map<String, dynamic> json) =
      _$BatchImageInputImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'image_base64')
  String get imageBase64;
  @override
  @JsonKey(ignore: true)
  _$$BatchImageInputImplCopyWith<_$BatchImageInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchExtractionResponse _$BatchExtractionResponseFromJson(
    Map<String, dynamic> json) {
  return _BatchExtractionResponse.fromJson(json);
}

/// @nodoc
mixin _$BatchExtractionResponse {
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_images')
  int get totalImages => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchExtractionResponseCopyWith<BatchExtractionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchExtractionResponseCopyWith<$Res> {
  factory $BatchExtractionResponseCopyWith(BatchExtractionResponse value,
          $Res Function(BatchExtractionResponse) then) =
      _$BatchExtractionResponseCopyWithImpl<$Res, BatchExtractionResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'job_id') String jobId,
      String status,
      @JsonKey(name: 'total_images') int totalImages,
      String? message});
}

/// @nodoc
class _$BatchExtractionResponseCopyWithImpl<$Res,
        $Val extends BatchExtractionResponse>
    implements $BatchExtractionResponseCopyWith<$Res> {
  _$BatchExtractionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchExtractionResponseImplCopyWith<$Res>
    implements $BatchExtractionResponseCopyWith<$Res> {
  factory _$$BatchExtractionResponseImplCopyWith(
          _$BatchExtractionResponseImpl value,
          $Res Function(_$BatchExtractionResponseImpl) then) =
      __$$BatchExtractionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'job_id') String jobId,
      String status,
      @JsonKey(name: 'total_images') int totalImages,
      String? message});
}

/// @nodoc
class __$$BatchExtractionResponseImplCopyWithImpl<$Res>
    extends _$BatchExtractionResponseCopyWithImpl<$Res,
        _$BatchExtractionResponseImpl>
    implements _$$BatchExtractionResponseImplCopyWith<$Res> {
  __$$BatchExtractionResponseImplCopyWithImpl(
      _$BatchExtractionResponseImpl _value,
      $Res Function(_$BatchExtractionResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? message = freezed,
  }) {
    return _then(_$BatchExtractionResponseImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchExtractionResponseImpl implements _BatchExtractionResponse {
  const _$BatchExtractionResponseImpl(
      {@JsonKey(name: 'job_id') required this.jobId,
      required this.status,
      @JsonKey(name: 'total_images') required this.totalImages,
      this.message});

  factory _$BatchExtractionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchExtractionResponseImplFromJson(json);

  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  final String status;
  @override
  @JsonKey(name: 'total_images')
  final int totalImages;
  @override
  final String? message;

  @override
  String toString() {
    return 'BatchExtractionResponse(jobId: $jobId, status: $status, totalImages: $totalImages, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchExtractionResponseImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalImages, totalImages) ||
                other.totalImages == totalImages) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, jobId, status, totalImages, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchExtractionResponseImplCopyWith<_$BatchExtractionResponseImpl>
      get copyWith => __$$BatchExtractionResponseImplCopyWithImpl<
          _$BatchExtractionResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchExtractionResponseImplToJson(
      this,
    );
  }
}

abstract class _BatchExtractionResponse implements BatchExtractionResponse {
  const factory _BatchExtractionResponse(
      {@JsonKey(name: 'job_id') required final String jobId,
      required final String status,
      @JsonKey(name: 'total_images') required final int totalImages,
      final String? message}) = _$BatchExtractionResponseImpl;

  factory _BatchExtractionResponse.fromJson(Map<String, dynamic> json) =
      _$BatchExtractionResponseImpl.fromJson;

  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  String get status;
  @override
  @JsonKey(name: 'total_images')
  int get totalImages;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$BatchExtractionResponseImplCopyWith<_$BatchExtractionResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BatchJobStatusResponse _$BatchJobStatusResponseFromJson(
    Map<String, dynamic> json) {
  return _BatchJobStatusResponse.fromJson(json);
}

/// @nodoc
mixin _$BatchJobStatusResponse {
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_images')
  int get totalImages => throw _privateConstructorUsedError;
  @JsonKey(name: 'extracted_count')
  int get extractedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'generated_count')
  int get generatedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'failed_count')
  int get failedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_batch')
  int get currentBatch => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_batches')
  int get totalBatches => throw _privateConstructorUsedError;
  List<BatchImageResult>? get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'detected_items')
  List<BatchExtractedItem>? get detectedItems =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchJobStatusResponseCopyWith<BatchJobStatusResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchJobStatusResponseCopyWith<$Res> {
  factory $BatchJobStatusResponseCopyWith(BatchJobStatusResponse value,
          $Res Function(BatchJobStatusResponse) then) =
      _$BatchJobStatusResponseCopyWithImpl<$Res, BatchJobStatusResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'job_id') String jobId,
      String status,
      @JsonKey(name: 'total_images') int totalImages,
      @JsonKey(name: 'extracted_count') int extractedCount,
      @JsonKey(name: 'generated_count') int generatedCount,
      @JsonKey(name: 'failed_count') int failedCount,
      @JsonKey(name: 'current_batch') int currentBatch,
      @JsonKey(name: 'total_batches') int totalBatches,
      List<BatchImageResult>? images,
      @JsonKey(name: 'detected_items') List<BatchExtractedItem>? detectedItems,
      String? error});
}

/// @nodoc
class _$BatchJobStatusResponseCopyWithImpl<$Res,
        $Val extends BatchJobStatusResponse>
    implements $BatchJobStatusResponseCopyWith<$Res> {
  _$BatchJobStatusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? extractedCount = null,
    Object? generatedCount = null,
    Object? failedCount = null,
    Object? currentBatch = null,
    Object? totalBatches = null,
    Object? images = freezed,
    Object? detectedItems = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      extractedCount: null == extractedCount
          ? _value.extractedCount
          : extractedCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedCount: null == generatedCount
          ? _value.generatedCount
          : generatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentBatch: null == currentBatch
          ? _value.currentBatch
          : currentBatch // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatches: null == totalBatches
          ? _value.totalBatches
          : totalBatches // ignore: cast_nullable_to_non_nullable
              as int,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<BatchImageResult>?,
      detectedItems: freezed == detectedItems
          ? _value.detectedItems
          : detectedItems // ignore: cast_nullable_to_non_nullable
              as List<BatchExtractedItem>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchJobStatusResponseImplCopyWith<$Res>
    implements $BatchJobStatusResponseCopyWith<$Res> {
  factory _$$BatchJobStatusResponseImplCopyWith(
          _$BatchJobStatusResponseImpl value,
          $Res Function(_$BatchJobStatusResponseImpl) then) =
      __$$BatchJobStatusResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'job_id') String jobId,
      String status,
      @JsonKey(name: 'total_images') int totalImages,
      @JsonKey(name: 'extracted_count') int extractedCount,
      @JsonKey(name: 'generated_count') int generatedCount,
      @JsonKey(name: 'failed_count') int failedCount,
      @JsonKey(name: 'current_batch') int currentBatch,
      @JsonKey(name: 'total_batches') int totalBatches,
      List<BatchImageResult>? images,
      @JsonKey(name: 'detected_items') List<BatchExtractedItem>? detectedItems,
      String? error});
}

/// @nodoc
class __$$BatchJobStatusResponseImplCopyWithImpl<$Res>
    extends _$BatchJobStatusResponseCopyWithImpl<$Res,
        _$BatchJobStatusResponseImpl>
    implements _$$BatchJobStatusResponseImplCopyWith<$Res> {
  __$$BatchJobStatusResponseImplCopyWithImpl(
      _$BatchJobStatusResponseImpl _value,
      $Res Function(_$BatchJobStatusResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? totalImages = null,
    Object? extractedCount = null,
    Object? generatedCount = null,
    Object? failedCount = null,
    Object? currentBatch = null,
    Object? totalBatches = null,
    Object? images = freezed,
    Object? detectedItems = freezed,
    Object? error = freezed,
  }) {
    return _then(_$BatchJobStatusResponseImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      extractedCount: null == extractedCount
          ? _value.extractedCount
          : extractedCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedCount: null == generatedCount
          ? _value.generatedCount
          : generatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentBatch: null == currentBatch
          ? _value.currentBatch
          : currentBatch // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatches: null == totalBatches
          ? _value.totalBatches
          : totalBatches // ignore: cast_nullable_to_non_nullable
              as int,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<BatchImageResult>?,
      detectedItems: freezed == detectedItems
          ? _value._detectedItems
          : detectedItems // ignore: cast_nullable_to_non_nullable
              as List<BatchExtractedItem>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchJobStatusResponseImpl implements _BatchJobStatusResponse {
  const _$BatchJobStatusResponseImpl(
      {@JsonKey(name: 'job_id') required this.jobId,
      required this.status,
      @JsonKey(name: 'total_images') required this.totalImages,
      @JsonKey(name: 'extracted_count') this.extractedCount = 0,
      @JsonKey(name: 'generated_count') this.generatedCount = 0,
      @JsonKey(name: 'failed_count') this.failedCount = 0,
      @JsonKey(name: 'current_batch') this.currentBatch = 0,
      @JsonKey(name: 'total_batches') this.totalBatches = 0,
      final List<BatchImageResult>? images,
      @JsonKey(name: 'detected_items')
      final List<BatchExtractedItem>? detectedItems,
      this.error})
      : _images = images,
        _detectedItems = detectedItems;

  factory _$BatchJobStatusResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchJobStatusResponseImplFromJson(json);

  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  final String status;
  @override
  @JsonKey(name: 'total_images')
  final int totalImages;
  @override
  @JsonKey(name: 'extracted_count')
  final int extractedCount;
  @override
  @JsonKey(name: 'generated_count')
  final int generatedCount;
  @override
  @JsonKey(name: 'failed_count')
  final int failedCount;
  @override
  @JsonKey(name: 'current_batch')
  final int currentBatch;
  @override
  @JsonKey(name: 'total_batches')
  final int totalBatches;
  final List<BatchImageResult>? _images;
  @override
  List<BatchImageResult>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BatchExtractedItem>? _detectedItems;
  @override
  @JsonKey(name: 'detected_items')
  List<BatchExtractedItem>? get detectedItems {
    final value = _detectedItems;
    if (value == null) return null;
    if (_detectedItems is EqualUnmodifiableListView) return _detectedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? error;

  @override
  String toString() {
    return 'BatchJobStatusResponse(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, images: $images, detectedItems: $detectedItems, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchJobStatusResponseImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalImages, totalImages) ||
                other.totalImages == totalImages) &&
            (identical(other.extractedCount, extractedCount) ||
                other.extractedCount == extractedCount) &&
            (identical(other.generatedCount, generatedCount) ||
                other.generatedCount == generatedCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount) &&
            (identical(other.currentBatch, currentBatch) ||
                other.currentBatch == currentBatch) &&
            (identical(other.totalBatches, totalBatches) ||
                other.totalBatches == totalBatches) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._detectedItems, _detectedItems) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      status,
      totalImages,
      extractedCount,
      generatedCount,
      failedCount,
      currentBatch,
      totalBatches,
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_detectedItems),
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchJobStatusResponseImplCopyWith<_$BatchJobStatusResponseImpl>
      get copyWith => __$$BatchJobStatusResponseImplCopyWithImpl<
          _$BatchJobStatusResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchJobStatusResponseImplToJson(
      this,
    );
  }
}

abstract class _BatchJobStatusResponse implements BatchJobStatusResponse {
  const factory _BatchJobStatusResponse(
      {@JsonKey(name: 'job_id') required final String jobId,
      required final String status,
      @JsonKey(name: 'total_images') required final int totalImages,
      @JsonKey(name: 'extracted_count') final int extractedCount,
      @JsonKey(name: 'generated_count') final int generatedCount,
      @JsonKey(name: 'failed_count') final int failedCount,
      @JsonKey(name: 'current_batch') final int currentBatch,
      @JsonKey(name: 'total_batches') final int totalBatches,
      final List<BatchImageResult>? images,
      @JsonKey(name: 'detected_items')
      final List<BatchExtractedItem>? detectedItems,
      final String? error}) = _$BatchJobStatusResponseImpl;

  factory _BatchJobStatusResponse.fromJson(Map<String, dynamic> json) =
      _$BatchJobStatusResponseImpl.fromJson;

  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  String get status;
  @override
  @JsonKey(name: 'total_images')
  int get totalImages;
  @override
  @JsonKey(name: 'extracted_count')
  int get extractedCount;
  @override
  @JsonKey(name: 'generated_count')
  int get generatedCount;
  @override
  @JsonKey(name: 'failed_count')
  int get failedCount;
  @override
  @JsonKey(name: 'current_batch')
  int get currentBatch;
  @override
  @JsonKey(name: 'total_batches')
  int get totalBatches;
  @override
  List<BatchImageResult>? get images;
  @override
  @JsonKey(name: 'detected_items')
  List<BatchExtractedItem>? get detectedItems;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$BatchJobStatusResponseImplCopyWith<_$BatchJobStatusResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BatchImageResult _$BatchImageResultFromJson(Map<String, dynamic> json) {
  return _BatchImageResult.fromJson(json);
}

/// @nodoc
mixin _$BatchImageResult {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_count')
  int get itemCount => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchImageResultCopyWith<BatchImageResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchImageResultCopyWith<$Res> {
  factory $BatchImageResultCopyWith(
          BatchImageResult value, $Res Function(BatchImageResult) then) =
      _$BatchImageResultCopyWithImpl<$Res, BatchImageResult>;
  @useResult
  $Res call(
      {String id,
      String status,
      @JsonKey(name: 'item_count') int itemCount,
      String? error});
}

/// @nodoc
class _$BatchImageResultCopyWithImpl<$Res, $Val extends BatchImageResult>
    implements $BatchImageResultCopyWith<$Res> {
  _$BatchImageResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? itemCount = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchImageResultImplCopyWith<$Res>
    implements $BatchImageResultCopyWith<$Res> {
  factory _$$BatchImageResultImplCopyWith(_$BatchImageResultImpl value,
          $Res Function(_$BatchImageResultImpl) then) =
      __$$BatchImageResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      @JsonKey(name: 'item_count') int itemCount,
      String? error});
}

/// @nodoc
class __$$BatchImageResultImplCopyWithImpl<$Res>
    extends _$BatchImageResultCopyWithImpl<$Res, _$BatchImageResultImpl>
    implements _$$BatchImageResultImplCopyWith<$Res> {
  __$$BatchImageResultImplCopyWithImpl(_$BatchImageResultImpl _value,
      $Res Function(_$BatchImageResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? itemCount = null,
    Object? error = freezed,
  }) {
    return _then(_$BatchImageResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchImageResultImpl implements _BatchImageResult {
  const _$BatchImageResultImpl(
      {required this.id,
      required this.status,
      @JsonKey(name: 'item_count') this.itemCount = 0,
      this.error});

  factory _$BatchImageResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchImageResultImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  @JsonKey(name: 'item_count')
  final int itemCount;
  @override
  final String? error;

  @override
  String toString() {
    return 'BatchImageResult(id: $id, status: $status, itemCount: $itemCount, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImageResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, itemCount, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImageResultImplCopyWith<_$BatchImageResultImpl> get copyWith =>
      __$$BatchImageResultImplCopyWithImpl<_$BatchImageResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchImageResultImplToJson(
      this,
    );
  }
}

abstract class _BatchImageResult implements BatchImageResult {
  const factory _BatchImageResult(
      {required final String id,
      required final String status,
      @JsonKey(name: 'item_count') final int itemCount,
      final String? error}) = _$BatchImageResultImpl;

  factory _BatchImageResult.fromJson(Map<String, dynamic> json) =
      _$BatchImageResultImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  @JsonKey(name: 'item_count')
  int get itemCount;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$BatchImageResultImplCopyWith<_$BatchImageResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
