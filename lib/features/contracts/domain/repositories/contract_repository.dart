import '../entities/contract.dart';

abstract interface class ContractRepository {
  Future<List<Contract>> getAll({required String companyId});
  Future<List<Contract>> getByClient({
    required String companyId,
    required String clientId,
  });
  Future<Contract?> getById(String id);
}
