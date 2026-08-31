import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/execution_status.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/firestore_converters.dart';
import '../../../checklists/data/repositories/firebase_checklist_repository.dart';
import '../../../tasks/data/repositories/firebase_task_repository.dart';
import '../../domain/entities/execution_item.dart';
import '../../domain/entities/execution_photo.dart';
import '../../domain/entities/task_execution.dart';
import '../../domain/repositories/task_execution_repository.dart';

ExecutionItem _itemFromMap(Map<String, dynamic> m) => ExecutionItem(
      id: (m['id'] as String?) ?? '',
      checklistItemId: (m['checklistItemId'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      order: (m['order'] as num?)?.toInt() ?? 0,
      required: (m['required'] as bool?) ?? true,
      completed: (m['completed'] as bool?) ?? false,
      completedAt: m['completedAt'] == null ? null : fsDate(m['completedAt']),
      completedBy: m['completedBy'] as String?,
    );

Map<String, dynamic> _itemToMap(ExecutionItem i) => {
      'id': i.id,
      'checklistItemId': i.checklistItemId,
      'description': i.description,
      'order': i.order,
      'required': i.required,
      'completed': i.completed,
      'completedAt': i.completedAt == null ? null : fsTs(i.completedAt!),
      'completedBy': i.completedBy,
    };

ExecutionPhoto _photoFromMap(Map<String, dynamic> m) => ExecutionPhoto(
      id: (m['id'] as String?) ?? '',
      companyId: (m['companyId'] as String?) ?? '',
      taskExecutionId: (m['taskExecutionId'] as String?) ?? '',
      storagePath: (m['storagePath'] as String?) ?? '',
      downloadUrl: m['downloadUrl'] as String?,
      localPath: m['localPath'] as String?,
      createdAt: fsDate(m['createdAt']),
      createdBy: m['createdBy'] as String?,
    );

Map<String, dynamic> _photoToMap(ExecutionPhoto p) => {
      'id': p.id,
      'companyId': p.companyId,
      'taskExecutionId': p.taskExecutionId,
      'storagePath': p.storagePath,
      'downloadUrl': p.downloadUrl,
      'localPath': p.localPath,
      'createdAt': fsTs(p.createdAt),
      'createdBy': p.createdBy,
    };

TaskExecution executionFromDoc(String id, Map<String, dynamic> d) {
  final items = (d['items'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(_itemFromMap)
      .toList();
  final photos = (d['photos'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(_photoFromMap)
      .toList();
  return TaskExecution(
    id: id,
    companyId: (d['companyId'] as String?) ?? '',
    taskId: (d['taskId'] as String?) ?? '',
    employeeId: (d['employeeId'] as String?) ?? '',
    status: ExecutionStatus.fromName(d['status'] as String?),
    startedAt: d['startedAt'] == null ? null : fsDate(d['startedAt']),
    finishedAt: d['finishedAt'] == null ? null : fsDate(d['finishedAt']),
    observation: d['observation'] as String?,
    items: items,
    photos: photos,
    createdAt: fsDate(d['createdAt']),
    updatedAt: fsDate(d['updatedAt']),
  );
}

Map<String, dynamic> executionToMap(TaskExecution e) => {
      'companyId': e.companyId,
      'taskId': e.taskId,
      'employeeId': e.employeeId,
      'status': e.status.name,
      'startedAt': e.startedAt == null ? null : fsTs(e.startedAt!),
      'finishedAt': e.finishedAt == null ? null : fsTs(e.finishedAt!),
      'observation': e.observation,
      'items': e.items.map(_itemToMap).toList(),
      'photos': e.photos.map(_photoToMap).toList(),
      'createdAt': fsTs(e.createdAt),
      'updatedAt': fsTs(e.updatedAt),
    };

class FirebaseTaskExecutionRepository implements TaskExecutionRepository {
  FirebaseTaskExecutionRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('taskExecutions');

  @override
  Future<TaskExecution> getOrCreateForTask({
    required String companyId,
    required String taskId,
    required String employeeId,
  }) async {
    final existing = await findByTaskId(companyId: companyId, taskId: taskId);
    if (existing != null) return existing;

    final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
    if (!taskDoc.exists) {
      throw const NotFoundException('Tarefa não encontrada.');
    }
    final task = taskFromDoc(taskDoc.id, taskDoc.data()!);

    final checklistDoc =
        await _firestore.collection('checklists').doc(task.checklistId).get();
    if (!checklistDoc.exists) {
      throw const NotFoundException('Checklist não encontrado.');
    }
    final checklist = checklistFromDoc(checklistDoc.id, checklistDoc.data()!);
    final ordered = checklist.orderedItems;

    final now = DateTime.now();
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

    final ref = _col.doc();
    final photos = <ExecutionPhoto>[
      if (task.status == TaskStatus.completed)
        ExecutionPhoto(
          id: _uuid.v4(),
          companyId: companyId,
          taskExecutionId: ref.id,
          storagePath: 'mock://companies/$companyId/executions/${ref.id}/photo.jpg',
          localPath: 'mock',
          createdAt: now,
          createdBy: employeeId,
        ),
    ];

    final execution = TaskExecution(
      id: ref.id,
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
    await ref.set(executionToMap(execution));
    return execution;
  }

  @override
  Future<TaskExecution?> findByTaskId({
    required String companyId,
    required String taskId,
  }) async {
    final snap = await _col.where('taskId', isEqualTo: taskId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final exec = executionFromDoc(snap.docs.first.id, snap.docs.first.data());
    return exec.companyId == companyId ? exec : null;
  }

  Future<TaskExecution> _load(String executionId) async {
    final doc = await _col.doc(executionId).get();
    if (!doc.exists) throw const NotFoundException('Execução não encontrada.');
    return executionFromDoc(doc.id, doc.data()!);
  }

  /// Grava a execução e reflete status/progresso na tarefa correspondente.
  Future<TaskExecution> _save(TaskExecution updated) async {
    final synced = updated.copyWith(updatedAt: DateTime.now());
    final batch = _firestore.batch();
    batch.set(_col.doc(synced.id), executionToMap(synced));

    final taskStatus = switch (synced.status) {
      ExecutionStatus.notStarted => TaskStatus.pending,
      ExecutionStatus.inProgress => TaskStatus.inProgress,
      ExecutionStatus.completed => TaskStatus.completed,
      ExecutionStatus.cancelled => TaskStatus.cancelled,
    };
    batch.update(_firestore.collection('tasks').doc(synced.taskId), {
      'status': taskStatus.name,
      'progress': synced.progress,
      'updatedAt': Timestamp.now(),
    });
    await batch.commit();
    return synced;
  }

  @override
  Future<TaskExecution> start(String executionId) async {
    final e = await _load(executionId);
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
    final e = await _load(executionId);
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
    final e = await _load(executionId);
    return _save(e.copyWith(observation: observation));
  }

  @override
  Future<TaskExecution> addPhoto(String executionId, {String? localPath}) async {
    final e = await _load(executionId);
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
    final e = await _load(executionId);
    return _save(
      e.copyWith(photos: e.photos.where((p) => p.id != photoId).toList()),
    );
  }

  @override
  Future<TaskExecution> finish(String executionId) async {
    final e = await _load(executionId);
    return _save(e.copyWith(
      status: ExecutionStatus.completed,
      finishedAt: DateTime.now(),
    ));
  }
}
