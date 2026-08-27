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

  test('createEmployee cadastra funcionário ativo com role employee', () async {
    final db = MockDatabase.seeded();
    final repo = MockUserRepository(db);

    final created = await repo.createEmployee(
      companyId: companyId,
      name: 'Ana Souza',
      email: 'ana@teste.com',
    );

    expect(created.role, UserRole.employee);
    expect(created.active, isTrue);
    expect(created.companyId, companyId);

    final employees = await repo.getEmployees(companyId: companyId);
    expect(employees.any((e) => e.id == created.id), isTrue);
  });

  test('createEmployee rejeita e-mail duplicado', () async {
    final db = MockDatabase.seeded();
    final repo = MockUserRepository(db);

    expect(
      () => repo.createEmployee(
        companyId: companyId,
        name: 'Outro',
        email: 'supervisor@teste.com', // já existe no seed
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
