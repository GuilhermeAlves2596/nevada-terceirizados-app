import 'package:uuid/uuid.dart';

import '../../../../core/enums/task_priority.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  MockTaskRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

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

  @override
  Future<Task> create({
    required String companyId,
    required String clientId,
    required String contractId,
    required String locationId,
    required String checklistId,
    required String assignedTo,
    required String assignedBy,
    required DateTime scheduledDate,
    String? scheduledStartTime,
    required TaskPriority priority,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final task = Task(
      id: 'task_${_uuid.v4()}',
      companyId: companyId,
      clientId: clientId,
      contractId: contractId,
      locationId: locationId,
      checklistId: checklistId,
      assignedTo: assignedTo,
      assignedBy: assignedBy,
      scheduledDate: scheduledDate,
      scheduledStartTime: scheduledStartTime,
      priority: priority,
      status: TaskStatus.pending,
      progress: 0,
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertTask(task);
    return task;
  }

  @override
  Future<Task> setStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final task = _db.tasks.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(status: status, updatedAt: DateTime.now());
    _db.upsertTask(updated);
    return updated;
  }

  @override
  Future<void> delete(String taskId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _db.tasks.removeWhere((t) => t.id == taskId);
    _db.executions.removeWhere((e) => e.taskId == taskId);
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
