import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/utils/credentials.dart';

void main() {
  test('cpfDigits remove formatação', () {
    expect(Credentials.cpfDigits('111.222.333-44'), '11122233344');
    expect(Credentials.cpfDigits('11122233344'), '11122233344');
  });

  test('e-mail sintético é derivado do CPF', () {
    expect(
      Credentials.syntheticEmailForCpf('111.222.333-44'),
      '11122233344@func.nevada.app',
    );
  });

  test('resolveLoginEmail: CPF vira e-mail sintético; e-mail passa direto', () {
    expect(
      Credentials.resolveLoginEmail('111.222.333-44'),
      '11122233344@func.nevada.app',
    );
    expect(
      Credentials.resolveLoginEmail('Supervisor@Teste.com'),
      'supervisor@teste.com',
    );
  });

  test('formatCpf formata 11 dígitos', () {
    expect(Credentials.formatCpf('11122233344'), '111.222.333-44');
    expect(Credentials.formatCpf('123'), '123'); // inválido: retorna original
  });

  test('senha temporária tem 8 caracteres', () {
    expect(Credentials.generateTempPassword().length, 8);
  });
}
