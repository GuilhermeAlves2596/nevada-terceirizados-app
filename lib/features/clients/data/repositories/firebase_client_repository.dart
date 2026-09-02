import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_converters.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

Client clientFromDoc(String id, Map<String, dynamic> d) => Client(
      id: id,
      companyId: (d['companyId'] as String?) ?? '',
      name: (d['name'] as String?) ?? '',
      document: d['document'] as String?,
      phone: d['phone'] as String?,
      email: d['email'] as String?,
      address: d['address'] as String?,
      active: (d['active'] as bool?) ?? true,
      createdAt: fsDate(d['createdAt']),
      updatedAt: fsDate(d['updatedAt']),
    );

Map<String, dynamic> clientToMap(Client c) => {
      'companyId': c.companyId,
      'name': c.name,
      'document': c.document,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'active': c.active,
      'createdAt': fsTs(c.createdAt),
      'updatedAt': fsTs(c.updatedAt),
    };

class FirebaseClientRepository implements ClientRepository {
  FirebaseClientRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('clients');

  @override
  Future<List<Client>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    final list = snap.docs.map((d) => clientFromDoc(d.id, d.data())).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Client?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? clientFromDoc(doc.id, doc.data()!) : null;
  }

  @override
  Future<Client> create({
    required String companyId,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,
  }) async {
    final ref = _col.doc();
    final now = DateTime.now();
    final client = Client(
      id: ref.id,
      companyId: companyId,
      name: name.trim(),
      document: document?.trim(),
      phone: phone?.trim(),
      email: email?.trim(),
      address: address?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(clientToMap(client));
    return client;
  }

  @override
  Future<Client> update({
    required String id,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,
  }) async {
    final ref = _col.doc(id);
    final doc = await ref.get();
    if (!doc.exists) throw StateError('Cliente não encontrado.');
    final current = clientFromDoc(doc.id, doc.data()!);
    final updated = current.copyWith(
      name: name.trim(),
      document: document?.trim(),
      phone: phone?.trim(),
      email: email?.trim(),
      address: address?.trim(),
      updatedAt: DateTime.now(),
    );
    await ref.set(clientToMap(updated));
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
