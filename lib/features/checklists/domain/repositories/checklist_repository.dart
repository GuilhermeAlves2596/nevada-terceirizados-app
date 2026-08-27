import '../entities/checklist.dart';

abstract interface class ChecklistRepository {
  Future<List<Checklist>> getAll({required String companyId});
  Future<Checklist?> getById(String id);
}
