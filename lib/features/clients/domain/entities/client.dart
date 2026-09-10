import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';

/// Cliente de uma empresa terceirizada (seção 11).
///
/// Ex.: a Nevada tem como cliente a "Prefeitura Municipal".
@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    required String companyId,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,

    /// Tipo de cliente (cadastrado pelo gestor no painel web). Usado para
    /// vincular os checklists padrão ao cliente pelo seu tipo.
    String? clientTypeId,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Client;
}
