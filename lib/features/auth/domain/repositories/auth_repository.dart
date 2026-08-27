import '../entities/app_user.dart';

/// Contrato de autenticação (seção 40).
///
/// A implementação de Fase 1 é mockada ([MockAuthRepository]); nas fases
/// futuras entra a [FirebaseAuthRepository] sem alterar as camadas acima.
abstract interface class AuthRepository {
  /// Autentica por e-mail/senha. Lança [AuthenticationException] em caso de
  /// credenciais inválidas.
  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();

  /// Usuário atualmente autenticado, ou `null`.
  Future<AppUser?> currentUser();
}
