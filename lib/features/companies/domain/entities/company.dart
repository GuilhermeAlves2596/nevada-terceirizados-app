import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/subscription_status.dart';

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

    /// Plano contratado (rótulo livre por enquanto, ex.: "basic"/"pro").
    String? plan,

    /// Situação da assinatura — controla o acesso da empresa ao SaaS.
    @Default(SubscriptionStatus.trial) SubscriptionStatus subscriptionStatus,

    /// Nº de assentos (usuários) contratados; nulo = sem limite definido.
    int? seats,
    @Default(true) bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Company;
}
