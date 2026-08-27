import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';

class MockContractRepository implements ContractRepository {
  MockContractRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<Contract>> getAll({required String companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.contracts.where((c) => c.companyId == companyId).toList();
  }

  @override
  Future<List<Contract>> getByClient({
    required String companyId,
    required String clientId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.contracts
        .where((c) => c.companyId == companyId && c.clientId == clientId)
        .toList();
  }

  @override
  Future<Contract?> getById(String id) async {
    for (final c in _db.contracts) {
      if (c.id == id) return c;
    }
    return null;
  }
}
