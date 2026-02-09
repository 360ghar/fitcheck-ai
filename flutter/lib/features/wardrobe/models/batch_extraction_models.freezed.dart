// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_extraction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatchImage {

 String get id; String get filePath; String? get base64Data; String? get thumbnailPath; BatchImageStatus get status; String? get error; List<BatchExtractedItem> get extractedItems;
/// Create a copy of BatchImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchImageCopyWith<BatchImage> get copyWith => _$BatchImageCopyWithImpl<BatchImage>(this as BatchImage, _$identity);

  /// Serializes this BatchImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchImage&&(identical(other.id, id) || other.id == id)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.base64Data, base64Data) || other.base64Data == base64Data)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.extractedItems, extractedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filePath,base64Data,thumbnailPath,status,error,const DeepCollectionEquality().hash(extractedItems));

@override
String toString() {
  return 'BatchImage(id: $id, filePath: $filePath, base64Data: $base64Data, thumbnailPath: $thumbnailPath, status: $status, error: $error, extractedItems: $extractedItems)';
}


}

/// @nodoc
abstract mixin class $BatchImageCopyWith<$Res>  {
  factory $BatchImageCopyWith(BatchImage value, $Res Function(BatchImage) _then) = _$BatchImageCopyWithImpl;
@useResult
$Res call({
 String id, String filePath, String? base64Data, String? thumbnailPath, BatchImageStatus status, String? error, List<BatchExtractedItem> extractedItems
});




}
/// @nodoc
class _$BatchImageCopyWithImpl<$Res>
    implements $BatchImageCopyWith<$Res> {
  _$BatchImageCopyWithImpl(this._self, this._then);

  final BatchImage _self;
  final $Res Function(BatchImage) _then;

/// Create a copy of BatchImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filePath = null,Object? base64Data = freezed,Object? thumbnailPath = freezed,Object? status = null,Object? error = freezed,Object? extractedItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,base64Data: freezed == base64Data ? _self.base64Data : base64Data // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchImageStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,extractedItems: null == extractedItems ? _self.extractedItems : extractedItems // ignore: cast_nullable_to_non_nullable
as List<BatchExtractedItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchImage].
extension BatchImagePatterns on BatchImage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchImage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchImage value)  $default,){
final _that = this;
switch (_that) {
case _BatchImage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchImage value)?  $default,){
final _that = this;
switch (_that) {
case _BatchImage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String filePath,  String? base64Data,  String? thumbnailPath,  BatchImageStatus status,  String? error,  List<BatchExtractedItem> extractedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchImage() when $default != null:
return $default(_that.id,_that.filePath,_that.base64Data,_that.thumbnailPath,_that.status,_that.error,_that.extractedItems);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String filePath,  String? base64Data,  String? thumbnailPath,  BatchImageStatus status,  String? error,  List<BatchExtractedItem> extractedItems)  $default,) {final _that = this;
switch (_that) {
case _BatchImage():
return $default(_that.id,_that.filePath,_that.base64Data,_that.thumbnailPath,_that.status,_that.error,_that.extractedItems);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String filePath,  String? base64Data,  String? thumbnailPath,  BatchImageStatus status,  String? error,  List<BatchExtractedItem> extractedItems)?  $default,) {final _that = this;
switch (_that) {
case _BatchImage() when $default != null:
return $default(_that.id,_that.filePath,_that.base64Data,_that.thumbnailPath,_that.status,_that.error,_that.extractedItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchImage implements BatchImage {
  const _BatchImage({required this.id, required this.filePath, this.base64Data, this.thumbnailPath, this.status = BatchImageStatus.pending, this.error, final  List<BatchExtractedItem> extractedItems = const []}): _extractedItems = extractedItems;
  factory _BatchImage.fromJson(Map<String, dynamic> json) => _$BatchImageFromJson(json);

@override final  String id;
@override final  String filePath;
@override final  String? base64Data;
@override final  String? thumbnailPath;
@override@JsonKey() final  BatchImageStatus status;
@override final  String? error;
 final  List<BatchExtractedItem> _extractedItems;
@override@JsonKey() List<BatchExtractedItem> get extractedItems {
  if (_extractedItems is EqualUnmodifiableListView) return _extractedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extractedItems);
}


/// Create a copy of BatchImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchImageCopyWith<_BatchImage> get copyWith => __$BatchImageCopyWithImpl<_BatchImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchImage&&(identical(other.id, id) || other.id == id)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.base64Data, base64Data) || other.base64Data == base64Data)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._extractedItems, _extractedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filePath,base64Data,thumbnailPath,status,error,const DeepCollectionEquality().hash(_extractedItems));

@override
String toString() {
  return 'BatchImage(id: $id, filePath: $filePath, base64Data: $base64Data, thumbnailPath: $thumbnailPath, status: $status, error: $error, extractedItems: $extractedItems)';
}


}

/// @nodoc
abstract mixin class _$BatchImageCopyWith<$Res> implements $BatchImageCopyWith<$Res> {
  factory _$BatchImageCopyWith(_BatchImage value, $Res Function(_BatchImage) _then) = __$BatchImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String filePath, String? base64Data, String? thumbnailPath, BatchImageStatus status, String? error, List<BatchExtractedItem> extractedItems
});




}
/// @nodoc
class __$BatchImageCopyWithImpl<$Res>
    implements _$BatchImageCopyWith<$Res> {
  __$BatchImageCopyWithImpl(this._self, this._then);

  final _BatchImage _self;
  final $Res Function(_BatchImage) _then;

/// Create a copy of BatchImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filePath = null,Object? base64Data = freezed,Object? thumbnailPath = freezed,Object? status = null,Object? error = freezed,Object? extractedItems = null,}) {
  return _then(_BatchImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,base64Data: freezed == base64Data ? _self.base64Data : base64Data // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchImageStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,extractedItems: null == extractedItems ? _self._extractedItems : extractedItems // ignore: cast_nullable_to_non_nullable
as List<BatchExtractedItem>,
  ));
}


}


/// @nodoc
mixin _$BatchExtractionJob {

 String get jobId; BatchJobStatus get status; int get totalImages; int get extractedCount; int get generatedCount; int get failedCount; int get currentBatch; int get totalBatches; String? get error; DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of BatchExtractionJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchExtractionJobCopyWith<BatchExtractionJob> get copyWith => _$BatchExtractionJobCopyWithImpl<BatchExtractionJob>(this as BatchExtractionJob, _$identity);

  /// Serializes this BatchExtractionJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchExtractionJob&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.extractedCount, extractedCount) || other.extractedCount == extractedCount)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&(identical(other.error, error) || other.error == error)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,extractedCount,generatedCount,failedCount,currentBatch,totalBatches,error,startedAt,completedAt);

@override
String toString() {
  return 'BatchExtractionJob(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, error: $error, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $BatchExtractionJobCopyWith<$Res>  {
  factory $BatchExtractionJobCopyWith(BatchExtractionJob value, $Res Function(BatchExtractionJob) _then) = _$BatchExtractionJobCopyWithImpl;
@useResult
$Res call({
 String jobId, BatchJobStatus status, int totalImages, int extractedCount, int generatedCount, int failedCount, int currentBatch, int totalBatches, String? error, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$BatchExtractionJobCopyWithImpl<$Res>
    implements $BatchExtractionJobCopyWith<$Res> {
  _$BatchExtractionJobCopyWithImpl(this._self, this._then);

  final BatchExtractionJob _self;
  final $Res Function(BatchExtractionJob) _then;

/// Create a copy of BatchExtractionJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? extractedCount = null,Object? generatedCount = null,Object? failedCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? error = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchJobStatus,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,extractedCount: null == extractedCount ? _self.extractedCount : extractedCount // ignore: cast_nullable_to_non_nullable
as int,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchExtractionJob].
extension BatchExtractionJobPatterns on BatchExtractionJob {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchExtractionJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchExtractionJob() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchExtractionJob value)  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionJob():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchExtractionJob value)?  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionJob() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  BatchJobStatus status,  int totalImages,  int extractedCount,  int generatedCount,  int failedCount,  int currentBatch,  int totalBatches,  String? error,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchExtractionJob() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.currentBatch,_that.totalBatches,_that.error,_that.startedAt,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  BatchJobStatus status,  int totalImages,  int extractedCount,  int generatedCount,  int failedCount,  int currentBatch,  int totalBatches,  String? error,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionJob():
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.currentBatch,_that.totalBatches,_that.error,_that.startedAt,_that.completedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  BatchJobStatus status,  int totalImages,  int extractedCount,  int generatedCount,  int failedCount,  int currentBatch,  int totalBatches,  String? error,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionJob() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.currentBatch,_that.totalBatches,_that.error,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchExtractionJob implements BatchExtractionJob {
  const _BatchExtractionJob({required this.jobId, required this.status, required this.totalImages, this.extractedCount = 0, this.generatedCount = 0, this.failedCount = 0, this.currentBatch = 0, this.totalBatches = 0, this.error, this.startedAt, this.completedAt});
  factory _BatchExtractionJob.fromJson(Map<String, dynamic> json) => _$BatchExtractionJobFromJson(json);

@override final  String jobId;
@override final  BatchJobStatus status;
@override final  int totalImages;
@override@JsonKey() final  int extractedCount;
@override@JsonKey() final  int generatedCount;
@override@JsonKey() final  int failedCount;
@override@JsonKey() final  int currentBatch;
@override@JsonKey() final  int totalBatches;
@override final  String? error;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of BatchExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchExtractionJobCopyWith<_BatchExtractionJob> get copyWith => __$BatchExtractionJobCopyWithImpl<_BatchExtractionJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchExtractionJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchExtractionJob&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.extractedCount, extractedCount) || other.extractedCount == extractedCount)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&(identical(other.error, error) || other.error == error)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,extractedCount,generatedCount,failedCount,currentBatch,totalBatches,error,startedAt,completedAt);

@override
String toString() {
  return 'BatchExtractionJob(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, error: $error, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$BatchExtractionJobCopyWith<$Res> implements $BatchExtractionJobCopyWith<$Res> {
  factory _$BatchExtractionJobCopyWith(_BatchExtractionJob value, $Res Function(_BatchExtractionJob) _then) = __$BatchExtractionJobCopyWithImpl;
@override @useResult
$Res call({
 String jobId, BatchJobStatus status, int totalImages, int extractedCount, int generatedCount, int failedCount, int currentBatch, int totalBatches, String? error, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$BatchExtractionJobCopyWithImpl<$Res>
    implements _$BatchExtractionJobCopyWith<$Res> {
  __$BatchExtractionJobCopyWithImpl(this._self, this._then);

  final _BatchExtractionJob _self;
  final $Res Function(_BatchExtractionJob) _then;

/// Create a copy of BatchExtractionJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? extractedCount = null,Object? generatedCount = null,Object? failedCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? error = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_BatchExtractionJob(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchJobStatus,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,extractedCount: null == extractedCount ? _self.extractedCount : extractedCount // ignore: cast_nullable_to_non_nullable
as int,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BatchExtractedItem {

@JsonKey(name: 'temp_id') String get id;@JsonKey(name: 'image_id') String get sourceImageId; String get name; Category get category;@JsonKey(name: 'sub_category') String? get subCategory; List<String> get colors; String? get material; String? get pattern; String? get brand; String? get description;@JsonKey(name: 'bounding_box') Map<String, dynamic>? get boundingBox;@JsonKey(name: 'cropped_image_base64') String? get croppedImageBase64;@JsonKey(name: 'generated_image_base64') String? get generatedImageBase64;@JsonKey(name: 'generated_image_url') String? get generatedImageUrl; double? get confidence;@JsonKey(name: 'person_id') String? get personId;@JsonKey(name: 'person_label') String? get personLabel;@JsonKey(name: 'is_current_user_person') bool get isCurrentUserPerson;@JsonKey(name: 'include_in_wardrobe') bool get includeInWardrobe;@JsonKey(unknownEnumValue: BatchItemStatus.pending) BatchItemStatus get status; bool get isSelected; String? get error;
/// Create a copy of BatchExtractedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchExtractedItemCopyWith<BatchExtractedItem> get copyWith => _$BatchExtractedItemCopyWithImpl<BatchExtractedItem>(this as BatchExtractedItem, _$identity);

  /// Serializes this BatchExtractedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchExtractedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceImageId, sourceImageId) || other.sourceImageId == sourceImageId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.boundingBox, boundingBox)&&(identical(other.croppedImageBase64, croppedImageBase64) || other.croppedImageBase64 == croppedImageBase64)&&(identical(other.generatedImageBase64, generatedImageBase64) || other.generatedImageBase64 == generatedImageBase64)&&(identical(other.generatedImageUrl, generatedImageUrl) || other.generatedImageUrl == generatedImageUrl)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sourceImageId,name,category,subCategory,const DeepCollectionEquality().hash(colors),material,pattern,brand,description,const DeepCollectionEquality().hash(boundingBox),croppedImageBase64,generatedImageBase64,generatedImageUrl,confidence,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status,isSelected,error]);

@override
String toString() {
  return 'BatchExtractedItem(id: $id, sourceImageId: $sourceImageId, name: $name, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, description: $description, boundingBox: $boundingBox, croppedImageBase64: $croppedImageBase64, generatedImageBase64: $generatedImageBase64, generatedImageUrl: $generatedImageUrl, confidence: $confidence, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status, isSelected: $isSelected, error: $error)';
}


}

/// @nodoc
abstract mixin class $BatchExtractedItemCopyWith<$Res>  {
  factory $BatchExtractedItemCopyWith(BatchExtractedItem value, $Res Function(BatchExtractedItem) _then) = _$BatchExtractedItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'temp_id') String id,@JsonKey(name: 'image_id') String sourceImageId, String name, Category category,@JsonKey(name: 'sub_category') String? subCategory, List<String> colors, String? material, String? pattern, String? brand, String? description,@JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,@JsonKey(name: 'cropped_image_base64') String? croppedImageBase64,@JsonKey(name: 'generated_image_base64') String? generatedImageBase64,@JsonKey(name: 'generated_image_url') String? generatedImageUrl, double? confidence,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe,@JsonKey(unknownEnumValue: BatchItemStatus.pending) BatchItemStatus status, bool isSelected, String? error
});




}
/// @nodoc
class _$BatchExtractedItemCopyWithImpl<$Res>
    implements $BatchExtractedItemCopyWith<$Res> {
  _$BatchExtractedItemCopyWithImpl(this._self, this._then);

  final BatchExtractedItem _self;
  final $Res Function(BatchExtractedItem) _then;

/// Create a copy of BatchExtractedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceImageId = null,Object? name = null,Object? category = null,Object? subCategory = freezed,Object? colors = null,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? description = freezed,Object? boundingBox = freezed,Object? croppedImageBase64 = freezed,Object? generatedImageBase64 = freezed,Object? generatedImageUrl = freezed,Object? confidence = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,Object? isSelected = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceImageId: null == sourceImageId ? _self.sourceImageId : sourceImageId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,boundingBox: freezed == boundingBox ? _self.boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,croppedImageBase64: freezed == croppedImageBase64 ? _self.croppedImageBase64 : croppedImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,generatedImageBase64: freezed == generatedImageBase64 ? _self.generatedImageBase64 : generatedImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,generatedImageUrl: freezed == generatedImageUrl ? _self.generatedImageUrl : generatedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchItemStatus,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchExtractedItem].
extension BatchExtractedItemPatterns on BatchExtractedItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchExtractedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchExtractedItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchExtractedItem value)  $default,){
final _that = this;
switch (_that) {
case _BatchExtractedItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchExtractedItem value)?  $default,){
final _that = this;
switch (_that) {
case _BatchExtractedItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'temp_id')  String id, @JsonKey(name: 'image_id')  String sourceImageId,  String name,  Category category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String> colors,  String? material,  String? pattern,  String? brand,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox, @JsonKey(name: 'cropped_image_base64')  String? croppedImageBase64, @JsonKey(name: 'generated_image_base64')  String? generatedImageBase64, @JsonKey(name: 'generated_image_url')  String? generatedImageUrl,  double? confidence, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe, @JsonKey(unknownEnumValue: BatchItemStatus.pending)  BatchItemStatus status,  bool isSelected,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchExtractedItem() when $default != null:
return $default(_that.id,_that.sourceImageId,_that.name,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.description,_that.boundingBox,_that.croppedImageBase64,_that.generatedImageBase64,_that.generatedImageUrl,_that.confidence,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.isSelected,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'temp_id')  String id, @JsonKey(name: 'image_id')  String sourceImageId,  String name,  Category category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String> colors,  String? material,  String? pattern,  String? brand,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox, @JsonKey(name: 'cropped_image_base64')  String? croppedImageBase64, @JsonKey(name: 'generated_image_base64')  String? generatedImageBase64, @JsonKey(name: 'generated_image_url')  String? generatedImageUrl,  double? confidence, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe, @JsonKey(unknownEnumValue: BatchItemStatus.pending)  BatchItemStatus status,  bool isSelected,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BatchExtractedItem():
return $default(_that.id,_that.sourceImageId,_that.name,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.description,_that.boundingBox,_that.croppedImageBase64,_that.generatedImageBase64,_that.generatedImageUrl,_that.confidence,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.isSelected,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'temp_id')  String id, @JsonKey(name: 'image_id')  String sourceImageId,  String name,  Category category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String> colors,  String? material,  String? pattern,  String? brand,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox, @JsonKey(name: 'cropped_image_base64')  String? croppedImageBase64, @JsonKey(name: 'generated_image_base64')  String? generatedImageBase64, @JsonKey(name: 'generated_image_url')  String? generatedImageUrl,  double? confidence, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe, @JsonKey(unknownEnumValue: BatchItemStatus.pending)  BatchItemStatus status,  bool isSelected,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BatchExtractedItem() when $default != null:
return $default(_that.id,_that.sourceImageId,_that.name,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.description,_that.boundingBox,_that.croppedImageBase64,_that.generatedImageBase64,_that.generatedImageUrl,_that.confidence,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.isSelected,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchExtractedItem implements BatchExtractedItem {
  const _BatchExtractedItem({@JsonKey(name: 'temp_id') required this.id, @JsonKey(name: 'image_id') required this.sourceImageId, required this.name, required this.category, @JsonKey(name: 'sub_category') this.subCategory, final  List<String> colors = const [], this.material, this.pattern, this.brand, this.description, @JsonKey(name: 'bounding_box') final  Map<String, dynamic>? boundingBox, @JsonKey(name: 'cropped_image_base64') this.croppedImageBase64, @JsonKey(name: 'generated_image_base64') this.generatedImageBase64, @JsonKey(name: 'generated_image_url') this.generatedImageUrl, this.confidence, @JsonKey(name: 'person_id') this.personId, @JsonKey(name: 'person_label') this.personLabel, @JsonKey(name: 'is_current_user_person') this.isCurrentUserPerson = false, @JsonKey(name: 'include_in_wardrobe') this.includeInWardrobe = true, @JsonKey(unknownEnumValue: BatchItemStatus.pending) this.status = BatchItemStatus.pending, this.isSelected = true, this.error}): _colors = colors,_boundingBox = boundingBox;
  factory _BatchExtractedItem.fromJson(Map<String, dynamic> json) => _$BatchExtractedItemFromJson(json);

@override@JsonKey(name: 'temp_id') final  String id;
@override@JsonKey(name: 'image_id') final  String sourceImageId;
@override final  String name;
@override final  Category category;
@override@JsonKey(name: 'sub_category') final  String? subCategory;
 final  List<String> _colors;
@override@JsonKey() List<String> get colors {
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_colors);
}

@override final  String? material;
@override final  String? pattern;
@override final  String? brand;
@override final  String? description;
 final  Map<String, dynamic>? _boundingBox;
@override@JsonKey(name: 'bounding_box') Map<String, dynamic>? get boundingBox {
  final value = _boundingBox;
  if (value == null) return null;
  if (_boundingBox is EqualUnmodifiableMapView) return _boundingBox;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'cropped_image_base64') final  String? croppedImageBase64;
@override@JsonKey(name: 'generated_image_base64') final  String? generatedImageBase64;
@override@JsonKey(name: 'generated_image_url') final  String? generatedImageUrl;
@override final  double? confidence;
@override@JsonKey(name: 'person_id') final  String? personId;
@override@JsonKey(name: 'person_label') final  String? personLabel;
@override@JsonKey(name: 'is_current_user_person') final  bool isCurrentUserPerson;
@override@JsonKey(name: 'include_in_wardrobe') final  bool includeInWardrobe;
@override@JsonKey(unknownEnumValue: BatchItemStatus.pending) final  BatchItemStatus status;
@override@JsonKey() final  bool isSelected;
@override final  String? error;

/// Create a copy of BatchExtractedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchExtractedItemCopyWith<_BatchExtractedItem> get copyWith => __$BatchExtractedItemCopyWithImpl<_BatchExtractedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchExtractedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchExtractedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceImageId, sourceImageId) || other.sourceImageId == sourceImageId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._boundingBox, _boundingBox)&&(identical(other.croppedImageBase64, croppedImageBase64) || other.croppedImageBase64 == croppedImageBase64)&&(identical(other.generatedImageBase64, generatedImageBase64) || other.generatedImageBase64 == generatedImageBase64)&&(identical(other.generatedImageUrl, generatedImageUrl) || other.generatedImageUrl == generatedImageUrl)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sourceImageId,name,category,subCategory,const DeepCollectionEquality().hash(_colors),material,pattern,brand,description,const DeepCollectionEquality().hash(_boundingBox),croppedImageBase64,generatedImageBase64,generatedImageUrl,confidence,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status,isSelected,error]);

@override
String toString() {
  return 'BatchExtractedItem(id: $id, sourceImageId: $sourceImageId, name: $name, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, description: $description, boundingBox: $boundingBox, croppedImageBase64: $croppedImageBase64, generatedImageBase64: $generatedImageBase64, generatedImageUrl: $generatedImageUrl, confidence: $confidence, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status, isSelected: $isSelected, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BatchExtractedItemCopyWith<$Res> implements $BatchExtractedItemCopyWith<$Res> {
  factory _$BatchExtractedItemCopyWith(_BatchExtractedItem value, $Res Function(_BatchExtractedItem) _then) = __$BatchExtractedItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'temp_id') String id,@JsonKey(name: 'image_id') String sourceImageId, String name, Category category,@JsonKey(name: 'sub_category') String? subCategory, List<String> colors, String? material, String? pattern, String? brand, String? description,@JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,@JsonKey(name: 'cropped_image_base64') String? croppedImageBase64,@JsonKey(name: 'generated_image_base64') String? generatedImageBase64,@JsonKey(name: 'generated_image_url') String? generatedImageUrl, double? confidence,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe,@JsonKey(unknownEnumValue: BatchItemStatus.pending) BatchItemStatus status, bool isSelected, String? error
});




}
/// @nodoc
class __$BatchExtractedItemCopyWithImpl<$Res>
    implements _$BatchExtractedItemCopyWith<$Res> {
  __$BatchExtractedItemCopyWithImpl(this._self, this._then);

  final _BatchExtractedItem _self;
  final $Res Function(_BatchExtractedItem) _then;

/// Create a copy of BatchExtractedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceImageId = null,Object? name = null,Object? category = null,Object? subCategory = freezed,Object? colors = null,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? description = freezed,Object? boundingBox = freezed,Object? croppedImageBase64 = freezed,Object? generatedImageBase64 = freezed,Object? generatedImageUrl = freezed,Object? confidence = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,Object? isSelected = null,Object? error = freezed,}) {
  return _then(_BatchExtractedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceImageId: null == sourceImageId ? _self.sourceImageId : sourceImageId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: null == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,boundingBox: freezed == boundingBox ? _self._boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,croppedImageBase64: freezed == croppedImageBase64 ? _self.croppedImageBase64 : croppedImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,generatedImageBase64: freezed == generatedImageBase64 ? _self.generatedImageBase64 : generatedImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,generatedImageUrl: freezed == generatedImageUrl ? _self.generatedImageUrl : generatedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchItemStatus,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SSEEvent {

 String get type; Map<String, dynamic>? get data;
/// Create a copy of SSEEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SSEEventCopyWith<SSEEvent> get copyWith => _$SSEEventCopyWithImpl<SSEEvent>(this as SSEEvent, _$identity);

  /// Serializes this SSEEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SSEEvent&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SSEEvent(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $SSEEventCopyWith<$Res>  {
  factory $SSEEventCopyWith(SSEEvent value, $Res Function(SSEEvent) _then) = _$SSEEventCopyWithImpl;
@useResult
$Res call({
 String type, Map<String, dynamic>? data
});




}
/// @nodoc
class _$SSEEventCopyWithImpl<$Res>
    implements $SSEEventCopyWith<$Res> {
  _$SSEEventCopyWithImpl(this._self, this._then);

  final SSEEvent _self;
  final $Res Function(SSEEvent) _then;

/// Create a copy of SSEEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SSEEvent].
extension SSEEventPatterns on SSEEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SSEEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SSEEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SSEEvent value)  $default,){
final _that = this;
switch (_that) {
case _SSEEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SSEEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SSEEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SSEEvent() when $default != null:
return $default(_that.type,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data)  $default,) {final _that = this;
switch (_that) {
case _SSEEvent():
return $default(_that.type,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  Map<String, dynamic>? data)?  $default,) {final _that = this;
switch (_that) {
case _SSEEvent() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SSEEvent implements SSEEvent {
  const _SSEEvent({required this.type, final  Map<String, dynamic>? data}): _data = data;
  factory _SSEEvent.fromJson(Map<String, dynamic> json) => _$SSEEventFromJson(json);

@override final  String type;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SSEEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SSEEventCopyWith<_SSEEvent> get copyWith => __$SSEEventCopyWithImpl<_SSEEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SSEEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SSEEvent&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'SSEEvent(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$SSEEventCopyWith<$Res> implements $SSEEventCopyWith<$Res> {
  factory _$SSEEventCopyWith(_SSEEvent value, $Res Function(_SSEEvent) _then) = __$SSEEventCopyWithImpl;
@override @useResult
$Res call({
 String type, Map<String, dynamic>? data
});




}
/// @nodoc
class __$SSEEventCopyWithImpl<$Res>
    implements _$SSEEventCopyWith<$Res> {
  __$SSEEventCopyWithImpl(this._self, this._then);

  final _SSEEvent _self;
  final $Res Function(_SSEEvent) _then;

/// Create a copy of SSEEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_SSEEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$BatchExtractionRequest {

 List<BatchImageInput> get images;@JsonKey(name: 'auto_generate') bool get autoGenerate;@JsonKey(name: 'generation_batch_size') int get generationBatchSize;
/// Create a copy of BatchExtractionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchExtractionRequestCopyWith<BatchExtractionRequest> get copyWith => _$BatchExtractionRequestCopyWithImpl<BatchExtractionRequest>(this as BatchExtractionRequest, _$identity);

  /// Serializes this BatchExtractionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchExtractionRequest&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.autoGenerate, autoGenerate) || other.autoGenerate == autoGenerate)&&(identical(other.generationBatchSize, generationBatchSize) || other.generationBatchSize == generationBatchSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(images),autoGenerate,generationBatchSize);

@override
String toString() {
  return 'BatchExtractionRequest(images: $images, autoGenerate: $autoGenerate, generationBatchSize: $generationBatchSize)';
}


}

/// @nodoc
abstract mixin class $BatchExtractionRequestCopyWith<$Res>  {
  factory $BatchExtractionRequestCopyWith(BatchExtractionRequest value, $Res Function(BatchExtractionRequest) _then) = _$BatchExtractionRequestCopyWithImpl;
@useResult
$Res call({
 List<BatchImageInput> images,@JsonKey(name: 'auto_generate') bool autoGenerate,@JsonKey(name: 'generation_batch_size') int generationBatchSize
});




}
/// @nodoc
class _$BatchExtractionRequestCopyWithImpl<$Res>
    implements $BatchExtractionRequestCopyWith<$Res> {
  _$BatchExtractionRequestCopyWithImpl(this._self, this._then);

  final BatchExtractionRequest _self;
  final $Res Function(BatchExtractionRequest) _then;

/// Create a copy of BatchExtractionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? images = null,Object? autoGenerate = null,Object? generationBatchSize = null,}) {
  return _then(_self.copyWith(
images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<BatchImageInput>,autoGenerate: null == autoGenerate ? _self.autoGenerate : autoGenerate // ignore: cast_nullable_to_non_nullable
as bool,generationBatchSize: null == generationBatchSize ? _self.generationBatchSize : generationBatchSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchExtractionRequest].
extension BatchExtractionRequestPatterns on BatchExtractionRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchExtractionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchExtractionRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchExtractionRequest value)  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchExtractionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BatchImageInput> images, @JsonKey(name: 'auto_generate')  bool autoGenerate, @JsonKey(name: 'generation_batch_size')  int generationBatchSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchExtractionRequest() when $default != null:
return $default(_that.images,_that.autoGenerate,_that.generationBatchSize);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BatchImageInput> images, @JsonKey(name: 'auto_generate')  bool autoGenerate, @JsonKey(name: 'generation_batch_size')  int generationBatchSize)  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionRequest():
return $default(_that.images,_that.autoGenerate,_that.generationBatchSize);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BatchImageInput> images, @JsonKey(name: 'auto_generate')  bool autoGenerate, @JsonKey(name: 'generation_batch_size')  int generationBatchSize)?  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionRequest() when $default != null:
return $default(_that.images,_that.autoGenerate,_that.generationBatchSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchExtractionRequest implements BatchExtractionRequest {
  const _BatchExtractionRequest({required final  List<BatchImageInput> images, @JsonKey(name: 'auto_generate') this.autoGenerate = true, @JsonKey(name: 'generation_batch_size') this.generationBatchSize = 5}): _images = images;
  factory _BatchExtractionRequest.fromJson(Map<String, dynamic> json) => _$BatchExtractionRequestFromJson(json);

 final  List<BatchImageInput> _images;
@override List<BatchImageInput> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'auto_generate') final  bool autoGenerate;
@override@JsonKey(name: 'generation_batch_size') final  int generationBatchSize;

/// Create a copy of BatchExtractionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchExtractionRequestCopyWith<_BatchExtractionRequest> get copyWith => __$BatchExtractionRequestCopyWithImpl<_BatchExtractionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchExtractionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchExtractionRequest&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.autoGenerate, autoGenerate) || other.autoGenerate == autoGenerate)&&(identical(other.generationBatchSize, generationBatchSize) || other.generationBatchSize == generationBatchSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_images),autoGenerate,generationBatchSize);

@override
String toString() {
  return 'BatchExtractionRequest(images: $images, autoGenerate: $autoGenerate, generationBatchSize: $generationBatchSize)';
}


}

/// @nodoc
abstract mixin class _$BatchExtractionRequestCopyWith<$Res> implements $BatchExtractionRequestCopyWith<$Res> {
  factory _$BatchExtractionRequestCopyWith(_BatchExtractionRequest value, $Res Function(_BatchExtractionRequest) _then) = __$BatchExtractionRequestCopyWithImpl;
@override @useResult
$Res call({
 List<BatchImageInput> images,@JsonKey(name: 'auto_generate') bool autoGenerate,@JsonKey(name: 'generation_batch_size') int generationBatchSize
});




}
/// @nodoc
class __$BatchExtractionRequestCopyWithImpl<$Res>
    implements _$BatchExtractionRequestCopyWith<$Res> {
  __$BatchExtractionRequestCopyWithImpl(this._self, this._then);

  final _BatchExtractionRequest _self;
  final $Res Function(_BatchExtractionRequest) _then;

/// Create a copy of BatchExtractionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? images = null,Object? autoGenerate = null,Object? generationBatchSize = null,}) {
  return _then(_BatchExtractionRequest(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<BatchImageInput>,autoGenerate: null == autoGenerate ? _self.autoGenerate : autoGenerate // ignore: cast_nullable_to_non_nullable
as bool,generationBatchSize: null == generationBatchSize ? _self.generationBatchSize : generationBatchSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BatchImageInput {

@JsonKey(name: 'image_id') String get imageId;@JsonKey(name: 'image_base64') String get imageBase64;
/// Create a copy of BatchImageInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchImageInputCopyWith<BatchImageInput> get copyWith => _$BatchImageInputCopyWithImpl<BatchImageInput>(this as BatchImageInput, _$identity);

  /// Serializes this BatchImageInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchImageInput&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageBase64);

@override
String toString() {
  return 'BatchImageInput(imageId: $imageId, imageBase64: $imageBase64)';
}


}

/// @nodoc
abstract mixin class $BatchImageInputCopyWith<$Res>  {
  factory $BatchImageInputCopyWith(BatchImageInput value, $Res Function(BatchImageInput) _then) = _$BatchImageInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_id') String imageId,@JsonKey(name: 'image_base64') String imageBase64
});




}
/// @nodoc
class _$BatchImageInputCopyWithImpl<$Res>
    implements $BatchImageInputCopyWith<$Res> {
  _$BatchImageInputCopyWithImpl(this._self, this._then);

  final BatchImageInput _self;
  final $Res Function(BatchImageInput) _then;

/// Create a copy of BatchImageInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? imageBase64 = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchImageInput].
extension BatchImageInputPatterns on BatchImageInput {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchImageInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchImageInput() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchImageInput value)  $default,){
final _that = this;
switch (_that) {
case _BatchImageInput():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchImageInput value)?  $default,){
final _that = this;
switch (_that) {
case _BatchImageInput() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_id')  String imageId, @JsonKey(name: 'image_base64')  String imageBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchImageInput() when $default != null:
return $default(_that.imageId,_that.imageBase64);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_id')  String imageId, @JsonKey(name: 'image_base64')  String imageBase64)  $default,) {final _that = this;
switch (_that) {
case _BatchImageInput():
return $default(_that.imageId,_that.imageBase64);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'image_id')  String imageId, @JsonKey(name: 'image_base64')  String imageBase64)?  $default,) {final _that = this;
switch (_that) {
case _BatchImageInput() when $default != null:
return $default(_that.imageId,_that.imageBase64);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchImageInput implements BatchImageInput {
  const _BatchImageInput({@JsonKey(name: 'image_id') required this.imageId, @JsonKey(name: 'image_base64') required this.imageBase64});
  factory _BatchImageInput.fromJson(Map<String, dynamic> json) => _$BatchImageInputFromJson(json);

@override@JsonKey(name: 'image_id') final  String imageId;
@override@JsonKey(name: 'image_base64') final  String imageBase64;

/// Create a copy of BatchImageInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchImageInputCopyWith<_BatchImageInput> get copyWith => __$BatchImageInputCopyWithImpl<_BatchImageInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchImageInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchImageInput&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageBase64);

@override
String toString() {
  return 'BatchImageInput(imageId: $imageId, imageBase64: $imageBase64)';
}


}

/// @nodoc
abstract mixin class _$BatchImageInputCopyWith<$Res> implements $BatchImageInputCopyWith<$Res> {
  factory _$BatchImageInputCopyWith(_BatchImageInput value, $Res Function(_BatchImageInput) _then) = __$BatchImageInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'image_id') String imageId,@JsonKey(name: 'image_base64') String imageBase64
});




}
/// @nodoc
class __$BatchImageInputCopyWithImpl<$Res>
    implements _$BatchImageInputCopyWith<$Res> {
  __$BatchImageInputCopyWithImpl(this._self, this._then);

  final _BatchImageInput _self;
  final $Res Function(_BatchImageInput) _then;

/// Create a copy of BatchImageInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? imageBase64 = null,}) {
  return _then(_BatchImageInput(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BatchExtractionResponse {

@JsonKey(name: 'job_id') String get jobId; String get status;@JsonKey(name: 'total_images') int get totalImages; String? get message;
/// Create a copy of BatchExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchExtractionResponseCopyWith<BatchExtractionResponse> get copyWith => _$BatchExtractionResponseCopyWithImpl<BatchExtractionResponse>(this as BatchExtractionResponse, _$identity);

  /// Serializes this BatchExtractionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchExtractionResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,message);

@override
String toString() {
  return 'BatchExtractionResponse(jobId: $jobId, status: $status, totalImages: $totalImages, message: $message)';
}


}

/// @nodoc
abstract mixin class $BatchExtractionResponseCopyWith<$Res>  {
  factory $BatchExtractionResponseCopyWith(BatchExtractionResponse value, $Res Function(BatchExtractionResponse) _then) = _$BatchExtractionResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'total_images') int totalImages, String? message
});




}
/// @nodoc
class _$BatchExtractionResponseCopyWithImpl<$Res>
    implements $BatchExtractionResponseCopyWith<$Res> {
  _$BatchExtractionResponseCopyWithImpl(this._self, this._then);

  final BatchExtractionResponse _self;
  final $Res Function(BatchExtractionResponse) _then;

/// Create a copy of BatchExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchExtractionResponse].
extension BatchExtractionResponsePatterns on BatchExtractionResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchExtractionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchExtractionResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchExtractionResponse value)  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchExtractionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BatchExtractionResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchExtractionResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages,  String? message)  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionResponse():
return $default(_that.jobId,_that.status,_that.totalImages,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _BatchExtractionResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchExtractionResponse implements BatchExtractionResponse {
  const _BatchExtractionResponse({@JsonKey(name: 'job_id') required this.jobId, required this.status, @JsonKey(name: 'total_images') required this.totalImages, this.message});
  factory _BatchExtractionResponse.fromJson(Map<String, dynamic> json) => _$BatchExtractionResponseFromJson(json);

@override@JsonKey(name: 'job_id') final  String jobId;
@override final  String status;
@override@JsonKey(name: 'total_images') final  int totalImages;
@override final  String? message;

/// Create a copy of BatchExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchExtractionResponseCopyWith<_BatchExtractionResponse> get copyWith => __$BatchExtractionResponseCopyWithImpl<_BatchExtractionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchExtractionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchExtractionResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,message);

@override
String toString() {
  return 'BatchExtractionResponse(jobId: $jobId, status: $status, totalImages: $totalImages, message: $message)';
}


}

/// @nodoc
abstract mixin class _$BatchExtractionResponseCopyWith<$Res> implements $BatchExtractionResponseCopyWith<$Res> {
  factory _$BatchExtractionResponseCopyWith(_BatchExtractionResponse value, $Res Function(_BatchExtractionResponse) _then) = __$BatchExtractionResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'total_images') int totalImages, String? message
});




}
/// @nodoc
class __$BatchExtractionResponseCopyWithImpl<$Res>
    implements _$BatchExtractionResponseCopyWith<$Res> {
  __$BatchExtractionResponseCopyWithImpl(this._self, this._then);

  final _BatchExtractionResponse _self;
  final $Res Function(_BatchExtractionResponse) _then;

/// Create a copy of BatchExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? message = freezed,}) {
  return _then(_BatchExtractionResponse(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BatchJobStatusResponse {

@JsonKey(name: 'job_id') String get jobId; String get status;@JsonKey(name: 'total_images') int get totalImages;@JsonKey(name: 'extractions_completed') int get extractedCount;@JsonKey(name: 'generations_completed') int get generatedCount;@JsonKey(name: 'extractions_failed') int get failedCount;@JsonKey(name: 'generations_failed') int get generationFailedCount;@JsonKey(name: 'current_batch') int get currentBatch;@JsonKey(name: 'total_batches') int get totalBatches; List<BatchImageResult>? get images;@JsonKey(name: 'items') List<BatchExtractedItem>? get detectedItems; String? get error;
/// Create a copy of BatchJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchJobStatusResponseCopyWith<BatchJobStatusResponse> get copyWith => _$BatchJobStatusResponseCopyWithImpl<BatchJobStatusResponse>(this as BatchJobStatusResponse, _$identity);

  /// Serializes this BatchJobStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchJobStatusResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.extractedCount, extractedCount) || other.extractedCount == extractedCount)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.generationFailedCount, generationFailedCount) || other.generationFailedCount == generationFailedCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.detectedItems, detectedItems)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,extractedCount,generatedCount,failedCount,generationFailedCount,currentBatch,totalBatches,const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(detectedItems),error);

@override
String toString() {
  return 'BatchJobStatusResponse(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, generationFailedCount: $generationFailedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, images: $images, detectedItems: $detectedItems, error: $error)';
}


}

/// @nodoc
abstract mixin class $BatchJobStatusResponseCopyWith<$Res>  {
  factory $BatchJobStatusResponseCopyWith(BatchJobStatusResponse value, $Res Function(BatchJobStatusResponse) _then) = _$BatchJobStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'total_images') int totalImages,@JsonKey(name: 'extractions_completed') int extractedCount,@JsonKey(name: 'generations_completed') int generatedCount,@JsonKey(name: 'extractions_failed') int failedCount,@JsonKey(name: 'generations_failed') int generationFailedCount,@JsonKey(name: 'current_batch') int currentBatch,@JsonKey(name: 'total_batches') int totalBatches, List<BatchImageResult>? images,@JsonKey(name: 'items') List<BatchExtractedItem>? detectedItems, String? error
});




}
/// @nodoc
class _$BatchJobStatusResponseCopyWithImpl<$Res>
    implements $BatchJobStatusResponseCopyWith<$Res> {
  _$BatchJobStatusResponseCopyWithImpl(this._self, this._then);

  final BatchJobStatusResponse _self;
  final $Res Function(BatchJobStatusResponse) _then;

/// Create a copy of BatchJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? extractedCount = null,Object? generatedCount = null,Object? failedCount = null,Object? generationFailedCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? images = freezed,Object? detectedItems = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,extractedCount: null == extractedCount ? _self.extractedCount : extractedCount // ignore: cast_nullable_to_non_nullable
as int,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,generationFailedCount: null == generationFailedCount ? _self.generationFailedCount : generationFailedCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<BatchImageResult>?,detectedItems: freezed == detectedItems ? _self.detectedItems : detectedItems // ignore: cast_nullable_to_non_nullable
as List<BatchExtractedItem>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchJobStatusResponse].
extension BatchJobStatusResponsePatterns on BatchJobStatusResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchJobStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchJobStatusResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchJobStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _BatchJobStatusResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchJobStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BatchJobStatusResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages, @JsonKey(name: 'extractions_completed')  int extractedCount, @JsonKey(name: 'generations_completed')  int generatedCount, @JsonKey(name: 'extractions_failed')  int failedCount, @JsonKey(name: 'generations_failed')  int generationFailedCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<BatchImageResult>? images, @JsonKey(name: 'items')  List<BatchExtractedItem>? detectedItems,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchJobStatusResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.generationFailedCount,_that.currentBatch,_that.totalBatches,_that.images,_that.detectedItems,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages, @JsonKey(name: 'extractions_completed')  int extractedCount, @JsonKey(name: 'generations_completed')  int generatedCount, @JsonKey(name: 'extractions_failed')  int failedCount, @JsonKey(name: 'generations_failed')  int generationFailedCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<BatchImageResult>? images, @JsonKey(name: 'items')  List<BatchExtractedItem>? detectedItems,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BatchJobStatusResponse():
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.generationFailedCount,_that.currentBatch,_that.totalBatches,_that.images,_that.detectedItems,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'total_images')  int totalImages, @JsonKey(name: 'extractions_completed')  int extractedCount, @JsonKey(name: 'generations_completed')  int generatedCount, @JsonKey(name: 'extractions_failed')  int failedCount, @JsonKey(name: 'generations_failed')  int generationFailedCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<BatchImageResult>? images, @JsonKey(name: 'items')  List<BatchExtractedItem>? detectedItems,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BatchJobStatusResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.totalImages,_that.extractedCount,_that.generatedCount,_that.failedCount,_that.generationFailedCount,_that.currentBatch,_that.totalBatches,_that.images,_that.detectedItems,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchJobStatusResponse implements BatchJobStatusResponse {
  const _BatchJobStatusResponse({@JsonKey(name: 'job_id') required this.jobId, required this.status, @JsonKey(name: 'total_images') required this.totalImages, @JsonKey(name: 'extractions_completed') this.extractedCount = 0, @JsonKey(name: 'generations_completed') this.generatedCount = 0, @JsonKey(name: 'extractions_failed') this.failedCount = 0, @JsonKey(name: 'generations_failed') this.generationFailedCount = 0, @JsonKey(name: 'current_batch') this.currentBatch = 0, @JsonKey(name: 'total_batches') this.totalBatches = 0, final  List<BatchImageResult>? images, @JsonKey(name: 'items') final  List<BatchExtractedItem>? detectedItems, this.error}): _images = images,_detectedItems = detectedItems;
  factory _BatchJobStatusResponse.fromJson(Map<String, dynamic> json) => _$BatchJobStatusResponseFromJson(json);

@override@JsonKey(name: 'job_id') final  String jobId;
@override final  String status;
@override@JsonKey(name: 'total_images') final  int totalImages;
@override@JsonKey(name: 'extractions_completed') final  int extractedCount;
@override@JsonKey(name: 'generations_completed') final  int generatedCount;
@override@JsonKey(name: 'extractions_failed') final  int failedCount;
@override@JsonKey(name: 'generations_failed') final  int generationFailedCount;
@override@JsonKey(name: 'current_batch') final  int currentBatch;
@override@JsonKey(name: 'total_batches') final  int totalBatches;
 final  List<BatchImageResult>? _images;
@override List<BatchImageResult>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<BatchExtractedItem>? _detectedItems;
@override@JsonKey(name: 'items') List<BatchExtractedItem>? get detectedItems {
  final value = _detectedItems;
  if (value == null) return null;
  if (_detectedItems is EqualUnmodifiableListView) return _detectedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? error;

/// Create a copy of BatchJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchJobStatusResponseCopyWith<_BatchJobStatusResponse> get copyWith => __$BatchJobStatusResponseCopyWithImpl<_BatchJobStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchJobStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchJobStatusResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalImages, totalImages) || other.totalImages == totalImages)&&(identical(other.extractedCount, extractedCount) || other.extractedCount == extractedCount)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.generationFailedCount, generationFailedCount) || other.generationFailedCount == generationFailedCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._detectedItems, _detectedItems)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,totalImages,extractedCount,generatedCount,failedCount,generationFailedCount,currentBatch,totalBatches,const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_detectedItems),error);

@override
String toString() {
  return 'BatchJobStatusResponse(jobId: $jobId, status: $status, totalImages: $totalImages, extractedCount: $extractedCount, generatedCount: $generatedCount, failedCount: $failedCount, generationFailedCount: $generationFailedCount, currentBatch: $currentBatch, totalBatches: $totalBatches, images: $images, detectedItems: $detectedItems, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BatchJobStatusResponseCopyWith<$Res> implements $BatchJobStatusResponseCopyWith<$Res> {
  factory _$BatchJobStatusResponseCopyWith(_BatchJobStatusResponse value, $Res Function(_BatchJobStatusResponse) _then) = __$BatchJobStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'total_images') int totalImages,@JsonKey(name: 'extractions_completed') int extractedCount,@JsonKey(name: 'generations_completed') int generatedCount,@JsonKey(name: 'extractions_failed') int failedCount,@JsonKey(name: 'generations_failed') int generationFailedCount,@JsonKey(name: 'current_batch') int currentBatch,@JsonKey(name: 'total_batches') int totalBatches, List<BatchImageResult>? images,@JsonKey(name: 'items') List<BatchExtractedItem>? detectedItems, String? error
});




}
/// @nodoc
class __$BatchJobStatusResponseCopyWithImpl<$Res>
    implements _$BatchJobStatusResponseCopyWith<$Res> {
  __$BatchJobStatusResponseCopyWithImpl(this._self, this._then);

  final _BatchJobStatusResponse _self;
  final $Res Function(_BatchJobStatusResponse) _then;

/// Create a copy of BatchJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? totalImages = null,Object? extractedCount = null,Object? generatedCount = null,Object? failedCount = null,Object? generationFailedCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? images = freezed,Object? detectedItems = freezed,Object? error = freezed,}) {
  return _then(_BatchJobStatusResponse(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalImages: null == totalImages ? _self.totalImages : totalImages // ignore: cast_nullable_to_non_nullable
as int,extractedCount: null == extractedCount ? _self.extractedCount : extractedCount // ignore: cast_nullable_to_non_nullable
as int,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,generationFailedCount: null == generationFailedCount ? _self.generationFailedCount : generationFailedCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<BatchImageResult>?,detectedItems: freezed == detectedItems ? _self._detectedItems : detectedItems // ignore: cast_nullable_to_non_nullable
as List<BatchExtractedItem>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BatchImageResult {

@JsonKey(name: 'image_id') String get id; String get status;@JsonKey(name: 'item_count') int get itemCount; String? get error;
/// Create a copy of BatchImageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchImageResultCopyWith<BatchImageResult> get copyWith => _$BatchImageResultCopyWithImpl<BatchImageResult>(this as BatchImageResult, _$identity);

  /// Serializes this BatchImageResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchImageResult&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,itemCount,error);

@override
String toString() {
  return 'BatchImageResult(id: $id, status: $status, itemCount: $itemCount, error: $error)';
}


}

/// @nodoc
abstract mixin class $BatchImageResultCopyWith<$Res>  {
  factory $BatchImageResultCopyWith(BatchImageResult value, $Res Function(BatchImageResult) _then) = _$BatchImageResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_id') String id, String status,@JsonKey(name: 'item_count') int itemCount, String? error
});




}
/// @nodoc
class _$BatchImageResultCopyWithImpl<$Res>
    implements $BatchImageResultCopyWith<$Res> {
  _$BatchImageResultCopyWithImpl(this._self, this._then);

  final BatchImageResult _self;
  final $Res Function(BatchImageResult) _then;

/// Create a copy of BatchImageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? itemCount = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchImageResult].
extension BatchImageResultPatterns on BatchImageResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchImageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchImageResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchImageResult value)  $default,){
final _that = this;
switch (_that) {
case _BatchImageResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchImageResult value)?  $default,){
final _that = this;
switch (_that) {
case _BatchImageResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_id')  String id,  String status, @JsonKey(name: 'item_count')  int itemCount,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchImageResult() when $default != null:
return $default(_that.id,_that.status,_that.itemCount,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_id')  String id,  String status, @JsonKey(name: 'item_count')  int itemCount,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BatchImageResult():
return $default(_that.id,_that.status,_that.itemCount,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'image_id')  String id,  String status, @JsonKey(name: 'item_count')  int itemCount,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BatchImageResult() when $default != null:
return $default(_that.id,_that.status,_that.itemCount,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchImageResult implements BatchImageResult {
  const _BatchImageResult({@JsonKey(name: 'image_id') required this.id, required this.status, @JsonKey(name: 'item_count') this.itemCount = 0, this.error});
  factory _BatchImageResult.fromJson(Map<String, dynamic> json) => _$BatchImageResultFromJson(json);

@override@JsonKey(name: 'image_id') final  String id;
@override final  String status;
@override@JsonKey(name: 'item_count') final  int itemCount;
@override final  String? error;

/// Create a copy of BatchImageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchImageResultCopyWith<_BatchImageResult> get copyWith => __$BatchImageResultCopyWithImpl<_BatchImageResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchImageResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchImageResult&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,itemCount,error);

@override
String toString() {
  return 'BatchImageResult(id: $id, status: $status, itemCount: $itemCount, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BatchImageResultCopyWith<$Res> implements $BatchImageResultCopyWith<$Res> {
  factory _$BatchImageResultCopyWith(_BatchImageResult value, $Res Function(_BatchImageResult) _then) = __$BatchImageResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'image_id') String id, String status,@JsonKey(name: 'item_count') int itemCount, String? error
});




}
/// @nodoc
class __$BatchImageResultCopyWithImpl<$Res>
    implements _$BatchImageResultCopyWith<$Res> {
  __$BatchImageResultCopyWithImpl(this._self, this._then);

  final _BatchImageResult _self;
  final $Res Function(_BatchImageResult) _then;

/// Create a copy of BatchImageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? itemCount = null,Object? error = freezed,}) {
  return _then(_BatchImageResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
