import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/checklists/data/repositories/firebase_checklist_repository.dart';
import '../../features/checklists/domain/repositories/checklist_repository.dart';
import '../../features/clients/data/repositories/firebase_client_repository.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/contracts/data/repositories/firebase_contract_repository.dart';
import '../../features/contracts/domain/repositories/contract_repository.dart';
import '../../features/employees/data/repositories/firebase_user_repository.dart';
import '../../features/employees/domain/repositories/user_repository.dart';
import '../../features/executions/data/repositories/firebase_task_execution_repository.dart';
import '../../features/executions/domain/repositories/task_execution_repository.dart';
import '../../features/locations/data/repositories/firebase_location_repository.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/tasks/data/repositories/firebase_task_repository.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

/// Ponto único de composição das dependências (Dependency Injection).
///
/// A partir da Fase 9, todos os repositórios apontam para o **Firebase**
/// (Firestore). O domínio e a apresentação permanecem intactos — a troca
/// aconteceu apenas aqui.

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Cloud Functions na região das functions (southamerica-east1).
final functionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'southamerica-east1');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    ref.watch(firestoreProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  );
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return FirebaseClientRepository(ref.watch(firestoreProvider));
});

final contractRepositoryProvider = Provider<ContractRepository>((ref) {
  return FirebaseContractRepository(ref.watch(firestoreProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return FirebaseLocationRepository(ref.watch(firestoreProvider));
});

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return FirebaseChecklistRepository(ref.watch(firestoreProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository(ref.watch(firestoreProvider));
});

final taskExecutionRepositoryProvider =
    Provider<TaskExecutionRepository>((ref) {
  return FirebaseTaskExecutionRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  );
});
