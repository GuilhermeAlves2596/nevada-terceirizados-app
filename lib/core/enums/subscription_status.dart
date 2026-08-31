/// Situação da assinatura de uma empresa-tenant no SaaS.
///
/// Controlada **manualmente** por enquanto (cobrança por fora — boleto/PIX);
/// o gateway de pagamento fica para depois. O app apenas **respeita** este
/// status; o bloqueio real de acesso será reforçado server-side nas Firestore
/// Security Rules (Fase 12), não só no cliente.
enum SubscriptionStatus {
  /// Período de avaliação (empresa recém-criada, ainda sem pagamento).
  trial,

  /// Assinatura em dia — acesso liberado.
  active,

  /// Inadimplente/pausada — acesso deve ser bloqueado.
  suspended,

  /// Encerrada — empresa deixou o SaaS.
  canceled;

  String get label => switch (this) {
        SubscriptionStatus.trial => 'Avaliação',
        SubscriptionStatus.active => 'Ativa',
        SubscriptionStatus.suspended => 'Suspensa',
        SubscriptionStatus.canceled => 'Cancelada',
      };

  /// A empresa pode usar o sistema? (trial e active liberam.)
  bool get grantsAccess =>
      this == SubscriptionStatus.trial || this == SubscriptionStatus.active;

  static SubscriptionStatus fromName(String? value) =>
      SubscriptionStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => SubscriptionStatus.active,
      );
}
