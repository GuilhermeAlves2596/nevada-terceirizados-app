import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/task_priority.dart';
import '../../../../core/enums/task_status.dart';

part 'task.freezed.dart';

/// Trabalho agendado: aplica um [Checklist] a um local, funcionário e data
/// (seção 15).
@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String companyId,
    required String clientId,
    required String contractId,
    required String locationId,
    required String checklistId,

    /// `userId` do funcionário responsável.
    required String assignedTo,

    /// `userId` do supervisor que atribuiu.
    required String assignedBy,
    required DateTime scheduledDate,
    String? scheduledStartTime,
    @Default(TaskPriority.normal) TaskPriority priority,
    @Default(TaskStatus.pending) TaskStatus status,

    /// Progresso (0–100) espelhado da execução, para exibição em listas sem
    /// precisar carregar a execução inteira.
    @Default(0) int progress,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  bool get isPending => status == TaskStatus.pending;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isCancelled => status == TaskStatus.cancelled;

  /// Considerada atrasada se a data agendada já passou e ainda está aberta.
  bool isLate(DateTime now) =>
      status.isOpen &&
      scheduledDate.isBefore(DateTime(now.year, now.month, now.day));
}
