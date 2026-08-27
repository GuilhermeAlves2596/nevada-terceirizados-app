// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Task {

 String get id; String get companyId; String get clientId; String get contractId; String get locationId; String get checklistId;/// `userId` do funcionário responsável.
 String get assignedTo;/// `userId` do supervisor que atribuiu.
 String get assignedBy; DateTime get scheduledDate; String? get scheduledStartTime; TaskPriority get priority; TaskStatus get status;/// Progresso (0–100) espelhado da execução, para exibição em listas sem
/// precisar carregar a execução inteira.
 int get progress; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.checklistId, checklistId) || other.checklistId == checklistId)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledStartTime, scheduledStartTime) || other.scheduledStartTime == scheduledStartTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,contractId,locationId,checklistId,assignedTo,assignedBy,scheduledDate,scheduledStartTime,priority,status,progress,createdAt,updatedAt);

@override
String toString() {
  return 'Task(id: $id, companyId: $companyId, clientId: $clientId, contractId: $contractId, locationId: $locationId, checklistId: $checklistId, assignedTo: $assignedTo, assignedBy: $assignedBy, scheduledDate: $scheduledDate, scheduledStartTime: $scheduledStartTime, priority: $priority, status: $status, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String clientId, String contractId, String locationId, String checklistId, String assignedTo, String assignedBy, DateTime scheduledDate, String? scheduledStartTime, TaskPriority priority, TaskStatus status, int progress, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? contractId = null,Object? locationId = null,Object? checklistId = null,Object? assignedTo = null,Object? assignedBy = null,Object? scheduledDate = null,Object? scheduledStartTime = freezed,Object? priority = null,Object? status = null,Object? progress = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,checklistId: null == checklistId ? _self.checklistId : checklistId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: null == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String,assignedBy: null == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledStartTime: freezed == scheduledStartTime ? _self.scheduledStartTime : scheduledStartTime // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String contractId,  String locationId,  String checklistId,  String assignedTo,  String assignedBy,  DateTime scheduledDate,  String? scheduledStartTime,  TaskPriority priority,  TaskStatus status,  int progress,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.locationId,_that.checklistId,_that.assignedTo,_that.assignedBy,_that.scheduledDate,_that.scheduledStartTime,_that.priority,_that.status,_that.progress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String contractId,  String locationId,  String checklistId,  String assignedTo,  String assignedBy,  DateTime scheduledDate,  String? scheduledStartTime,  TaskPriority priority,  TaskStatus status,  int progress,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.locationId,_that.checklistId,_that.assignedTo,_that.assignedBy,_that.scheduledDate,_that.scheduledStartTime,_that.priority,_that.status,_that.progress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String clientId,  String contractId,  String locationId,  String checklistId,  String assignedTo,  String assignedBy,  DateTime scheduledDate,  String? scheduledStartTime,  TaskPriority priority,  TaskStatus status,  int progress,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.locationId,_that.checklistId,_that.assignedTo,_that.assignedBy,_that.scheduledDate,_that.scheduledStartTime,_that.priority,_that.status,_that.progress,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Task extends Task {
  const _Task({required this.id, required this.companyId, required this.clientId, required this.contractId, required this.locationId, required this.checklistId, required this.assignedTo, required this.assignedBy, required this.scheduledDate, this.scheduledStartTime, this.priority = TaskPriority.normal, this.status = TaskStatus.pending, this.progress = 0, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String companyId;
@override final  String clientId;
@override final  String contractId;
@override final  String locationId;
@override final  String checklistId;
/// `userId` do funcionário responsável.
@override final  String assignedTo;
/// `userId` do supervisor que atribuiu.
@override final  String assignedBy;
@override final  DateTime scheduledDate;
@override final  String? scheduledStartTime;
@override@JsonKey() final  TaskPriority priority;
@override@JsonKey() final  TaskStatus status;
/// Progresso (0–100) espelhado da execução, para exibição em listas sem
/// precisar carregar a execução inteira.
@override@JsonKey() final  int progress;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.checklistId, checklistId) || other.checklistId == checklistId)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledStartTime, scheduledStartTime) || other.scheduledStartTime == scheduledStartTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,contractId,locationId,checklistId,assignedTo,assignedBy,scheduledDate,scheduledStartTime,priority,status,progress,createdAt,updatedAt);

@override
String toString() {
  return 'Task(id: $id, companyId: $companyId, clientId: $clientId, contractId: $contractId, locationId: $locationId, checklistId: $checklistId, assignedTo: $assignedTo, assignedBy: $assignedBy, scheduledDate: $scheduledDate, scheduledStartTime: $scheduledStartTime, priority: $priority, status: $status, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String clientId, String contractId, String locationId, String checklistId, String assignedTo, String assignedBy, DateTime scheduledDate, String? scheduledStartTime, TaskPriority priority, TaskStatus status, int progress, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? contractId = null,Object? locationId = null,Object? checklistId = null,Object? assignedTo = null,Object? assignedBy = null,Object? scheduledDate = null,Object? scheduledStartTime = freezed,Object? priority = null,Object? status = null,Object? progress = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,checklistId: null == checklistId ? _self.checklistId : checklistId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: null == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String,assignedBy: null == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledStartTime: freezed == scheduledStartTime ? _self.scheduledStartTime : scheduledStartTime // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
