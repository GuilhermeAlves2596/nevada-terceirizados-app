import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/enums/task_status.dart';
import 'package:nevada_terceirizados/features/tasks/domain/entities/task.dart';
import 'package:nevada_terceirizados/features/tasks/presentation/models/task_stats.dart';

Task _task({
  required String id,
  required TaskStatus status,
  required DateTime scheduledDate,
}) {
  final now = DateTime(2026, 8, 27);
  return Task(
    id: id,
    companyId: 'c1',
    clientId: 'cl1',
    contractId: 'ct1',
    locationId: 'l1',
    checklistId: 'chk1',
    assignedTo: 'u1',
    assignedBy: 's1',
    scheduledDate: scheduledDate,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final now = DateTime(2026, 8, 27, 10);
  final today = DateTime(2026, 8, 27);
  final yesterday = DateTime(2026, 8, 26);
  final tomorrow = DateTime(2026, 8, 28);

  test('conta status corretamente', () {
    final stats = TaskStats.from([
      _task(id: '1', status: TaskStatus.pending, scheduledDate: today),
      _task(id: '2', status: TaskStatus.inProgress, scheduledDate: today),
      _task(id: '3', status: TaskStatus.completed, scheduledDate: today),
      _task(id: '4', status: TaskStatus.completed, scheduledDate: today),
      _task(id: '5', status: TaskStatus.cancelled, scheduledDate: today),
    ], now: now);

    expect(stats.total, 5);
    expect(stats.pending, 1);
    expect(stats.inProgress, 1);
    expect(stats.completed, 2);
    expect(stats.cancelled, 1);
  });

  test('tarefa aberta com data passada é atrasada', () {
    final stats = TaskStats.from([
      _task(id: '1', status: TaskStatus.pending, scheduledDate: yesterday),
      _task(id: '2', status: TaskStatus.inProgress, scheduledDate: yesterday),
      _task(id: '3', status: TaskStatus.completed, scheduledDate: yesterday),
      _task(id: '4', status: TaskStatus.pending, scheduledDate: today),
      _task(id: '5', status: TaskStatus.pending, scheduledDate: tomorrow),
    ], now: now);

    // Apenas as duas abertas de ontem contam como atrasadas.
    expect(stats.late, 2);
  });
}
