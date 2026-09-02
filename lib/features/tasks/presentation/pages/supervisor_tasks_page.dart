import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

class SupervisorTasksPage extends ConsumerWidget {
  const SupervisorTasksPage({super.key, this.filter});

  /// all | pending | inProgress | completed | cancelled | late
  final String? filter;

  (String, bool Function(Task)) _config(DateTime now) {
    return switch (filter) {
      'pending' => ('Pendentes', (Task t) => t.isPending),
      'inProgress' => ('Em andamento', (Task t) => t.isInProgress),
      'completed' => ('Concluídas', (Task t) => t.isCompleted),
      'cancelled' => ('Canceladas', (Task t) => t.isCancelled),
      'late' => ('Atrasadas', (Task t) => t.isLate(now)),
      _ => ('Todas as tarefas', (Task t) => true),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(supervisorTaskViewsProvider);
    final (title, predicate) = _config(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
              onRetry: () => ref.invalidate(supervisorTaskViewsProvider)),
          data: (all) {
            final items = all.where((v) => predicate(v.task)).toList();
            if (items.isEmpty) {
              return const AppEmptyState(
                icon: Icons.assignment_outlined,
                message: 'Nenhuma tarefa nesta categoria.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => refreshSupervisorTasks(ref),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final v = items[i];
                  return TaskCard(
                    view: v,
                    showEmployee: true,
                    onTap: () => context
                        .push('${RoutePaths.supervisorTasks}/${v.task.id}'),
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
