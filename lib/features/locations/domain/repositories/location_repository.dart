import '../entities/location.dart';

abstract interface class LocationRepository {
  Future<List<Location>> getAll({required String companyId});
  Future<Location?> getById(String id);

  /// Resolve um local a partir do identificador embutido no QR Code (seção 19).
  Future<Location?> getByQrCodeId({
    required String companyId,
    required String qrCodeId,
  });
}
