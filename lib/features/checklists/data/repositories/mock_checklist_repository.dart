import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/checklist.dart';
import '../../domain/repositories/checklist_repository.dart';

class MockChecklistRepository implements ChecklistRepository {
  MockChecklistRepository(this._db);

  final MockDatabase _db;

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
}
