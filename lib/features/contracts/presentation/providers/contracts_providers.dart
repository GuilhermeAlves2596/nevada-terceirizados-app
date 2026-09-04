import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/contract.dart';

final contractsProvider =
    FutureProvider.autoDispose<List<Contract>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  final scope = ref.watch(dataScopeProvider);
  final contracts =
      await ref.watch(contractRepositoryProvider).getAll(companyId: companyId);
  return contracts.where((c) => scope.allowsContract(c.id)).toList();
});
