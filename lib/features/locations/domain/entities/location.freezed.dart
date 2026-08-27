// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Location {

 String get id; String get companyId; String get clientId; String get contractId; String get name; String? get description; String? get address; String? get parentLocationId;/// Identificador opaco embutido no QR Code físico do ambiente (seção 19).
 String? get qrCodeId; bool get active; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this as Location, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.parentLocationId, parentLocationId) || other.parentLocationId == parentLocationId)&&(identical(other.qrCodeId, qrCodeId) || other.qrCodeId == qrCodeId)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,contractId,name,description,address,parentLocationId,qrCodeId,active,createdAt,updatedAt);

@override
String toString() {
  return 'Location(id: $id, companyId: $companyId, clientId: $clientId, contractId: $contractId, name: $name, description: $description, address: $address, parentLocationId: $parentLocationId, qrCodeId: $qrCodeId, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res>  {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String clientId, String contractId, String name, String? description, String? address, String? parentLocationId, String? qrCodeId, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? contractId = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? parentLocationId = freezed,Object? qrCodeId = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,parentLocationId: freezed == parentLocationId ? _self.parentLocationId : parentLocationId // ignore: cast_nullable_to_non_nullable
as String?,qrCodeId: freezed == qrCodeId ? _self.qrCodeId : qrCodeId // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Location].
extension LocationPatterns on Location {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Location value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Location value)  $default,){
final _that = this;
switch (_that) {
case _Location():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Location value)?  $default,){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String contractId,  String name,  String? description,  String? address,  String? parentLocationId,  String? qrCodeId,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.name,_that.description,_that.address,_that.parentLocationId,_that.qrCodeId,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String clientId,  String contractId,  String name,  String? description,  String? address,  String? parentLocationId,  String? qrCodeId,  bool active,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Location():
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.name,_that.description,_that.address,_that.parentLocationId,_that.qrCodeId,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String clientId,  String contractId,  String name,  String? description,  String? address,  String? parentLocationId,  String? qrCodeId,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.companyId,_that.clientId,_that.contractId,_that.name,_that.description,_that.address,_that.parentLocationId,_that.qrCodeId,_that.active,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Location implements Location {
  const _Location({required this.id, required this.companyId, required this.clientId, required this.contractId, required this.name, this.description, this.address, this.parentLocationId, this.qrCodeId, this.active = true, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String clientId;
@override final  String contractId;
@override final  String name;
@override final  String? description;
@override final  String? address;
@override final  String? parentLocationId;
/// Identificador opaco embutido no QR Code físico do ambiente (seção 19).
@override final  String? qrCodeId;
@override@JsonKey() final  bool active;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCopyWith<_Location> get copyWith => __$LocationCopyWithImpl<_Location>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.parentLocationId, parentLocationId) || other.parentLocationId == parentLocationId)&&(identical(other.qrCodeId, qrCodeId) || other.qrCodeId == qrCodeId)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,clientId,contractId,name,description,address,parentLocationId,qrCodeId,active,createdAt,updatedAt);

@override
String toString() {
  return 'Location(id: $id, companyId: $companyId, clientId: $clientId, contractId: $contractId, name: $name, description: $description, address: $address, parentLocationId: $parentLocationId, qrCodeId: $qrCodeId, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LocationCopyWith<$Res> implements $LocationCopyWith<$Res> {
  factory _$LocationCopyWith(_Location value, $Res Function(_Location) _then) = __$LocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String clientId, String contractId, String name, String? description, String? address, String? parentLocationId, String? qrCodeId, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$LocationCopyWithImpl<$Res>
    implements _$LocationCopyWith<$Res> {
  __$LocationCopyWithImpl(this._self, this._then);

  final _Location _self;
  final $Res Function(_Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? clientId = null,Object? contractId = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? parentLocationId = freezed,Object? qrCodeId = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Location(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,parentLocationId: freezed == parentLocationId ? _self.parentLocationId : parentLocationId // ignore: cast_nullable_to_non_nullable
as String?,qrCodeId: freezed == qrCodeId ? _self.qrCodeId : qrCodeId // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
