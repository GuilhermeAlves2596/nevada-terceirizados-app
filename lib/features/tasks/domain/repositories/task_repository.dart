import '../../../../core/enums/task_priority.dart';
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

  /// Cria (atribui) uma nova tarefa. Status inicial PENDING, progresso 0.
  Future<Task> create({
    required String companyId,
    required String clientId,
    required String contractId,
    required String locationId,
    required String checklistId,
    required String assignedTo,
    required String assignedBy,
    required DateTime scheduledDate,
    String? scheduledStartTime,
    required TaskPriority priority,
  });
}
