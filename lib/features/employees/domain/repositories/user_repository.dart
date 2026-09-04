import '../../../auth/domain/entities/app_user.dart';
import '../entities/new_employee_result.dart';

/// Acesso a usuários da empresa (funcionários e supervisores).
///
/// Todas as consultas são isoladas por `companyId` (multi-tenant, seção 6).
abstract interface class UserRepository {
  Future<AppUser?> getById(String id);

  /// Todos os usuários da empresa.
  Future<List<AppUser>> getAll({required String companyId});

  /// Apenas os funcionários (role employee) da empresa.
  Future<List<AppUser>> getEmployees({required String companyId});

  /// Cadastra um funcionário (role = employee): cria a conta de acesso com uma
  /// senha temporária e o perfil. O login é feito por [cpf]; o e-mail é
  /// opcional. O funcionário **herda** o contrato/cliente informado ([contractId]
  /// dentro do escopo do supervisor — seção do realinhamento). Retorna o usuário
  /// e a senha temporária a exibir ao supervisor.
  Future<NewEmployeeResult> createEmployee({
    required String companyId,
    required String contractId,
    required String clientId,
    required String name,
    required String cpf,
    String? email,
    String? phone,
    String? jobTitle,
  });

  /// Edita os dados de perfil (não altera CPF/role/senha).
  Future<AppUser> update({
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? jobTitle,
  });

  /// Remove o perfil do usuário. Obs.: a conta de acesso (Firebase Auth) não é
  /// removida pelo cliente — isso exige Admin SDK/Cloud Function.
  Future<void> delete(String userId);

  /// Ativa/desativa um usuário.
  Future<AppUser> setActive({required String userId, required bool active});

  /// Define os contratos/clientes que um **supervisor** atende (vínculo feito
  /// pelo gestor). O supervisor passa a ver apenas esse escopo; funcionários
  /// criados por ele herdam um desses contratos.
  Future<AppUser> setContracts({
    required String userId,
    required List<String> contractIds,
    required List<String> clientIds,
  });
}
