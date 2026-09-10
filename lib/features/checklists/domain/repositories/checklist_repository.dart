import '../../../../core/enums/service_type.dart';
import '../entities/checklist.dart';

/// Descritor de item recebido da UI ao criar/editar um checklist.
typedef ChecklistItemInput = ({String description, bool required});

abstract interface class ChecklistRepository {
  Future<List<Checklist>> getAll({required String companyId});
  Future<Checklist?> getById(String id);

  Future<Checklist> create({
    required String companyId,
    required String name,
    required ServiceType serviceType,
    String? description,
    String? clientId,
    String? contractId,

    /// Dono (uid do supervisor) — checklists criados/copiados pelo supervisor.
    String? ownerId,

    /// Quando é uma cópia de um checklist padrão: id do padrão de origem.
    String? sourceId,
    String? clientTypeId,
    required List<ChecklistItemInput> items,
  });

  Future<Checklist> update({
    required String id,
    required String name,
    required ServiceType serviceType,
    String? description,
    required List<ChecklistItemInput> items,
  });

  Future<void> delete(String id);
}
