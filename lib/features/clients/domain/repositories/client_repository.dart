import '../entities/client.dart';

abstract interface class ClientRepository {
  Future<List<Client>> getAll({required String companyId});
  Future<Client?> getById(String id);
}
