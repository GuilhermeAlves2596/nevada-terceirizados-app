import 'package:uuid/uuid.dart';

import '../../../../core/enums/contract_status.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';

class MockContractRepository implements ContractRepository {
  MockContractRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final contract = Contract(
      id: _uuid.v4(),
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
    _db.upsertContract(contract);
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
    final current = _db.contracts.firstWhere((c) => c.id == id);
    final updated = current.copyWith(
      clientId: clientId,
      name: name.trim(),
      description: description?.trim(),
      startDate: startDate,
      endDate: endDate,
      status: status,
      updatedAt: DateTime.now(),
    );
    _db.upsertContract(updated);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _db.contracts.removeWhere((c) => c.id == id);
  }
}
