// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppUser {

 String get id; String get name; UserRole get role;/// E-mail é **opcional** (funcionário de campo costuma não ter). O login é
/// feito por [cpf]; o e-mail vira apenas dado de perfil/notificação.
 String? get email;/// CPF — identificador de login do usuário (só dígitos armazenados aqui).
 String? get cpf;/// Obrigatório para funcionários e supervisores; pode ser nulo para o
/// admin da plataforma.
 String? get companyId;/// Contratos aos quais o usuário está vinculado (multi-tenant, nível cliente).
///
/// Fonte da verdade do escopo: **supervisor** cobre vários; **funcionário**
/// tem exatamente um; **companyAdmin/platformAdmin** ficam vazios (enxergam
/// todo o escopo da empresa/plataforma). O gestor define esses vínculos no
/// painel web ao cadastrar o supervisor.
 List<String> get contractIds;/// Clientes correspondentes aos [contractIds], **denormalizados** para
/// permitir filtros `array-contains` no Firestore (que não faz join).
/// Derivável de `Contract.clientId`; mantido em sincronia na escrita.
 List<String> get clientIds; String? get phone; String? get photoUrl;/// Cargo/função exibido na interface (ex.: "Auxiliar de Limpeza").
 String? get jobTitle;/// Exige troca de senha no próximo acesso (1º login com senha temporária).
 bool get mustChangePassword; bool get active; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&const DeepCollectionEquality().equals(other.contractIds, contractIds)&&const DeepCollectionEquality().equals(other.clientIds, clientIds)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,email,cpf,companyId,const DeepCollectionEquality().hash(contractIds),const DeepCollectionEquality().hash(clientIds),phone,photoUrl,jobTitle,mustChangePassword,active,createdAt,updatedAt);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, role: $role, email: $email, cpf: $cpf, companyId: $companyId, contractIds: $contractIds, clientIds: $clientIds, phone: $phone, photoUrl: $photoUrl, jobTitle: $jobTitle, mustChangePassword: $mustChangePassword, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, UserRole role, String? email, String? cpf, String? companyId, List<String> contractIds, List<String> clientIds, String? phone, String? photoUrl, String? jobTitle, bool mustChangePassword, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? email = freezed,Object? cpf = freezed,Object? companyId = freezed,Object? contractIds = null,Object? clientIds = null,Object? phone = freezed,Object? photoUrl = freezed,Object? jobTitle = freezed,Object? mustChangePassword = null,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,contractIds: null == contractIds ? _self.contractIds : contractIds // ignore: cast_nullable_to_non_nullable
as List<String>,clientIds: null == clientIds ? _self.clientIds : clientIds // ignore: cast_nullable_to_non_nullable
as List<String>,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  String? email,  String? cpf,  String? companyId,  List<String> contractIds,  List<String> clientIds,  String? phone,  String? photoUrl,  String? jobTitle,  bool mustChangePassword,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.email,_that.cpf,_that.companyId,_that.contractIds,_that.clientIds,_that.phone,_that.photoUrl,_that.jobTitle,_that.mustChangePassword,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role,  String? email,  String? cpf,  String? companyId,  List<String> contractIds,  List<String> clientIds,  String? phone,  String? photoUrl,  String? jobTitle,  bool mustChangePassword,  bool active,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.name,_that.role,_that.email,_that.cpf,_that.companyId,_that.contractIds,_that.clientIds,_that.phone,_that.photoUrl,_that.jobTitle,_that.mustChangePassword,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  UserRole role,  String? email,  String? cpf,  String? companyId,  List<String> contractIds,  List<String> clientIds,  String? phone,  String? photoUrl,  String? jobTitle,  bool mustChangePassword,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.email,_that.cpf,_that.companyId,_that.contractIds,_that.clientIds,_that.phone,_that.photoUrl,_that.jobTitle,_that.mustChangePassword,_that.active,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AppUser extends AppUser {
  const _AppUser({required this.id, required this.name, required this.role, this.email, this.cpf, this.companyId, final  List<String> contractIds = const <String>[], final  List<String> clientIds = const <String>[], this.phone, this.photoUrl, this.jobTitle, this.mustChangePassword = false, this.active = true, required this.createdAt, required this.updatedAt}): _contractIds = contractIds,_clientIds = clientIds,super._();
  

@override final  String id;
@override final  String name;
@override final  UserRole role;
/// E-mail é **opcional** (funcionário de campo costuma não ter). O login é
/// feito por [cpf]; o e-mail vira apenas dado de perfil/notificação.
@override final  String? email;
/// CPF — identificador de login do usuário (só dígitos armazenados aqui).
@override final  String? cpf;
/// Obrigatório para funcionários e supervisores; pode ser nulo para o
/// admin da plataforma.
@override final  String? companyId;
/// Contratos aos quais o usuário está vinculado (multi-tenant, nível cliente).
///
/// Fonte da verdade do escopo: **supervisor** cobre vários; **funcionário**
/// tem exatamente um; **companyAdmin/platformAdmin** ficam vazios (enxergam
/// todo o escopo da empresa/plataforma). O gestor define esses vínculos no
/// painel web ao cadastrar o supervisor.
 final  List<String> _contractIds;
/// Contratos aos quais o usuário está vinculado (multi-tenant, nível cliente).
///
/// Fonte da verdade do escopo: **supervisor** cobre vários; **funcionário**
/// tem exatamente um; **companyAdmin/platformAdmin** ficam vazios (enxergam
/// todo o escopo da empresa/plataforma). O gestor define esses vínculos no
/// painel web ao cadastrar o supervisor.
@override@JsonKey() List<String> get contractIds {
  if (_contractIds is EqualUnmodifiableListView) return _contractIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contractIds);
}

/// Clientes correspondentes aos [contractIds], **denormalizados** para
/// permitir filtros `array-contains` no Firestore (que não faz join).
/// Derivável de `Contract.clientId`; mantido em sincronia na escrita.
 final  List<String> _clientIds;
/// Clientes correspondentes aos [contractIds], **denormalizados** para
/// permitir filtros `array-contains` no Firestore (que não faz join).
/// Derivável de `Contract.clientId`; mantido em sincronia na escrita.
@override@JsonKey() List<String> get clientIds {
  if (_clientIds is EqualUnmodifiableListView) return _clientIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clientIds);
}

@override final  String? phone;
@override final  String? photoUrl;
/// Cargo/função exibido na interface (ex.: "Auxiliar de Limpeza").
@override final  String? jobTitle;
/// Exige troca de senha no próximo acesso (1º login com senha temporária).
@override@JsonKey() final  bool mustChangePassword;
@override@JsonKey() final  bool active;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&const DeepCollectionEquality().equals(other._contractIds, _contractIds)&&const DeepCollectionEquality().equals(other._clientIds, _clientIds)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,email,cpf,companyId,const DeepCollectionEquality().hash(_contractIds),const DeepCollectionEquality().hash(_clientIds),phone,photoUrl,jobTitle,mustChangePassword,active,createdAt,updatedAt);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, role: $role, email: $email, cpf: $cpf, companyId: $companyId, contractIds: $contractIds, clientIds: $clientIds, phone: $phone, photoUrl: $photoUrl, jobTitle: $jobTitle, mustChangePassword: $mustChangePassword, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, UserRole role, String? email, String? cpf, String? companyId, List<String> contractIds, List<String> clientIds, String? phone, String? photoUrl, String? jobTitle, bool mustChangePassword, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? email = freezed,Object? cpf = freezed,Object? companyId = freezed,Object? contractIds = null,Object? clientIds = null,Object? phone = freezed,Object? photoUrl = freezed,Object? jobTitle = freezed,Object? mustChangePassword = null,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,contractIds: null == contractIds ? _self._contractIds : contractIds // ignore: cast_nullable_to_non_nullable
as List<String>,clientIds: null == clientIds ? _self._clientIds : clientIds // ignore: cast_nullable_to_non_nullable
as List<String>,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
