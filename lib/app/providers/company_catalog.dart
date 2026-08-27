import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/checklists/domain/entities/checklist.dart';
import '../../features/clients/domain/entities/client.dart';
import '../../features/contracts/domain/entities/contract.dart';
import '../../features/locations/domain/entities/location.dart';
import '../di/repository_providers.dart';

/// Coleção de mapas (id → entidade) da empresa atual, para resolver os nomes
/// exibidos nas tarefas sem múltiplas idas ao repositório.
class CompanyCatalog {
  const CompanyCatalog({
    required this.locationsById,
    required this.checklistsById,
    required this.clientsById,
    required this.contractsById,
    required this.usersById,
  });

  const CompanyCatalog.empty()
      : locationsById = const {},
        checklistsById = const {},
        clientsById = const {},
        contractsById = const {},
        usersById = const {};

  final Map<String, Location> locationsById;
  final Map<String, Checklist> checklistsById;
  final Map<String, Client> clientsById;
  final Map<String, Contract> contractsById;
  final Map<String, AppUser> usersById;
}

final companyCatalogProvider =
    FutureProvider.autoDispose<CompanyCatalog>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const CompanyCatalog.empty();

  final results = await Future.wait([
    ref.watch(locationRepositoryProvider).getAll(companyId: companyId),
    ref.watch(checklistRepositoryProvider).getAll(companyId: companyId),
    ref.watch(clientRepositoryProvider).getAll(companyId: companyId),
    ref.watch(userRepositoryProvider).getAll(companyId: companyId),
    ref.watch(contractRepositoryProvider).getAll(companyId: companyId),
  ]);

  return CompanyCatalog(
    locationsById: {for (final l in results[0] as List<Location>) l.id: l},
    checklistsById: {for (final c in results[1] as List<Checklist>) c.id: c},
    clientsById: {for (final c in results[2] as List<Client>) c.id: c},
    usersById: {for (final u in results[3] as List<AppUser>) u.id: u},
    contractsById: {for (final c in results[4] as List<Contract>) c.id: c},
  );
});
