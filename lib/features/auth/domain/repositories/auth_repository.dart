import '../entities/app_user.dart';

/// Contrato de autenticação (seção 40).
///
/// A implementação real é a [FirebaseAuthRepository]. O login é feito por
/// **CPF** (ou e-mail) — o identificador é resolvido em um e-mail do Firebase.
abstract interface class AuthRepository {
  /// Autentica por CPF **ou** e-mail. Lança [AuthenticationException] em caso
  /// de credenciais inválidas.
  Future<AppUser> signIn({
    required String identifier,
    required String password,
  });

  Future<void> signOut();

  /// Usuário atualmente autenticado, ou `null`.
  Future<AppUser?> currentUser();

  /// Troca a senha do usuário logado e limpa a flag de troca obrigatória.
  Future<AppUser> changePassword(String newPassword);

  /// Envia o e-mail de redefinição de senha (fluxo "esqueci minha senha").
  /// Só faz sentido para contas com e-mail real (supervisor/gestor); o e-mail
  /// sintético do funcionário não recebe mensagens.
  Future<void> sendPasswordReset(String email);

  /// Atualiza os dados de perfil do **próprio** usuário logado (nome/telefone).
  /// Não altera role/companyId — também barrado pelas Security Rules.
  Future<AppUser> updateProfile({
    required String name,
    String? phone,
  });
}
