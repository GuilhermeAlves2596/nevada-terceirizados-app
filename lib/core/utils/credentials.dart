import 'dart:math';

/// Utilidades de credenciais para o login por CPF.
///
/// O Firebase Auth exige um e-mail como identidade, então derivamos um
/// **e-mail sintético interno** a partir do CPF. O usuário nunca vê esse
/// e-mail — ele digita apenas o CPF.
abstract final class Credentials {
  const Credentials._();

  /// Domínio interno (não recebe e-mails de verdade).
  static const cpfEmailDomain = 'func.nevada.app';

  /// Mantém apenas os dígitos do CPF.
  static String cpfDigits(String cpf) => cpf.replaceAll(RegExp(r'\D'), '');

  /// E-mail sintético usado como identidade no Firebase Auth.
  static String syntheticEmailForCpf(String cpf) =>
      '${cpfDigits(cpf)}@$cpfEmailDomain';

  /// Formata um CPF (11 dígitos) como 000.000.000-00; se não tiver 11 dígitos,
  /// retorna o valor original.
  static String formatCpf(String cpf) {
    final d = cpfDigits(cpf);
    if (d.length != 11) return cpf;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  /// Mantém apenas os dígitos de um telefone.
  static String phoneDigits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  /// Formata um telefone brasileiro: (DD) 9XXXX-XXXX (11 dígitos) ou
  /// (DD) XXXX-XXXX (10 dígitos). Fora disso, retorna o valor original.
  static String formatPhone(String phone) {
    final d = phoneDigits(phone);
    if (d.length == 11) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    }
    if (d.length == 10) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    }
    return phone;
  }

  /// Um identificador é tratado como e-mail quando contém "@"; caso contrário
  /// é interpretado como CPF.
  static bool looksLikeEmail(String identifier) => identifier.contains('@');

  /// Resolve o identificador (CPF ou e-mail) no e-mail usado pelo Firebase.
  static String resolveLoginEmail(String identifier) {
    final value = identifier.trim();
    return looksLikeEmail(value) ? value.toLowerCase() : syntheticEmailForCpf(value);
  }

  /// Gera uma senha temporária legível (8 caracteres, sem ambíguos).
  static String generateTempPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
