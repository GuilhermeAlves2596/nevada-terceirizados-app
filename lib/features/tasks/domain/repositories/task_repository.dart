import '../entities/task.dart';

/// Acesso a tarefas agendadas, sempre isolado por `companyId`.
abstract interface class TaskRepository {
  /// Tarefas de um funcionário específico (visão do app do funcionário).
  Future<List<Task>> getForEmployee({
    required String companyId,
    required String employeeId,
  });

  /// Todas as tarefas da empresa (visão do supervisor).
  Future<List<Task>> getForCompany({required String companyId});

  Future<Task?> getById(String id);
}
