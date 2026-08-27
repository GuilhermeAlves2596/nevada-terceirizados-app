import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/contract_status.dart';

part 'contract.freezed.dart';

/// Contrato entre a empresa terceirizada e um cliente (seção 12).
///
/// Ex.: Nevada → Prefeitura → "Contrato de Limpeza 2026".
@freezed
abstract class Contract with _$Contract {
  const factory Contract({
    required String id,
    required String companyId,
    required String clientId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    @Default(ContractStatus.active) ContractStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Contract;
}
