import '../../../auth/domain/entities/app_user.dart';

/// Resultado do cadastro de um funcionário: o usuário criado e a **senha
/// temporária** gerada (exibida ao supervisor para repassar ao funcionário).
class NewEmployeeResult {
  const NewEmployeeResult({
    required this.user,
    required this.temporaryPassword,
  });

  final AppUser user;
  final String temporaryPassword;
}
