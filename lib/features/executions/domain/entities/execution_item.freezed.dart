// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'execution_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExecutionItem {

 String get id; String get checklistItemId; bool get completed; DateTime? get completedAt; String? get completedBy;
/// Create a copy of ExecutionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionItemCopyWith<ExecutionItem> get copyWith => _$ExecutionItemCopyWithImpl<ExecutionItem>(this as ExecutionItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.checklistItemId, checklistItemId) || other.checklistItemId == checklistItemId)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,checklistItemId,completed,completedAt,completedBy);

@override
String toString() {
  return 'ExecutionItem(id: $id, checklistItemId: $checklistItemId, completed: $completed, completedAt: $completedAt, completedBy: $completedBy)';
}


}

/// @nodoc
abstract mixin class $ExecutionItemCopyWith<$Res>  {
  factory $ExecutionItemCopyWith(ExecutionItem value, $Res Function(ExecutionItem) _then) = _$ExecutionItemCopyWithImpl;
@useResult
$Res call({
 String id, String checklistItemId, bool completed, DateTime? completedAt, String? completedBy
});




}
/// @nodoc
class _$ExecutionItemCopyWithImpl<$Res>
    implements $ExecutionItemCopyWith<$Res> {
  _$ExecutionItemCopyWithImpl(this._self, this._then);

  final ExecutionItem _self;
  final $Res Function(ExecutionItem) _then;

/// Create a copy of ExecutionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? checklistItemId = null,Object? completed = null,Object? completedAt = freezed,Object? completedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,checklistItemId: null == checklistItemId ? _self.checklistItemId : checklistItemId // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExecutionItem].
extension ExecutionItemPatterns on ExecutionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionItem value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionItem value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String checklistItemId,  bool completed,  DateTime? completedAt,  String? completedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionItem() when $default != null:
return $default(_that.id,_that.checklistItemId,_that.completed,_that.completedAt,_that.completedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String checklistItemId,  bool completed,  DateTime? completedAt,  String? completedBy)  $default,) {final _that = this;
switch (_that) {
case _ExecutionItem():
return $default(_that.id,_that.checklistItemId,_that.completed,_that.completedAt,_that.completedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String checklistItemId,  bool completed,  DateTime? completedAt,  String? completedBy)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionItem() when $default != null:
return $default(_that.id,_that.checklistItemId,_that.completed,_that.completedAt,_that.completedBy);case _:
  return null;

}
}

}

/// @nodoc


class _ExecutionItem implements ExecutionItem {
  const _ExecutionItem({required this.id, required this.checklistItemId, this.completed = false, this.completedAt, this.completedBy});
  

@override final  String id;
@override final  String checklistItemId;
@override@JsonKey() final  bool completed;
@override final  DateTime? completedAt;
@override final  String? completedBy;

/// Create a copy of ExecutionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionItemCopyWith<_ExecutionItem> get copyWith => __$ExecutionItemCopyWithImpl<_ExecutionItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.checklistItemId, checklistItemId) || other.checklistItemId == checklistItemId)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,checklistItemId,completed,completedAt,completedBy);

@override
String toString() {
  return 'ExecutionItem(id: $id, checklistItemId: $checklistItemId, completed: $completed, completedAt: $completedAt, completedBy: $completedBy)';
}


}

/// @nodoc
abstract mixin class _$ExecutionItemCopyWith<$Res> implements $ExecutionItemCopyWith<$Res> {
  factory _$ExecutionItemCopyWith(_ExecutionItem value, $Res Function(_ExecutionItem) _then) = __$ExecutionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String checklistItemId, bool completed, DateTime? completedAt, String? completedBy
});




}
/// @nodoc
class __$ExecutionItemCopyWithImpl<$Res>
    implements _$ExecutionItemCopyWith<$Res> {
  __$ExecutionItemCopyWithImpl(this._self, this._then);

  final _ExecutionItem _self;
  final $Res Function(_ExecutionItem) _then;

/// Create a copy of ExecutionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? checklistItemId = null,Object? completed = null,Object? completedAt = freezed,Object? completedBy = freezed,}) {
  return _then(_ExecutionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,checklistItemId: null == checklistItemId ? _self.checklistItemId : checklistItemId // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
