import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../models/task_view.dart';

/// Uma tarefa específica já resolvida para exibição (header da execução).
final taskViewByIdProvider =
    FutureProvider.autoDispose.family<TaskView?, String>((ref, taskId) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return null;
  final catalog = await ref.watch(companyCatalogProvider.future);
  final task = await ref.watch(taskRepositoryProvider).getById(taskId);
  if (task == null) return null;
  return TaskView.resolve(task, catalog);
});

/// Tarefas do funcionário autenticado, já resolvidas para exibição.
final employeeTaskViewsProvider =
    FutureProvider.autoDispose<List<TaskView>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final companyId = user?.companyId;
  if (user == null || companyId == null) return const [];

  final catalog = await ref.watch(companyCatalogProvider.future);
  final tasks = await ref
      .watch(taskRepositoryProvider)
      .getForEmployee(companyId: companyId, employeeId: user.id);
  return TaskView.resolveAll(tasks, catalog);
});

/// Todas as tarefas da empresa (visão do supervisor).
final supervisorTaskViewsProvider =
    FutureProvider.autoDispose<List<TaskView>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];

  final catalog = await ref.watch(companyCatalogProvider.future);
  final tasks =
      await ref.watch(taskRepositoryProvider).getForCompany(companyId: companyId);
  return TaskView.resolveAll(tasks, catalog);
});
