import 'package:uuid/uuid.dart';

import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  MockLocationRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<Location>> getAll({required String companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.locations.where((l) => l.companyId == companyId).toList();
  }

  @override
  Future<Location?> getById(String id) async {
    for (final l in _db.locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  @override
  Future<Location?> getByQrCodeId({
    required String companyId,
    required String qrCodeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final l in _db.locations) {
      if (l.companyId == companyId && l.qrCodeId == qrCodeId) return l;
    }
    return null;
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final qrCodeId = 'QR-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final location = Location(
      id: _uuid.v4(),
      companyId: companyId,
      clientId: clientId,
      contractId: contractId,
      name: name.trim(),
      description: description?.trim(),
      address: address?.trim(),
      parentLocationId: parentLocationId,
      qrCodeId: qrCodeId,
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertLocation(location);
    return location;
  }
}
