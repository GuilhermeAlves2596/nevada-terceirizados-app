import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/enums/task_status.dart';
import 'package:nevada_terceirizados/core/mock/mock_database.dart';
import 'package:nevada_terceirizados/features/executions/data/repositories/mock_task_execution_repository.dart';
import 'package:nevada_terceirizados/features/tasks/data/repositories/mock_task_repository.dart';

void main() {
  const companyId = MockDatabase.companyNevada;

  test('setStatus cancela a tarefa', () async {
    final db = MockDatabase.seeded();
    final repo = MockTaskRepository(db);
    final target = db.tasks.first;

    final updated =
        await repo.setStatus(taskId: target.id, status: TaskStatus.cancelled);
    expect(updated.status, TaskStatus.cancelled);
  });

  test('delete remove a tarefa e sua execução', () async {
    final db = MockDatabase.seeded();
    final taskRepo = MockTaskRepository(db);
    final execRepo = MockTaskExecutionRepository(db);
    final target = db.tasks.first;

    // Cria uma execução para a tarefa.
    await execRepo.getOrCreateForTask(
      companyId: companyId,
      taskId: target.id,
      employeeId: target.assignedTo,
    );
    expect(
      await execRepo.findByTaskId(companyId: companyId, taskId: target.id),
      isNotNull,
    );

    await taskRepo.delete(target.id);

    expect(await taskRepo.getById(target.id), isNull);
    expect(
      await execRepo.findByTaskId(companyId: companyId, taskId: target.id),
      isNull,
    );
  });

  test('findByTaskId não cria execução quando não existe', () async {
    final db = MockDatabase.seeded();
    final execRepo = MockTaskExecutionRepository(db);
    final target = db.tasks.first;

    final found =
        await execRepo.findByTaskId(companyId: companyId, taskId: target.id);
    expect(found, isNull);
    expect(db.executions, isEmpty);
  });
}
