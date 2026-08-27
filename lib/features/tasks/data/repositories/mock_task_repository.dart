import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  MockTaskRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<Task>> getForEmployee({
    required String companyId,
    required String employeeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final result = _db.tasks
        .where((t) => t.companyId == companyId && t.assignedTo == employeeId)
        .toList();
    _sort(result);
    return result;
  }

  @override
  Future<List<Task>> getForCompany({required String companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final result =
        _db.tasks.where((t) => t.companyId == companyId).toList();
    _sort(result);
    return result;
  }

  @override
  Future<Task?> getById(String id) async {
    for (final t in _db.tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Abertas primeiro, depois por data agendada e horário.
  void _sort(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.status.isOpen != b.status.isOpen) {
        return a.status.isOpen ? -1 : 1;
      }
      final byDate = a.scheduledDate.compareTo(b.scheduledDate);
      if (byDate != 0) return byDate;
      return (a.scheduledStartTime ?? '').compareTo(b.scheduledStartTime ?? '');
    });
  }
}
