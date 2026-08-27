import 'package:freezed_annotation/freezed_annotation.dart';

part 'execution_item.freezed.dart';

/// Registro da execução de um item específico do checklist (seção 17).
///
/// Mantém o histórico de quando e por quem cada item foi concluído.
@freezed
abstract class ExecutionItem with _$ExecutionItem {
  const factory ExecutionItem({
    required String id,
    required String checklistItemId,
    @Default(false) bool completed,
    DateTime? completedAt,
    String? completedBy,
  }) = _ExecutionItem;
}
