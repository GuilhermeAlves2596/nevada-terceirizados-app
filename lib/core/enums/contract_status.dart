/// Situação de um contrato (seção 12).
enum ContractStatus {
  active,
  inactive,
  expired;

  String get label => switch (this) {
        ContractStatus.active => 'Ativo',
        ContractStatus.inactive => 'Inativo',
        ContractStatus.expired => 'Expirado',
      };

  static ContractStatus fromName(String? value) => ContractStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ContractStatus.active,
      );
}
