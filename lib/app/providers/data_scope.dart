import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';

/// Escopo de dados do usuário logado **dentro** da empresa.
///
/// - **supervisor**: vê apenas os contratos/clientes vinculados a ele
///   (`contractIds`/`clientIds` do próprio usuário).
/// - **companyAdmin / platformAdmin**: veem tudo da empresa (`all`).
/// - **employee**: não navega essas listas (usa só as próprias tarefas); por
///   segurança é tratado como escopo vazio.
///
/// O isolamento entre empresas continua sendo garantido pelas Security Rules
/// (companyId). Este escopo é o recorte fino **por contrato**, aplicado no app.
class DataScope {
  const DataScope({
    required this.all,
    this.contractIds = const {},
    this.clientIds = const {},
  });

  const DataScope.all()
      : all = true,
        contractIds = const {},
        clientIds = const {};

  const DataScope.none()
      : all = false,
        contractIds = const {},
        clientIds = const {};

  /// Vê tudo da empresa (gestor/admin) — ignora os filtros de contrato.
  final bool all;
  final Set<String> contractIds;
  final Set<String> clientIds;

  bool allowsContract(String? contractId) =>
      all || (contractId != null && contractIds.contains(contractId));

  bool allowsClient(String? clientId) =>
      all || (clientId != null && clientIds.contains(clientId));

  /// Um funcionário está no escopo se algum contrato dele estiver no escopo.
  bool allowsEmployee(Iterable<String> employeeContractIds) =>
      all || employeeContractIds.any(contractIds.contains);
}

/// Escopo de dados do usuário autenticado.
final dataScopeProvider = Provider.autoDispose<DataScope>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const DataScope.none();
  if (user.isSupervisor) {
    return DataScope(
      all: false,
      contractIds: user.contractIds.toSet(),
      clientIds: user.clientIds.toSet(),
    );
  }
  // Gestor da empresa e admin da plataforma enxergam tudo.
  return const DataScope.all();
});
