import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_item.freezed.dart';

/// Item de um checklist/rotina (seção 14).
///
/// Ex.: "Varrer o piso", "Repor papel higiênico".
@freezed
abstract class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String id,
    required String description,
    required int order,

    /// Se `true`, precisa estar concluído para finalizar a tarefa (seção 25).
    @Default(true) bool required,
  }) = _ChecklistItem;
}
