/// Perfis de acesso do sistema (seção 7 do briefing).
///
/// Hierarquia (do topo para a base):
/// [platformAdmin] (dono do SaaS) → [companyAdmin] (gestor da empresa-tenant) →
/// [supervisor] (operação em campo) → [employee] (execução).
enum UserRole {
  employee,
  supervisor,
  companyAdmin,
  platformAdmin;

  /// Rótulo amigável em português para exibição na interface.
  String get label => switch (this) {
        UserRole.employee => 'Funcionário',
        UserRole.supervisor => 'Supervisor',
        UserRole.companyAdmin => 'Gestor da Empresa',
        UserRole.platformAdmin => 'Admin da Plataforma',
      };

  bool get isEmployee => this == UserRole.employee;
  bool get isSupervisor => this == UserRole.supervisor;
  bool get isCompanyAdmin => this == UserRole.companyAdmin;
  bool get isPlatformAdmin => this == UserRole.platformAdmin;

  /// Converte a partir do valor persistido (Firestore/JSON), com fallback seguro.
  static UserRole fromName(String? value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.employee,
      );
}
