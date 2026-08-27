import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação mockada da autenticação (Fase 2).
///
/// Aceita qualquer senha não vazia para os e-mails semeados. Será substituída
/// pela implementação de Firebase Authentication na Fase 8.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._db);

  final MockDatabase _db;
  AppUser? _current;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final normalized = email.trim().toLowerCase();
    if (password.trim().isEmpty) {
      throw const AuthenticationException('Informe a senha.');
    }

    final user = _db.users
        .where((u) => u.email.toLowerCase() == normalized && u.active)
        .cast<AppUser?>()
        .firstWhere((u) => u != null, orElse: () => null);

    if (user == null) {
      throw const AuthenticationException(
        'E-mail ou senha inválidos.',
      );
    }

    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _current = null;
  }

  @override
  Future<AppUser?> currentUser() async => _current;
}
