import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

/// Lista das tarefas do funcionário (de hoje) filtradas por status — aberta ao
/// tocar nos cards do dashboard. Tocar numa tarefa abre a execução.
class EmployeeTasksPage extends ConsumerWidget {
  const EmployeeTasksPage({super.key, this.filter});

  /// pending | inProgress | completed | all
  final String? filter;

  (String, bool Function(Task)) _config() {
    return switch (filter) {
      'pending' => ('Pendentes de hoje', (Task t) => t.isPending),
      'inProgress' => ('Em andamento hoje', (Task t) => t.isInProgress),
      'completed' => ('Concluídas hoje', (Task t) => t.isCompleted),
      _ => ('Minhas tarefas de hoje', (Task t) => true),
    };
  }

  bool _isToday(DateTime d, DateTime now) =>
      d.year == now.year && d.month == now.month && d.day == now.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(employeeTaskViewsProvider);
    final (title, predicate) = _config();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
              onRetry: () => ref.invalidate(employeeTaskViewsProvider)),
          data: (all) {
            final items = all
                .where((v) =>
                    _isToday(v.task.scheduledDate, now) && predicate(v.task))
                .toList();
            if (items.isEmpty) {
              return const AppEmptyState(
                icon: Icons.task_alt,
                message: 'Nenhuma tarefa nesta categoria hoje.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(employeeTaskViewsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final v = items[i];
                  return TaskCard(
                    view: v,
                    onTap: () => context
                        .push('${RoutePaths.employeeTasks}/${v.task.id}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
