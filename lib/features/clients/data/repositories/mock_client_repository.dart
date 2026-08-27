import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class MockClientRepository implements ClientRepository {
  MockClientRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<Client>> getAll({required String companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.clients.where((c) => c.companyId == companyId).toList();
  }

  @override
  Future<Client?> getById(String id) async {
    for (final c in _db.clients) {
      if (c.id == id) return c;
    }
    return null;
  }
}
