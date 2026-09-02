import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/firestore_converters.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

Location locationFromDoc(String id, Map<String, dynamic> d) => Location(
      id: id,
      companyId: (d['companyId'] as String?) ?? '',
      clientId: (d['clientId'] as String?) ?? '',
      contractId: (d['contractId'] as String?) ?? '',
      name: (d['name'] as String?) ?? '',
      description: d['description'] as String?,
      address: d['address'] as String?,
      parentLocationId: d['parentLocationId'] as String?,
      qrCodeId: d['qrCodeId'] as String?,
      active: (d['active'] as bool?) ?? true,
      createdAt: fsDate(d['createdAt']),
      updatedAt: fsDate(d['updatedAt']),
    );

Map<String, dynamic> locationToMap(Location l) => {
      'companyId': l.companyId,
      'clientId': l.clientId,
      'contractId': l.contractId,
      'name': l.name,
      'description': l.description,
      'address': l.address,
      'parentLocationId': l.parentLocationId,
      'qrCodeId': l.qrCodeId,
      'active': l.active,
      'createdAt': fsTs(l.createdAt),
      'updatedAt': fsTs(l.updatedAt),
    };

class FirebaseLocationRepository implements LocationRepository {
  FirebaseLocationRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('locations');

  @override
  Future<List<Location>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    return snap.docs.map((d) => locationFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<Location?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? locationFromDoc(doc.id, doc.data()!) : null;
  }

  @override
  Future<Location?> getByQrCodeId({
    required String companyId,
    required String qrCodeId,
  }) async {
    // Filtra por companyId + qrCodeId: além do isolamento multi-tenant, é o que
    // as Security Rules exigem — uma query sem companyId é negada por inteiro.
    final snap = await _col
        .where('companyId', isEqualTo: companyId)
        .where('qrCodeId', isEqualTo: qrCodeId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return locationFromDoc(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<Location> create({
    required String companyId,
    required String clientId,
    required String contractId,
    required String name,
    String? description,
    String? address,
    String? parentLocationId,
  }) async {
    final ref = _col.doc();
    final now = DateTime.now();
    final location = Location(
      id: ref.id,
      companyId: companyId,
      clientId: clientId,
      contractId: contractId,
      name: name.trim(),
      description: description?.trim(),
      address: address?.trim(),
      parentLocationId: parentLocationId,
      qrCodeId: 'QR-${_uuid.v4().substring(0, 8).toUpperCase()}',
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(locationToMap(location));
    return location;
  }
}
