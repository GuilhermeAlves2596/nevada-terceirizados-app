import '../entities/task_execution.dart';

/// Contrato da execução de tarefas (seções 16–18, 20, 24, 25).
///
/// A implementação mock reflete as mudanças no status/progresso da própria
/// [Task]; na fase de Firestore isso vira escrita transacional.
abstract interface class TaskExecutionRepository {
  /// Carrega a execução da tarefa; cria uma nova (NOT_STARTED) se ainda não
  /// existir, com os itens espelhados do checklist.
  Future<TaskExecution> getOrCreateForTask({
    required String companyId,
    required String taskId,
    required String employeeId,
  });

  /// Retorna a execução existente da tarefa, ou `null` (não cria). Usado pela
  /// visão de acompanhamento do supervisor (somente leitura).
  Future<TaskExecution?> findByTaskId({
    required String companyId,
    required String taskId,
  });

  /// Registra o início (startedAt + status IN_PROGRESS).
  Future<TaskExecution> start(String executionId);

  /// Marca/desmarca um item do checklist.
  Future<TaskExecution> setItemCompleted({
    required String executionId,
    required String executionItemId,
    required bool completed,
  });

  Future<TaskExecution> setObservation({
    required String executionId,
    String? observation,
  });

  /// Adiciona uma foto (na Fase 3 é simulada; câmera real na Fase 6).
  Future<TaskExecution> addPhoto(String executionId, {String? localPath});

  Future<TaskExecution> removePhoto(String executionId, String photoId);

  /// Finaliza (finishedAt + status COMPLETED + progresso 100).
  Future<TaskExecution> finish(String executionId);
}
