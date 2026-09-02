import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/task_priority.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/firestore_converters.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

Task taskFromDoc(String id, Map<String, dynamic> d) => Task(
      id: id,
      companyId: (d['companyId'] as String?) ?? '',
      clientId: (d['clientId'] as String?) ?? '',
      contractId: (d['contractId'] as String?) ?? '',
      locationId: (d['locationId'] as String?) ?? '',
      checklistId: (d['checklistId'] as String?) ?? '',
      assignedTo: (d['assignedTo'] as String?) ?? '',
      assignedBy: (d['assignedBy'] as String?) ?? '',
      scheduledDate: fsDateOnly(d['scheduledDate']),
      scheduledStartTime: d['scheduledStartTime'] as String?,
      priority: TaskPriority.fromName(d['priority'] as String?),
      status: TaskStatus.fromName(d['status'] as String?),
      progress: (d['progress'] as num?)?.toInt() ?? 0,
      createdAt: fsDate(d['createdAt']),
      updatedAt: fsDate(d['updatedAt']),
    );

Map<String, dynamic> taskToMap(Task t) => {
      'companyId': t.companyId,
      'clientId': t.clientId,
      'contractId': t.contractId,
      'locationId': t.locationId,
      'checklistId': t.checklistId,
      'assignedTo': t.assignedTo,
      'assignedBy': t.assignedBy,
      'scheduledDate': dateOnlyTs(t.scheduledDate),
      'scheduledStartTime': t.scheduledStartTime,
      'priority': t.priority.name,
      'status': t.status.name,
      'progress': t.progress,
      'createdAt': fsTs(t.createdAt),
      'updatedAt': fsTs(t.updatedAt),
    };

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('tasks');

  void _sort(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.status.isOpen != b.status.isOpen) return a.status.isOpen ? -1 : 1;
      final byDate = a.scheduledDate.compareTo(b.scheduledDate);
      if (byDate != 0) return byDate;
      return (a.scheduledStartTime ?? '').compareTo(b.scheduledStartTime ?? '');
    });
  }

  @override
  Future<List<Task>> getForEmployee({
    required String companyId,
    required String employeeId,
  }) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    final list = snap.docs
        .map((d) => taskFromDoc(d.id, d.data()))
        .where((t) => t.assignedTo == employeeId)
        .toList();
    _sort(list);
    return list;
  }

  @override
  Future<List<Task>> getForCompany({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    final list = snap.docs.map((d) => taskFromDoc(d.id, d.data())).toList();
    _sort(list);
    return list;
  }

  @override
  Future<Task?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? taskFromDoc(doc.id, doc.data()!) : null;
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
    final ref = _col.doc();
    final now = DateTime.now();
    final task = Task(
      id: ref.id,
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
    await ref.set(taskToMap(task));
    return task;
  }

  @override
  Future<Task> update({
    required String id,
    required String clientId,
    required String contractId,
    required String locationId,
    required String checklistId,
    required String assignedTo,
    required DateTime scheduledDate,
    String? scheduledStartTime,
    required TaskPriority priority,
  }) async {
    final ref = _col.doc(id);
    final doc = await ref.get();
    if (!doc.exists) throw const NotFoundException('Tarefa não encontrada.');
    final updated = taskFromDoc(doc.id, doc.data()!).copyWith(
      clientId: clientId,
      contractId: contractId,
      locationId: locationId,
      checklistId: checklistId,
      assignedTo: assignedTo,
      scheduledDate: scheduledDate,
      scheduledStartTime: scheduledStartTime,
      priority: priority,
      updatedAt: DateTime.now(),
    );
    await ref.set(taskToMap(updated));
    return updated;
  }

  @override
  Future<Task> setStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final ref = _col.doc(taskId);
    await ref.update({'status': status.name, 'updatedAt': Timestamp.now()});
    final doc = await ref.get();
    if (!doc.exists) throw const NotFoundException('Tarefa não encontrada.');
    return taskFromDoc(doc.id, doc.data()!);
  }

  @override
  Future<void> delete(String taskId) async {
    // Remove a tarefa e as execuções vinculadas. A query de execuções filtra
    // por companyId (derivado da própria tarefa) para satisfazer as Security
    // Rules — uma query sem companyId é negada por inteiro.
    final taskDoc = await _col.doc(taskId).get();
    if (!taskDoc.exists) throw const NotFoundException('Tarefa não encontrada.');
    final companyId = (taskDoc.data()!['companyId'] as String?) ?? '';
    final execs = await _firestore
        .collection('taskExecutions')
        .where('companyId', isEqualTo: companyId)
        .where('taskId', isEqualTo: taskId)
        .get();
    final batch = _firestore.batch();
    for (final e in execs.docs) {
      batch.delete(e.reference);
    }
    batch.delete(_col.doc(taskId));
    await batch.commit();
  }
}
