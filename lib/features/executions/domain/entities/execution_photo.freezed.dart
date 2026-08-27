// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'execution_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExecutionPhoto {

 String get id; String get companyId; String get taskExecutionId; String get storagePath; String? get downloadUrl;/// Caminho de um arquivo local ainda não enviado (suporte a modo offline).
 String? get localPath; DateTime get createdAt; String? get createdBy;
/// Create a copy of ExecutionPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionPhotoCopyWith<ExecutionPhoto> get copyWith => _$ExecutionPhotoCopyWithImpl<ExecutionPhoto>(this as ExecutionPhoto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.taskExecutionId, taskExecutionId) || other.taskExecutionId == taskExecutionId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,taskExecutionId,storagePath,downloadUrl,localPath,createdAt,createdBy);

@override
String toString() {
  return 'ExecutionPhoto(id: $id, companyId: $companyId, taskExecutionId: $taskExecutionId, storagePath: $storagePath, downloadUrl: $downloadUrl, localPath: $localPath, createdAt: $createdAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $ExecutionPhotoCopyWith<$Res>  {
  factory $ExecutionPhotoCopyWith(ExecutionPhoto value, $Res Function(ExecutionPhoto) _then) = _$ExecutionPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String taskExecutionId, String storagePath, String? downloadUrl, String? localPath, DateTime createdAt, String? createdBy
});




}
/// @nodoc
class _$ExecutionPhotoCopyWithImpl<$Res>
    implements $ExecutionPhotoCopyWith<$Res> {
  _$ExecutionPhotoCopyWithImpl(this._self, this._then);

  final ExecutionPhoto _self;
  final $Res Function(ExecutionPhoto) _then;

/// Create a copy of ExecutionPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? taskExecutionId = null,Object? storagePath = null,Object? downloadUrl = freezed,Object? localPath = freezed,Object? createdAt = null,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,taskExecutionId: null == taskExecutionId ? _self.taskExecutionId : taskExecutionId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExecutionPhoto].
extension ExecutionPhotoPatterns on ExecutionPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String taskExecutionId,  String storagePath,  String? downloadUrl,  String? localPath,  DateTime createdAt,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionPhoto() when $default != null:
return $default(_that.id,_that.companyId,_that.taskExecutionId,_that.storagePath,_that.downloadUrl,_that.localPath,_that.createdAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String taskExecutionId,  String storagePath,  String? downloadUrl,  String? localPath,  DateTime createdAt,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _ExecutionPhoto():
return $default(_that.id,_that.companyId,_that.taskExecutionId,_that.storagePath,_that.downloadUrl,_that.localPath,_that.createdAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String taskExecutionId,  String storagePath,  String? downloadUrl,  String? localPath,  DateTime createdAt,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionPhoto() when $default != null:
return $default(_that.id,_that.companyId,_that.taskExecutionId,_that.storagePath,_that.downloadUrl,_that.localPath,_that.createdAt,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc


class _ExecutionPhoto implements ExecutionPhoto {
  const _ExecutionPhoto({required this.id, required this.companyId, required this.taskExecutionId, required this.storagePath, this.downloadUrl, this.localPath, required this.createdAt, this.createdBy});
  

@override final  String id;
@override final  String companyId;
@override final  String taskExecutionId;
@override final  String storagePath;
@override final  String? downloadUrl;
/// Caminho de um arquivo local ainda não enviado (suporte a modo offline).
@override final  String? localPath;
@override final  DateTime createdAt;
@override final  String? createdBy;

/// Create a copy of ExecutionPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionPhotoCopyWith<_ExecutionPhoto> get copyWith => __$ExecutionPhotoCopyWithImpl<_ExecutionPhoto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.taskExecutionId, taskExecutionId) || other.taskExecutionId == taskExecutionId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,taskExecutionId,storagePath,downloadUrl,localPath,createdAt,createdBy);

@override
String toString() {
  return 'ExecutionPhoto(id: $id, companyId: $companyId, taskExecutionId: $taskExecutionId, storagePath: $storagePath, downloadUrl: $downloadUrl, localPath: $localPath, createdAt: $createdAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$ExecutionPhotoCopyWith<$Res> implements $ExecutionPhotoCopyWith<$Res> {
  factory _$ExecutionPhotoCopyWith(_ExecutionPhoto value, $Res Function(_ExecutionPhoto) _then) = __$ExecutionPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String taskExecutionId, String storagePath, String? downloadUrl, String? localPath, DateTime createdAt, String? createdBy
});




}
/// @nodoc
class __$ExecutionPhotoCopyWithImpl<$Res>
    implements _$ExecutionPhotoCopyWith<$Res> {
  __$ExecutionPhotoCopyWithImpl(this._self, this._then);

  final _ExecutionPhoto _self;
  final $Res Function(_ExecutionPhoto) _then;

/// Create a copy of ExecutionPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? taskExecutionId = null,Object? storagePath = null,Object? downloadUrl = freezed,Object? localPath = freezed,Object? createdAt = null,Object? createdBy = freezed,}) {
  return _then(_ExecutionPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,taskExecutionId: null == taskExecutionId ? _self.taskExecutionId : taskExecutionId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
