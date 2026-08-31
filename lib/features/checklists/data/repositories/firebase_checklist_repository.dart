import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/service_type.dart';
import '../../../../core/utils/firestore_converters.dart';
import '../../domain/entities/checklist.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/repositories/checklist_repository.dart';

ChecklistItem _itemFromMap(Map<String, dynamic> m) => ChecklistItem(
      id: (m['id'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      order: (m['order'] as num?)?.toInt() ?? 0,
      required: (m['required'] as bool?) ?? true,
    );

Map<String, dynamic> _itemToMap(ChecklistItem i) => {
      'id': i.id,
      'description': i.description,
      'order': i.order,
      'required': i.required,
    };

Checklist checklistFromDoc(String id, Map<String, dynamic> d) {
  final rawItems = (d['items'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(_itemFromMap)
      .toList();
  return Checklist(
    id: id,
    companyId: (d['companyId'] as String?) ?? '',
    name: (d['name'] as String?) ?? '',
    serviceType: ServiceType.fromName(d['serviceType'] as String?),
    description: d['description'] as String?,
    clientId: d['clientId'] as String?,
    contractId: d['contractId'] as String?,
    items: rawItems,
    active: (d['active'] as bool?) ?? true,
    createdAt: fsDate(d['createdAt']),
    updatedAt: fsDate(d['updatedAt']),
  );
}

Map<String, dynamic> checklistToMap(Checklist c) => {
      'companyId': c.companyId,
      'name': c.name,
      'serviceType': c.serviceType.name,
      'description': c.description,
      'clientId': c.clientId,
      'contractId': c.contractId,
      'items': c.items.map(_itemToMap).toList(),
      'active': c.active,
      'createdAt': fsTs(c.createdAt),
      'updatedAt': fsTs(c.updatedAt),
    };

class FirebaseChecklistRepository implements ChecklistRepository {
  FirebaseChecklistRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('checklists');

  @override
  Future<List<Checklist>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    return snap.docs.map((d) => checklistFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<Checklist?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? checklistFromDoc(doc.id, doc.data()!) : null;
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
    final ref = _col.doc();
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
      id: ref.id,
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
    await ref.set(checklistToMap(checklist));
    return checklist;
  }

  @override
  Future<Checklist> update({
    required String id,
    required String name,
    required ServiceType serviceType,
    String? description,
    required List<ChecklistItemInput> items,
  }) async {
    final ref = _col.doc(id);
    final doc = await ref.get();
    if (!doc.exists) throw StateError('Checklist não encontrado.');
    final builtItems = <ChecklistItem>[
      for (var i = 0; i < items.length; i++)
        ChecklistItem(
          id: _uuid.v4(),
          description: items[i].description.trim(),
          order: i + 1,
          required: items[i].required,
        ),
    ];
    final updated = checklistFromDoc(doc.id, doc.data()!).copyWith(
      name: name.trim(),
      serviceType: serviceType,
      description: description?.trim(),
      items: builtItems,
      updatedAt: DateTime.now(),
    );
    await ref.set(checklistToMap(updated));
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
