import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Funcionários (role employee) da empresa do supervisor autenticado.
final employeesProvider =
    FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  return ref.watch(userRepositoryProvider).getEmployees(companyId: companyId);
});
