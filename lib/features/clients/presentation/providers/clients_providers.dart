import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/client.dart';

/// Clientes da empresa do supervisor autenticado.
final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  return ref.watch(clientRepositoryProvider).getAll(companyId: companyId);
});
