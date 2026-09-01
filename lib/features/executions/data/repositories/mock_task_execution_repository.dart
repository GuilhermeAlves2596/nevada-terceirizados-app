import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../../core/enums/execution_status.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/execution_item.dart';
import '../../domain/entities/execution_photo.dart';
import '../../domain/entities/task_execution.dart';
import '../../domain/repositories/task_execution_repository.dart';

class MockTaskExecutionRepository implements TaskExecutionRepository {
  MockTaskExecutionRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<TaskExecution> getOrCreateForTask({
    required String companyId,
    required String taskId,
    required String employeeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final existing = _db.executions
        .where((e) => e.taskId == taskId && e.companyId == companyId)
        .cast<TaskExecution?>()
        .firstWhere((e) => e != null, orElse: () => null);
    if (existing != null) return existing;

    final task = _db.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw const NotFoundException('Tarefa não encontrada.'),
    );
    final checklist = _db.checklists.firstWhere(
      (c) => c.id == task.checklistId,
      orElse: () => throw const NotFoundException('Checklist não encontrado.'),
    );

    final now = DateTime.now();
    final ordered = checklist.orderedItems;

    // Quantos itens já vêm concluídos para refletir o progresso atual da tarefa.
    final total = ordered.length;
    final preCompleted = switch (task.status) {
      TaskStatus.completed => total,
      TaskStatus.inProgress => ((task.progress / 100) * total).round(),
      _ => 0,
    };

    final items = <ExecutionItem>[
      for (var i = 0; i < ordered.length; i++)
        ExecutionItem(
          id: _uuid.v4(),
          checklistItemId: ordered[i].id,
          description: ordered[i].description,
          order: ordered[i].order,
          required: ordered[i].required,
          completed: i < preCompleted,
          completedAt: i < preCompleted ? now : null,
          completedBy: i < preCompleted ? employeeId : null,
        ),
    ];

    final status = switch (task.status) {
      TaskStatus.completed => ExecutionStatus.completed,
      TaskStatus.inProgress => ExecutionStatus.inProgress,
      _ => ExecutionStatus.notStarted,
    };

    final photos = <ExecutionPhoto>[
      if (task.status == TaskStatus.completed)
        ExecutionPhoto(
          id: _uuid.v4(),
          companyId: companyId,
          taskExecutionId: taskId,
          storagePath: 'mock://companies/$companyId/executions/$taskId/photo.jpg',
          localPath: 'mock',
          createdAt: now,
          createdBy: employeeId,
        ),
    ];

    final execution = TaskExecution(
      id: _uuid.v4(),
      companyId: companyId,
      taskId: taskId,
      employeeId: employeeId,
      status: status,
      startedAt: status == ExecutionStatus.notStarted ? null : now,
      finishedAt: status == ExecutionStatus.completed ? now : null,
      items: items,
      photos: photos,
      createdAt: now,
      updatedAt: now,
    );

    _db.upsertExecution(execution);
    return execution;
  }

  @override
  Future<TaskExecution?> findByTaskId({
    required String companyId,
    required String taskId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final e in _db.executions) {
      if (e.companyId == companyId && e.taskId == taskId) return e;
    }
    return null;
  }

  TaskExecution _require(String executionId) {
    return _db.executions.firstWhere(
      (e) => e.id == executionId,
      orElse: () => throw const NotFoundException('Execução não encontrada.'),
    );
  }

  /// Reflete status/progresso da execução na tarefa correspondente.
  void _syncTask(TaskExecution execution) {
    final task = _db.tasks
        .cast<Task?>()
        .firstWhere((t) => t?.id == execution.taskId, orElse: () => null);
    if (task == null) return;

    final status = switch (execution.status) {
      ExecutionStatus.notStarted => TaskStatus.pending,
      ExecutionStatus.inProgress => TaskStatus.inProgress,
      ExecutionStatus.completed => TaskStatus.completed,
      ExecutionStatus.cancelled => TaskStatus.cancelled,
    };
    _db.upsertTask(task.copyWith(
      status: status,
      progress: execution.progress,
      updatedAt: DateTime.now(),
    ));
  }

  TaskExecution _save(TaskExecution updated) {
    final synced = updated.copyWith(updatedAt: DateTime.now());
    _db.upsertExecution(synced);
    _syncTask(synced);
    return synced;
  }

  @override
  Future<TaskExecution> start(String executionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final e = _require(executionId);
    return _save(e.copyWith(
      status: ExecutionStatus.inProgress,
      startedAt: e.startedAt ?? DateTime.now(),
    ));
  }

  @override
  Future<TaskExecution> setItemCompleted({
    required String executionId,
    required String executionItemId,
    required bool completed,
  }) async {
    final e = _require(executionId);
    final items = e.items.map((item) {
      if (item.id != executionItemId) return item;
      return item.copyWith(
        completed: completed,
        completedAt: completed ? DateTime.now() : null,
        completedBy: completed ? e.employeeId : null,
      );
    }).toList();
    return _save(e.copyWith(items: items));
  }

  @override
  Future<TaskExecution> setObservation({
    required String executionId,
    String? observation,
  }) async {
    final e = _require(executionId);
    return _save(e.copyWith(observation: observation));
  }

  @override
  Future<TaskExecution> addPhoto(
    String executionId, {
    Uint8List? bytes,
    String? contentType,
    String? localPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final e = _require(executionId);
    final photo = ExecutionPhoto(
      id: _uuid.v4(),
      companyId: e.companyId,
      taskExecutionId: e.id,
      storagePath:
          'mock://companies/${e.companyId}/executions/${e.id}/${_uuid.v4()}.jpg',
      localPath: localPath ?? 'mock',
      createdAt: DateTime.now(),
      createdBy: e.employeeId,
    );
    return _save(e.copyWith(photos: [...e.photos, photo]));
  }

  @override
  Future<TaskExecution> removePhoto(String executionId, String photoId) async {
    final e = _require(executionId);
    return _save(
      e.copyWith(photos: e.photos.where((p) => p.id != photoId).toList()),
    );
  }

  @override
  Future<TaskExecution> finish(String executionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final e = _require(executionId);
    return _save(e.copyWith(
      status: ExecutionStatus.completed,
      finishedAt: DateTime.now(),
    ));
  }
}
