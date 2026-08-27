/// Perfis de acesso do sistema (seção 7 do briefing).
enum UserRole {
  employee,
  supervisor,
  platformAdmin;

  /// Rótulo amigável em português para exibição na interface.
  String get label => switch (this) {
        UserRole.employee => 'Funcionário',
        UserRole.supervisor => 'Supervisor',
        UserRole.platformAdmin => 'Admin da Plataforma',
      };

  bool get isEmployee => this == UserRole.employee;
  bool get isSupervisor => this == UserRole.supervisor;
  bool get isPlatformAdmin => this == UserRole.platformAdmin;

  /// Converte a partir do valor persistido (Firestore/JSON), com fallback seguro.
  static UserRole fromName(String? value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.employee,
      );
}
