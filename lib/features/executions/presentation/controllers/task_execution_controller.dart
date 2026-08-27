import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/task_execution.dart';
import '../../domain/usecases/validate_execution_finish.dart';

/// Controla a execução de uma tarefa específica (chaveada por `taskId`).
class TaskExecutionController
    extends FamilyAsyncNotifier<TaskExecution, String> {
  static const _validator = ValidateExecutionFinish();

  @override
  Future<TaskExecution> build(String taskId) async {
    final user = ref.watch(currentUserProvider);
    final companyId = user?.companyId;
    if (user == null || companyId == null) {
      throw const AuthenticationException('Sessão expirada. Entre novamente.');
    }
    return ref.read(taskExecutionRepositoryProvider).getOrCreateForTask(
          companyId: companyId,
          taskId: taskId,
          employeeId: user.id,
        );
  }

  Future<void> start() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated =
        await ref.read(taskExecutionRepositoryProvider).start(current.id);
    state = AsyncData(updated);
    _invalidateLists();
  }

  Future<void> toggleItem(String executionItemId, bool completed) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Atualização otimista para feedback instantâneo no checklist.
    final optimistic = current.copyWith(
      items: current.items
          .map((i) => i.id == executionItemId
              ? i.copyWith(
                  completed: completed,
                  completedAt: completed ? DateTime.now() : null,
                )
              : i)
          .toList(),
    );
    state = AsyncData(optimistic);

    final saved =
        await ref.read(taskExecutionRepositoryProvider).setItemCompleted(
              executionId: current.id,
              executionItemId: executionItemId,
              completed: completed,
            );
    state = AsyncData(saved);
    _invalidateLists();
  }

  Future<void> setObservation(String? observation) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final trimmed = (observation ?? '').trim();
    final updated =
        await ref.read(taskExecutionRepositoryProvider).setObservation(
              executionId: current.id,
              observation: trimmed.isEmpty ? null : trimmed,
            );
    state = AsyncData(updated);
  }

  Future<void> addPhoto() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated =
        await ref.read(taskExecutionRepositoryProvider).addPhoto(current.id);
    state = AsyncData(updated);
  }

  Future<void> removePhoto(String photoId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = await ref
        .read(taskExecutionRepositoryProvider)
        .removePhoto(current.id, photoId);
    state = AsyncData(updated);
  }

  /// Tenta finalizar. Retorna `null` em caso de sucesso ou a mensagem de erro
  /// de validação (itens obrigatórios/foto) para exibição.
  Future<String?> finish() async {
    final current = state.valueOrNull;
    if (current == null) return 'Execução não carregada.';

    final validation = _validator(current);
    if (!validation.canFinish) return validation.message;

    final updated =
        await ref.read(taskExecutionRepositoryProvider).finish(current.id);
    state = AsyncData(updated);
    _invalidateLists();
    return null;
  }

  void _invalidateLists() {
    ref.invalidate(employeeTaskViewsProvider);
    ref.invalidate(supervisorTaskViewsProvider);
  }
}

final taskExecutionControllerProvider = AsyncNotifierProvider.family<
    TaskExecutionController, TaskExecution, String>(
  TaskExecutionController.new,
);
