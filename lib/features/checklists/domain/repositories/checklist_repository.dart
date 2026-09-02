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
