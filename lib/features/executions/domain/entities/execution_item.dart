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

    /// Descrição e obrigatoriedade são denormalizadas do [ChecklistItem] no
    /// momento da criação da execução — assim a execução é auto-descritiva
    /// (bom para a tela, o histórico e a auditoria).
    required String description,
    required int order,
    @Default(true) bool required,
    @Default(false) bool completed,
    DateTime? completedAt,
    String? completedBy,
  }) = _ExecutionItem;
}
