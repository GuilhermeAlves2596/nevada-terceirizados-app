import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/user_role.dart';

part 'app_user.freezed.dart';

/// Usuário do sistema (seção 10).
///
/// Modelamos funcionário e supervisor como o mesmo tipo, diferenciados pela
/// [role]. Isso reflete a coleção única `/users` recomendada no briefing
/// (seção 51) e simplifica regras de segurança.
///
/// Nomeada `AppUser` (e não `User`) para evitar conflito com o `User` do
/// Firebase Authentication nas fases futuras.
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String id,
    required String name,
    required UserRole role,

    /// E-mail é **opcional** (funcionário de campo costuma não ter). O login é
    /// feito por [cpf]; o e-mail vira apenas dado de perfil/notificação.
    String? email,

    /// CPF — identificador de login do usuário (só dígitos armazenados aqui).
    String? cpf,

    /// Obrigatório para funcionários e supervisores; pode ser nulo para o
    /// admin da plataforma.
    String? companyId,
    String? phone,
    String? photoUrl,

    /// Cargo/função exibido na interface (ex.: "Auxiliar de Limpeza").
    String? jobTitle,

    /// Exige troca de senha no próximo acesso (1º login com senha temporária).
    @Default(false) bool mustChangePassword,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  bool get isEmployee => role.isEmployee;
  bool get isSupervisor => role.isSupervisor;
  bool get isPlatformAdmin => role.isPlatformAdmin;

  /// Primeiro nome, para saudações ("Olá, João!").
  String get firstName => name.trim().split(' ').first;

  /// Iniciais para avatar de fallback.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
