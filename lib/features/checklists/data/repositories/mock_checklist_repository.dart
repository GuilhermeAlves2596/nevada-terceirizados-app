import 'package:uuid/uuid.dart';

import '../../../../core/enums/service_type.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/checklist.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/repositories/checklist_repository.dart';

class MockChecklistRepository implements ChecklistRepository {
  MockChecklistRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<Checklist>> getAll({required String companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.checklists.where((c) => c.companyId == companyId).toList();
  }

  @override
  Future<Checklist?> getById(String id) async {
    for (final c in _db.checklists) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<Checklist> create({
    required String companyId,
    required String name,
    required ServiceType serviceType,
    String? description,
    String? clientId,
    String? contractId,
    required List<ChecklistItemInput> items,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final builtItems = <ChecklistItem>[
      for (var i = 0; i < items.length; i++)
        ChecklistItem(
          id: _uuid.v4(),
          description: items[i].description.trim(),
          order: i + 1,
          required: items[i].required,
        ),
    ];
    final checklist = Checklist(
      id: _uuid.v4(),
      companyId: companyId,
      name: name.trim(),
      serviceType: serviceType,
      description: description?.trim(),
      clientId: clientId,
      contractId: contractId,
      items: builtItems,
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertChecklist(checklist);
    return checklist;
  }
}
