import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/core/enums/task_priority.dart';
import 'package:nevada_terceirizados/core/enums/task_status.dart';
import 'package:nevada_terceirizados/core/enums/user_role.dart';
import 'package:nevada_terceirizados/core/errors/app_exception.dart';
import 'package:nevada_terceirizados/core/mock/mock_database.dart';
import 'package:nevada_terceirizados/features/clients/data/repositories/mock_client_repository.dart';
import 'package:nevada_terceirizados/features/employees/data/repositories/mock_user_repository.dart';
import 'package:nevada_terceirizados/features/tasks/data/repositories/mock_task_repository.dart';

void main() {
  const companyId = MockDatabase.companyNevada;

  test('createEmployee cria funcionário com CPF e senha temporária', () async {
    final db = MockDatabase.seeded();
    final repo = MockUserRepository(db);

    final result = await repo.createEmployee(
      companyId: companyId,
      contractId: MockDatabase.contractLimpeza2026,
      clientId: MockDatabase.clientPrefeitura,
      name: 'Ana Souza',
      cpf: '111.222.333-44',
    );

    expect(result.user.role, UserRole.employee);
    expect(result.user.active, isTrue);
    expect(result.user.companyId, companyId);
    expect(result.user.cpf, '11122233344'); // só dígitos
    // Passo 4: herda o contrato/cliente informado.
    expect(result.user.contractIds, [MockDatabase.contractLimpeza2026]);
    expect(result.user.clientIds, [MockDatabase.clientPrefeitura]);
    expect(result.user.mustChangePassword, isTrue);
    expect(result.temporaryPassword.length, greaterThanOrEqualTo(6));

    final employees = await repo.getEmployees(companyId: companyId);
    expect(employees.any((e) => e.id == result.user.id), isTrue);
  });

  test('createEmployee rejeita CPF duplicado', () async {
    final db = MockDatabase.seeded();
    final repo = MockUserRepository(db);

    await repo.createEmployee(
      companyId: companyId,
      contractId: MockDatabase.contractLimpeza2026,
      clientId: MockDatabase.clientPrefeitura,
      name: 'Primeiro',
      cpf: '55566677788',
    );

    expect(
      () => repo.createEmployee(
        companyId: companyId,
        contractId: MockDatabase.contractLimpeza2026,
        clientId: MockDatabase.clientPrefeitura,
        name: 'Segundo',
        cpf: '555.666.777-88',
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('client create adiciona cliente à empresa', () async {
    final db = MockDatabase.seeded();
    final repo = MockClientRepository(db);
    final before = (await repo.getAll(companyId: companyId)).length;

    await repo.create(companyId: companyId, name: 'Novo Cliente');

    final after = await repo.getAll(companyId: companyId);
    expect(after.length, before + 1);
    expect(after.any((c) => c.name == 'Novo Cliente'), isTrue);
  });

  test('task create gera tarefa pendente e aparece na empresa', () async {
    final db = MockDatabase.seeded();
    final repo = MockTaskRepository(db);

    final task = await repo.create(
      companyId: companyId,
      clientId: MockDatabase.clientPrefeitura,
      contractId: MockDatabase.contractLimpeza2026,
      locationId: MockDatabase.locRecepcao,
      checklistId: MockDatabase.chkRecepcao,
      assignedTo: MockDatabase.userMaria,
      assignedBy: MockDatabase.userCarlos,
      scheduledDate: DateTime(2026, 9, 1),
      priority: TaskPriority.high,
    );

    expect(task.status, TaskStatus.pending);
    expect(task.progress, 0);

    final all = await repo.getForCompany(companyId: companyId);
    expect(all.any((t) => t.id == task.id), isTrue);
  });
}
