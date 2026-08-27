// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Contract {

 String get id; String get companyId; String get clientId; String get name; String? get description; DateTime? get startDate; DateTime? get endDate; ContractStatus get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractCopyWith<Contract> get copyWith => _$ContractCopyWithImpl<Contract>(this as Contract, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contract&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,name,description,startDate,endDate,status,createdAt,updatedAt);

@override
String toString() {
  return 'Contract(id: $id, companyId: $companyId, clientId: $clientId, name: $name, description: $description, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ContractCopyWith<$Res>  {
  factory $ContractCopyWith(Contract value, $Res Function(Contract) _then) = _$ContractCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String clientId, String name, String? description, DateTime? startDate, DateTime? endDate, ContractStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ContractCopyWithImpl<$Res>
    implements $ContractCopyWith<$Res> {
  _$ContractCopyWithImpl(this._self, this._then);

  final Contract _self;
  final $Res Function(Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? name = null,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Contract].
extension ContractPatterns on Contract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contract value)  $default,){
final _that = this;
switch (_that) {
case _Contract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contract value)?  $default,){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String name,  String? description,  DateTime? startDate,  DateTime? endDate,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.name,_that.description,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String name,  String? description,  DateTime? startDate,  DateTime? endDate,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Contract():
return $default(_that.id,_that.companyId,_that.clientId,_that.name,_that.description,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String clientId,  String name,  String? description,  DateTime? startDate,  DateTime? endDate,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.name,_that.description,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Contract implements Contract {
  const _Contract({required this.id, required this.companyId, required this.clientId, required this.name, this.description, this.startDate, this.endDate, this.status = ContractStatus.active, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String clientId;
@override final  String name;
@override final  String? description;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  ContractStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractCopyWith<_Contract> get copyWith => __$ContractCopyWithImpl<_Contract>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contract&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,name,description,startDate,endDate,status,createdAt,updatedAt);

@override
String toString() {
  return 'Contract(id: $id, companyId: $companyId, clientId: $clientId, name: $name, description: $description, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ContractCopyWith<$Res> implements $ContractCopyWith<$Res> {
  factory _$ContractCopyWith(_Contract value, $Res Function(_Contract) _then) = __$ContractCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String clientId, String name, String? description, DateTime? startDate, DateTime? endDate, ContractStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ContractCopyWithImpl<$Res>
    implements _$ContractCopyWith<$Res> {
  __$ContractCopyWithImpl(this._self, this._then);

  final _Contract _self;
  final $Res Function(_Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? name = null,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Contract(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
