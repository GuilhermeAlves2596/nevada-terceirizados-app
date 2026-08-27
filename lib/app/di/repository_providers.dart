import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_database.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/checklists/data/repositories/mock_checklist_repository.dart';
import '../../features/checklists/domain/repositories/checklist_repository.dart';
import '../../features/clients/data/repositories/mock_client_repository.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/contracts/data/repositories/mock_contract_repository.dart';
import '../../features/contracts/domain/repositories/contract_repository.dart';
import '../../features/employees/data/repositories/mock_user_repository.dart';
import '../../features/employees/domain/repositories/user_repository.dart';
import '../../features/executions/data/repositories/mock_task_execution_repository.dart';
import '../../features/executions/domain/repositories/task_execution_repository.dart';
import '../../features/locations/data/repositories/mock_location_repository.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/tasks/data/repositories/mock_task_repository.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

/// Ponto único de composição das dependências (Dependency Injection).
///
/// Hoje tudo aponta para implementações *mock*. Ao chegar nas fases de
/// Firebase, basta trocar cada `Mock…Repository` pela versão `Firebase…` aqui —
/// domínio e apresentação permanecem intactos.

/// Base de dados em memória (fonte única durante a fase mock).
final mockDatabaseProvider = Provider<MockDatabase>((ref) {
  return MockDatabase.seeded();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(ref.watch(mockDatabaseProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository(ref.watch(mockDatabaseProvider));
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return MockClientRepository(ref.watch(mockDatabaseProvider));
});

final contractRepositoryProvider = Provider<ContractRepository>((ref) {
  return MockContractRepository(ref.watch(mockDatabaseProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return MockLocationRepository(ref.watch(mockDatabaseProvider));
});

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return MockChecklistRepository(ref.watch(mockDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return MockTaskRepository(ref.watch(mockDatabaseProvider));
});

final taskExecutionRepositoryProvider =
    Provider<TaskExecutionRepository>((ref) {
  return MockTaskExecutionRepository(ref.watch(mockDatabaseProvider));
});
