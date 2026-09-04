import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Funcionários visíveis: todos da empresa (gestor/admin) ou só os dos contratos
/// do supervisor.
final employeesProvider =
    FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  final scope = ref.watch(dataScopeProvider);
  final employees =
      await ref.watch(userRepositoryProvider).getEmployees(companyId: companyId);
  return employees.where((u) => scope.allowsEmployee(u.contractIds)).toList();
});

/// Supervisores da empresa (visão do gestor, para vincular a contratos). Não é
/// filtrado por escopo — o gestor enxerga todos.
final companySupervisorsProvider =
    FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  final all =
      await ref.watch(userRepositoryProvider).getAll(companyId: companyId);
  return all.where((u) => u.isSupervisor).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
});
