import '../entities/client.dart';

abstract interface class ClientRepository {
  Future<List<Client>> getAll({required String companyId});
  Future<Client?> getById(String id);

  Future<Client> create({
    required String companyId,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,
  });
}
