import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/contract_status.dart';
import '../../../../core/utils/firestore_converters.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';

Contract contractFromDoc(String id, Map<String, dynamic> d) => Contract(
      id: id,
      companyId: (d['companyId'] as String?) ?? '',
      clientId: (d['clientId'] as String?) ?? '',
      name: (d['name'] as String?) ?? '',
      description: d['description'] as String?,
      startDate: d['startDate'] == null ? null : fsDate(d['startDate']),
      endDate: d['endDate'] == null ? null : fsDate(d['endDate']),
      status: ContractStatus.fromName(d['status'] as String?),
      createdAt: fsDate(d['createdAt']),
      updatedAt: fsDate(d['updatedAt']),
    );

Map<String, dynamic> contractToMap(Contract c) => {
      'companyId': c.companyId,
      'clientId': c.clientId,
      'name': c.name,
      'description': c.description,
      'startDate': c.startDate == null ? null : fsTs(c.startDate!),
      'endDate': c.endDate == null ? null : fsTs(c.endDate!),
      'status': c.status.name,
      'createdAt': fsTs(c.createdAt),
      'updatedAt': fsTs(c.updatedAt),
    };

class FirebaseContractRepository implements ContractRepository {
  FirebaseContractRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('contracts');

  @override
  Future<List<Contract>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    return snap.docs.map((d) => contractFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<List<Contract>> getByClient({
    required String companyId,
    required String clientId,
  }) async {
    final all = await getAll(companyId: companyId);
    return all.where((c) => c.clientId == clientId).toList();
  }

  @override
  Future<Contract?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? contractFromDoc(doc.id, doc.data()!) : null;
  }

  @override
  Future<Contract> create({
    required String companyId,
    required String clientId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required ContractStatus status,
  }) async {
    final ref = _col.doc();
    final now = DateTime.now();
    final contract = Contract(
      id: ref.id,
      companyId: companyId,
      clientId: clientId,
      name: name.trim(),
      description: description?.trim(),
      startDate: startDate,
      endDate: endDate,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(contractToMap(contract));
    return contract;
  }

  @override
  Future<Contract> update({
    required String id,
    required String clientId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required ContractStatus status,
  }) async {
    final ref = _col.doc(id);
    final doc = await ref.get();
    if (!doc.exists) throw StateError('Contrato não encontrado.');
    final updated = contractFromDoc(doc.id, doc.data()!).copyWith(
      clientId: clientId,
      name: name.trim(),
      description: description?.trim(),
      startDate: startDate,
      endDate: endDate,
      status: status,
      updatedAt: DateTime.now(),
    );
    await ref.set(contractToMap(updated));
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
