import 'package:uuid/uuid.dart';

import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class MockClientRepository implements ClientRepository {
  MockClientRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

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

  @override
  Future<Client> create({
    required String companyId,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final client = Client(
      id: _uuid.v4(),
      companyId: companyId,
      name: name.trim(),
      document: document?.trim(),
      phone: phone?.trim(),
      email: email?.trim(),
      address: address?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertClient(client);
    return client;
  }
}
