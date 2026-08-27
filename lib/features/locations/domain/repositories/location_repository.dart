import '../entities/location.dart';

abstract interface class LocationRepository {
  Future<List<Location>> getAll({required String companyId});
  Future<Location?> getById(String id);

  /// Resolve um local a partir do identificador embutido no QR Code (seção 19).
  Future<Location?> getByQrCodeId({
    required String companyId,
    required String qrCodeId,
  });

  /// Cadastra um ambiente. Um [Location.qrCodeId] opaco é gerado
  /// automaticamente (o QR físico é gerado a partir dele na Fase 5).
  Future<Location> create({
    required String companyId,
    required String clientId,
    required String contractId,
    required String name,
    String? description,
    String? address,
    String? parentLocationId,
  });
}
