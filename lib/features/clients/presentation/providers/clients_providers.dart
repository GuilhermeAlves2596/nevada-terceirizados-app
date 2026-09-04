import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/client.dart';

/// Clientes visíveis ao usuário: todos da empresa (gestor/admin) ou só os do
/// escopo de contratos do supervisor.
final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  final scope = ref.watch(dataScopeProvider);
  final clients =
      await ref.watch(clientRepositoryProvider).getAll(companyId: companyId);
  return clients.where((c) => scope.allowsClient(c.id)).toList();
});
