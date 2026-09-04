import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/location.dart';

final locationsProvider =
    FutureProvider.autoDispose<List<Location>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  final scope = ref.watch(dataScopeProvider);
  final locations =
      await ref.watch(locationRepositoryProvider).getAll(companyId: companyId);
  return locations.where((l) => scope.allowsContract(l.contractId)).toList();
});
