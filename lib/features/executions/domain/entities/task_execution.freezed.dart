// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_execution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskExecution {

 String get id; String get companyId; String get taskId; String get employeeId; ExecutionStatus get status; DateTime? get startedAt; DateTime? get finishedAt; String? get observation; List<ExecutionItem> get items; List<ExecutionPhoto> get photos; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of TaskExecution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskExecutionCopyWith<TaskExecution> get copyWith => _$TaskExecutionCopyWithImpl<TaskExecution>(this as TaskExecution, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskExecution&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.observation, observation) || other.observation == observation)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,taskId,employeeId,status,startedAt,finishedAt,observation,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(photos),createdAt,updatedAt);

@override
String toString() {
  return 'TaskExecution(id: $id, companyId: $companyId, taskId: $taskId, employeeId: $employeeId, status: $status, startedAt: $startedAt, finishedAt: $finishedAt, observation: $observation, items: $items, photos: $photos, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskExecutionCopyWith<$Res>  {
  factory $TaskExecutionCopyWith(TaskExecution value, $Res Function(TaskExecution) _then) = _$TaskExecutionCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String taskId, String employeeId, ExecutionStatus status, DateTime? startedAt, DateTime? finishedAt, String? observation, List<ExecutionItem> items, List<ExecutionPhoto> photos, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TaskExecutionCopyWithImpl<$Res>
    implements $TaskExecutionCopyWith<$Res> {
  _$TaskExecutionCopyWithImpl(this._self, this._then);

  final TaskExecution _self;
  final $Res Function(TaskExecution) _then;

/// Create a copy of TaskExecution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? taskId = null,Object? employeeId = null,Object? status = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? observation = freezed,Object? items = null,Object? photos = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExecutionStatus,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,observation: freezed == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ExecutionItem>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<ExecutionPhoto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskExecution].
extension TaskExecutionPatterns on TaskExecution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskExecution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskExecution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskExecution value)  $default,){
final _that = this;
switch (_that) {
case _TaskExecution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskExecution value)?  $default,){
final _that = this;
switch (_that) {
case _TaskExecution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String taskId,  String employeeId,  ExecutionStatus status,  DateTime? startedAt,  DateTime? finishedAt,  String? observation,  List<ExecutionItem> items,  List<ExecutionPhoto> photos,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskExecution() when $default != null:
return $default(_that.id,_that.companyId,_that.taskId,_that.employeeId,_that.status,_that.startedAt,_that.finishedAt,_that.observation,_that.items,_that.photos,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String taskId,  String employeeId,  ExecutionStatus status,  DateTime? startedAt,  DateTime? finishedAt,  String? observation,  List<ExecutionItem> items,  List<ExecutionPhoto> photos,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaskExecution():
return $default(_that.id,_that.companyId,_that.taskId,_that.employeeId,_that.status,_that.startedAt,_that.finishedAt,_that.observation,_that.items,_that.photos,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String taskId,  String employeeId,  ExecutionStatus status,  DateTime? startedAt,  DateTime? finishedAt,  String? observation,  List<ExecutionItem> items,  List<ExecutionPhoto> photos,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskExecution() when $default != null:
return $default(_that.id,_that.companyId,_that.taskId,_that.employeeId,_that.status,_that.startedAt,_that.finishedAt,_that.observation,_that.items,_that.photos,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TaskExecution extends TaskExecution {
  const _TaskExecution({required this.id, required this.companyId, required this.taskId, required this.employeeId, this.status = ExecutionStatus.notStarted, this.startedAt, this.finishedAt, this.observation, final  List<ExecutionItem> items = const <ExecutionItem>[], final  List<ExecutionPhoto> photos = const <ExecutionPhoto>[], required this.createdAt, required this.updatedAt}): _items = items,_photos = photos,super._();
  

@override final  String id;
@override final  String companyId;
@override final  String taskId;
@override final  String employeeId;
@override@JsonKey() final  ExecutionStatus status;
@override final  DateTime? startedAt;
@override final  DateTime? finishedAt;
@override final  String? observation;
 final  List<ExecutionItem> _items;
@override@JsonKey() List<ExecutionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<ExecutionPhoto> _photos;
@override@JsonKey() List<ExecutionPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of TaskExecution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskExecutionCopyWith<_TaskExecution> get copyWith => __$TaskExecutionCopyWithImpl<_TaskExecution>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskExecution&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.observation, observation) || other.observation == observation)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,taskId,employeeId,status,startedAt,finishedAt,observation,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_photos),createdAt,updatedAt);

@override
String toString() {
  return 'TaskExecution(id: $id, companyId: $companyId, taskId: $taskId, employeeId: $employeeId, status: $status, startedAt: $startedAt, finishedAt: $finishedAt, observation: $observation, items: $items, photos: $photos, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskExecutionCopyWith<$Res> implements $TaskExecutionCopyWith<$Res> {
  factory _$TaskExecutionCopyWith(_TaskExecution value, $Res Function(_TaskExecution) _then) = __$TaskExecutionCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String taskId, String employeeId, ExecutionStatus status, DateTime? startedAt, DateTime? finishedAt, String? observation, List<ExecutionItem> items, List<ExecutionPhoto> photos, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TaskExecutionCopyWithImpl<$Res>
    implements _$TaskExecutionCopyWith<$Res> {
  __$TaskExecutionCopyWithImpl(this._self, this._then);

  final _TaskExecution _self;
  final $Res Function(_TaskExecution) _then;

/// Create a copy of TaskExecution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? taskId = null,Object? employeeId = null,Object? status = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? observation = freezed,Object? items = null,Object? photos = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TaskExecution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExecutionStatus,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,observation: freezed == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ExecutionItem>,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<ExecutionPhoto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
