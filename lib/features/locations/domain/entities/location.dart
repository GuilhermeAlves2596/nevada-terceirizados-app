import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

/// Local/ambiente onde o serviço é executado (seção 13).
///
/// Suporta hierarquia via [parentLocationId] (ex.: Prédio → Bloco A → Banheiro).
/// Cada ambiente "folha" possui um QR Code físico identificado por [qrCodeId].
@freezed
abstract class Location with _$Location {
  const factory Location({
    required String id,
    required String companyId,
    required String clientId,
    required String contractId,
    required String name,
    String? description,
    String? address,
    String? parentLocationId,

    /// Identificador opaco embutido no QR Code físico do ambiente (seção 19).
    String? qrCodeId,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Location;
}
