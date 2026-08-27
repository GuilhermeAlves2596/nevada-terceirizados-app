import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  MockLocationRepository(this._db);

  final MockDatabase _db;

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
}
