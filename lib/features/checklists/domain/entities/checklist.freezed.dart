// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checklist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Checklist {

 String get id; String get companyId; String get name; ServiceType get serviceType; String? get description;/// Vínculos opcionais: um checklist pode ser genérico ou específico de um
/// cliente/contrato/local.
 String? get clientId; String? get contractId; String? get locationId; List<ChecklistItem> get items; bool get active; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Checklist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChecklistCopyWith<Checklist> get copyWith => _$ChecklistCopyWithImpl<Checklist>(this as Checklist, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Checklist&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.description, description) || other.description == description)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,serviceType,description,clientId,contractId,locationId,const DeepCollectionEquality().hash(items),active,createdAt,updatedAt);

@override
String toString() {
  return 'Checklist(id: $id, companyId: $companyId, name: $name, serviceType: $serviceType, description: $description, clientId: $clientId, contractId: $contractId, locationId: $locationId, items: $items, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChecklistCopyWith<$Res>  {
  factory $ChecklistCopyWith(Checklist value, $Res Function(Checklist) _then) = _$ChecklistCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, ServiceType serviceType, String? description, String? clientId, String? contractId, String? locationId, List<ChecklistItem> items, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ChecklistCopyWithImpl<$Res>
    implements $ChecklistCopyWith<$Res> {
  _$ChecklistCopyWithImpl(this._self, this._then);

  final Checklist _self;
  final $Res Function(Checklist) _then;

/// Create a copy of Checklist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? serviceType = null,Object? description = freezed,Object? clientId = freezed,Object? contractId = freezed,Object? locationId = freezed,Object? items = null,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as ServiceType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,contractId: freezed == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ChecklistItem>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Checklist].
extension ChecklistPatterns on Checklist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Checklist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Checklist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Checklist value)  $default,){
final _that = this;
switch (_that) {
case _Checklist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Checklist value)?  $default,){
final _that = this;
switch (_that) {
case _Checklist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  ServiceType serviceType,  String? description,  String? clientId,  String? contractId,  String? locationId,  List<ChecklistItem> items,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Checklist() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.serviceType,_that.description,_that.clientId,_that.contractId,_that.locationId,_that.items,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  ServiceType serviceType,  String? description,  String? clientId,  String? contractId,  String? locationId,  List<ChecklistItem> items,  bool active,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Checklist():
return $default(_that.id,_that.companyId,_that.name,_that.serviceType,_that.description,_that.clientId,_that.contractId,_that.locationId,_that.items,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  ServiceType serviceType,  String? description,  String? clientId,  String? contractId,  String? locationId,  List<ChecklistItem> items,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Checklist() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.serviceType,_that.description,_that.clientId,_that.contractId,_that.locationId,_that.items,_that.active,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Checklist extends Checklist {
  const _Checklist({required this.id, required this.companyId, required this.name, required this.serviceType, this.description, this.clientId, this.contractId, this.locationId, final  List<ChecklistItem> items = const <ChecklistItem>[], this.active = true, required this.createdAt, required this.updatedAt}): _items = items,super._();
  

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  ServiceType serviceType;
@override final  String? description;
/// Vínculos opcionais: um checklist pode ser genérico ou específico de um
/// cliente/contrato/local.
@override final  String? clientId;
@override final  String? contractId;
@override final  String? locationId;
 final  List<ChecklistItem> _items;
@override@JsonKey() List<ChecklistItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool active;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Checklist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChecklistCopyWith<_Checklist> get copyWith => __$ChecklistCopyWithImpl<_Checklist>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Checklist&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.description, description) || other.description == description)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,serviceType,description,clientId,contractId,locationId,const DeepCollectionEquality().hash(_items),active,createdAt,updatedAt);

@override
String toString() {
  return 'Checklist(id: $id, companyId: $companyId, name: $name, serviceType: $serviceType, description: $description, clientId: $clientId, contractId: $contractId, locationId: $locationId, items: $items, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChecklistCopyWith<$Res> implements $ChecklistCopyWith<$Res> {
  factory _$ChecklistCopyWith(_Checklist value, $Res Function(_Checklist) _then) = __$ChecklistCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, ServiceType serviceType, String? description, String? clientId, String? contractId, String? locationId, List<ChecklistItem> items, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ChecklistCopyWithImpl<$Res>
    implements _$ChecklistCopyWith<$Res> {
  __$ChecklistCopyWithImpl(this._self, this._then);

  final _Checklist _self;
  final $Res Function(_Checklist) _then;

/// Create a copy of Checklist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? serviceType = null,Object? description = freezed,Object? clientId = freezed,Object? contractId = freezed,Object? locationId = freezed,Object? items = null,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Checklist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as ServiceType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,contractId: freezed == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChecklistItem>,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
