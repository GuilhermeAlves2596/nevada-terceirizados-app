import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/service_type.dart';
import 'checklist_item.dart';

part 'checklist.freezed.dart';

/// Modelo de rotina/checklist reutilizável (seção 14).
///
/// Um checklist é um **modelo** ("Limpeza de Banheiro"); a [Task] é o trabalho
/// agendado que aponta para ele; a `TaskExecution` é a execução real. Essa
/// separação é fundamental para tarefas recorrentes no futuro.
@freezed
abstract class Checklist with _$Checklist {
  const Checklist._();

  const factory Checklist({
    required String id,
    required String companyId,
    required String name,
    required ServiceType serviceType,
    String? description,

    /// Vínculos opcionais: um checklist pode ser genérico ou específico de um
    /// cliente/contrato/local.
    String? clientId,
    String? contractId,
    String? locationId,
    @Default(<ChecklistItem>[]) List<ChecklistItem> items,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Checklist;

  int get totalItems => items.length;
  int get requiredItems => items.where((i) => i.required).length;

  /// Itens ordenados pela posição definida pelo supervisor.
  List<ChecklistItem> get orderedItems =>
      [...items]..sort((a, b) => a.order.compareTo(b.order));
}
