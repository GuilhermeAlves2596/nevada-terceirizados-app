import '../../../../core/enums/contract_status.dart';
import '../entities/contract.dart';

abstract interface class ContractRepository {
  Future<List<Contract>> getAll({required String companyId});
  Future<List<Contract>> getByClient({
    required String companyId,
    required String clientId,
  });
  Future<Contract?> getById(String id);

  Future<Contract> create({
    required String companyId,
    required String clientId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    required ContractStatus status,
  });
}
