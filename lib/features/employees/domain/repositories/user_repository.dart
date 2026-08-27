import '../../../auth/domain/entities/app_user.dart';

/// Acesso a usuários da empresa (funcionários e supervisores).
///
/// Todas as consultas são isoladas por `companyId` (multi-tenant, seção 6).
abstract interface class UserRepository {
  Future<AppUser?> getById(String id);

  /// Todos os usuários da empresa.
  Future<List<AppUser>> getAll({required String companyId});

  /// Apenas os funcionários (role employee) da empresa.
  Future<List<AppUser>> getEmployees({required String companyId});

  /// Cadastra um funcionário associado à empresa (role = employee).
  Future<AppUser> createEmployee({
    required String companyId,
    required String name,
    required String email,
    String? phone,
    String? jobTitle,
  });

  /// Ativa/desativa um usuário.
  Future<AppUser> setActive({required String userId, required bool active});
}
