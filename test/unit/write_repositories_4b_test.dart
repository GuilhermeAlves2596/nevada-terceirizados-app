import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/enums/contract_status.dart';
import 'package:nevada_terceirizados/core/enums/service_type.dart';
import 'package:nevada_terceirizados/core/mock/mock_database.dart';
import 'package:nevada_terceirizados/features/checklists/data/repositories/mock_checklist_repository.dart';
import 'package:nevada_terceirizados/features/contracts/data/repositories/mock_contract_repository.dart';
import 'package:nevada_terceirizados/features/locations/data/repositories/mock_location_repository.dart';

void main() {
  const companyId = MockDatabase.companyNevada;

  test('contract create adiciona contrato com situação', () async {
    final db = MockDatabase.seeded();
    final repo = MockContractRepository(db);

    final c = await repo.create(
      companyId: companyId,
      clientId: MockDatabase.clientAbc,
      name: 'Contrato Portaria 2026',
      status: ContractStatus.active,
    );

    expect(c.status, ContractStatus.active);
    final all = await repo.getAll(companyId: companyId);
    expect(all.any((x) => x.id == c.id), isTrue);
  });

  test('location create gera qrCodeId e é resolvível por ele', () async {
    final db = MockDatabase.seeded();
    final repo = MockLocationRepository(db);

    final l = await repo.create(
      companyId: companyId,
      clientId: MockDatabase.clientPrefeitura,
      contractId: MockDatabase.contractLimpeza2026,
      name: 'Sala 10',
    );

    expect(l.qrCodeId, isNotNull);
    final found = await repo.getByQrCodeId(
      companyId: companyId,
      qrCodeId: l.qrCodeId!,
    );
    expect(found?.id, l.id);
  });

  test('checklist create constrói itens ordenados com obrigatoriedade', () async {
    final db = MockDatabase.seeded();
    final repo = MockChecklistRepository(db);

    final c = await repo.create(
      companyId: companyId,
      name: 'Rotina de teste',
      serviceType: ServiceType.jardinagem,
      items: const [
        (description: 'Passo 1', required: true),
        (description: 'Passo 2', required: false),
      ],
    );

    expect(c.totalItems, 2);
    expect(c.serviceType, ServiceType.jardinagem);
    expect(c.orderedItems.first.order, 1);
    expect(c.orderedItems.first.required, isTrue);
    expect(c.orderedItems.last.required, isFalse);
  });
}
