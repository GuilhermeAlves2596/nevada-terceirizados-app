import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/mock/mock_database.dart';
import 'package:nevada_terceirizados/features/locations/data/repositories/mock_location_repository.dart';
import 'package:nevada_terceirizados/features/qr_code/domain/qr_payload.dart';
import 'package:nevada_terceirizados/features/qr_code/domain/qr_resolver.dart';
import 'package:nevada_terceirizados/features/tasks/data/repositories/mock_task_repository.dart';

void main() {
  group('QrPayload', () {
    test('encode/decode roundtrip', () {
      const code = 'QR-NVD-0001';
      final encoded = const QrPayload(code: code).encode();
      final decoded = QrPayload.tryDecode(encoded);
      expect(decoded?.code, code);
    });

    test('aceita código puro (digitação manual)', () {
      expect(QrPayload.tryDecode('  qr-abc  ')?.code, 'qr-abc');
    });

    test('rejeita vazio e JSON de outro tipo', () {
      expect(QrPayload.tryDecode(''), isNull);
      expect(QrPayload.tryDecode('   '), isNull);
      expect(QrPayload.tryDecode('{"type":"other","code":"x"}'), isNull);
    });
  });

  group('QrResolver', () {
    QrResolver build(MockDatabase db) =>
        QrResolver(MockLocationRepository(db), MockTaskRepository(db));

    test('abre a tarefa aberta do funcionário no ambiente', () async {
      final db = MockDatabase.seeded();
      final result = await build(db).resolve(
        companyId: MockDatabase.companyNevada,
        employeeId: MockDatabase.userJoao,
        rawPayload: 'QR-NVD-0001', // Banheiro Bloco A (João tem tarefa aberta)
      );
      expect(result, isA<QrResolveSuccess>());
      expect((result as QrResolveSuccess).locationName, 'Banheiro Bloco A');
    });

    test('QR de outra empresa não resolve (isolamento)', () async {
      final db = MockDatabase.seeded();
      final result = await build(db).resolve(
        companyId: 'company_outra',
        employeeId: MockDatabase.userJoao,
        rawPayload: 'QR-NVD-0001',
      );
      expect(result, isA<QrResolveFailure>());
      expect((result as QrResolveFailure).message, contains('não encontrado'));
    });

    test('sem tarefa aberta no ambiente informa o funcionário', () async {
      final db = MockDatabase.seeded();
      // Área Externa: João tem apenas tarefa concluída lá.
      final result = await build(db).resolve(
        companyId: MockDatabase.companyNevada,
        employeeId: MockDatabase.userJoao,
        rawPayload: 'QR-NVD-0004',
      );
      expect(result, isA<QrResolveFailure>());
    });

    test('payload inválido retorna falha', () async {
      final db = MockDatabase.seeded();
      final result = await build(db).resolve(
        companyId: MockDatabase.companyNevada,
        employeeId: MockDatabase.userJoao,
        rawPayload: '',
      );
      expect(result, isA<QrResolveFailure>());
    });
  });
}
