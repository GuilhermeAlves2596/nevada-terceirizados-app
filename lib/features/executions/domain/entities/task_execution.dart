import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/execution_status.dart';
import 'execution_item.dart';
import 'execution_photo.dart';

part 'task_execution.freezed.dart';

/// Execução real do trabalho feito pelo funcionário (seção 16).
///
/// Contém o estado por item do checklist, fotos e observação.
@freezed
abstract class TaskExecution with _$TaskExecution {
  const TaskExecution._();

  const factory TaskExecution({
    required String id,
    required String companyId,
    required String taskId,
    required String employeeId,
    @Default(ExecutionStatus.notStarted) ExecutionStatus status,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? observation,
    @Default(<ExecutionItem>[]) List<ExecutionItem> items,
    @Default(<ExecutionPhoto>[]) List<ExecutionPhoto> photos,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskExecution;

  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.completed).length;

  bool get hasPhoto => photos.isNotEmpty;
  bool get isStarted => startedAt != null;

  /// Progresso 0–100 baseado em itens concluídos / total (seção 23).
  int get progress {
    if (items.isEmpty) return 0;
    return ((completedItems / totalItems) * 100).round();
  }
}
