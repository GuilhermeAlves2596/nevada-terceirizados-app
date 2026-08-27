import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../tasks/presentation/models/task_stats.dart';
import '../../../tasks/presentation/models/task_view.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/dashboard_header.dart';

class SupervisorDashboardPage extends ConsumerWidget {
  const SupervisorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(supervisorTaskViewsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(supervisorTaskViewsProvider.future),
          child: tasksAsync.when(
            loading: () => const _Scroll(
              children: [SizedBox(height: 240, child: AppLoading())],
            ),
            error: (e, _) => _Scroll(
              children: [
                SizedBox(
                  height: 240,
                  child: AppErrorState(
                    onRetry: () => ref.invalidate(supervisorTaskViewsProvider),
                  ),
                ),
              ],
            ),
            data: (tasks) => _Content(tasks: tasks),
          ),
        ),
      ),
    );
  }
}

class _Scroll extends StatelessWidget {
  const _Scroll({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const DashboardHeader(
          subtitle: 'Painel do supervisor',
          profilePath: ProfilePaths.supervisor,
        ),
        AppSpacing.gapLg,
        ...children,
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.tasks});

  final List<TaskView> tasks;

  @override
  Widget build(BuildContext context) {
    final stats = TaskStats.from(tasks.map((v) => v.task).toList());
    final recent = tasks.take(6).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const DashboardHeader(
          subtitle: 'Painel do supervisor',
          profilePath: ProfilePaths.supervisor,
        ),
        AppSpacing.gapLg,
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                value: '${stats.total}',
                label: 'Total',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.inProgress}',
                label: 'Em andamento',
                icon: Icons.play_circle_outline,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.pending}',
                label: 'Pendentes',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                value: '${stats.completed}',
                label: 'Concluídas',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.late}',
                label: 'Atrasadas',
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
        AppSpacing.gapLg,
        Text('Atividades recentes', style: AppTypography.title),
        AppSpacing.gapSm,
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppEmptyState(
              message: 'Nenhuma tarefa cadastrada ainda.',
            ),
          )
        else
          ...recent.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TaskCard(view: v, showEmployee: true),
              )),
      ],
    );
  }
}
