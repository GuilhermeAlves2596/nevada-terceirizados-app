import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';

/// Empresa terceirizada — o *tenant* da plataforma (seções 6 e 9).
///
/// Todo dado do sistema é isolado por [Company.id] (`companyId`).
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    String? document,
    String? logoUrl,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Company;
}
