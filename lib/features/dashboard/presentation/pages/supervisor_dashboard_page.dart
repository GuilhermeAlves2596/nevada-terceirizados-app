import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../tasks/presentation/models/task_stats.dart';
import '../../../tasks/presentation/models/task_view.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/dashboard_header.dart';

class SupervisorDashboardPage extends ConsumerWidget {
  const SupervisorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(supervisorTaskViewsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshSupervisorTasks(ref),
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
    final recent = tasks.take(3).toList();

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
                onTap: () =>
                    context.push('${RoutePaths.supervisorTasks}?filter=all'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.inProgress}',
                label: 'Em andamento',
                icon: Icons.play_circle_outline,
                color: AppColors.secondary,
                onTap: () => context
                    .push('${RoutePaths.supervisorTasks}?filter=inProgress'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.pending}',
                label: 'Pendentes',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
                onTap: () => context
                    .push('${RoutePaths.supervisorTasks}?filter=pending'),
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
                onTap: () => context
                    .push('${RoutePaths.supervisorTasks}?filter=completed'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '${stats.late}',
                label: 'Atrasadas',
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
                onTap: () =>
                    context.push('${RoutePaths.supervisorTasks}?filter=late'),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
        AppSpacing.gapLg,
        const _NewTaskButton(),
        AppSpacing.gapLg,
        Text('Gestão', style: AppTypography.title),
        AppSpacing.gapSm,
        const _ManagementGrid(),
        AppSpacing.gapLg,
        Row(
          children: [
            Text('Atividades recentes', style: AppTypography.title),
            const Spacer(),
            if (tasks.isNotEmpty)
              TextButton(
                onPressed: () => context.push(RoutePaths.supervisorTasks),
                child: const Text('Ver todas'),
              ),
          ],
        ),
        AppSpacing.gapXs,
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
                child: TaskCard(
                  view: v,
                  showEmployee: true,
                  onTap: () => context
                      .push('${RoutePaths.supervisorTasks}/${v.task.id}'),
                ),
              )),
      ],
    );
  }
}

class _NewTaskButton extends StatelessWidget {
  const _NewTaskButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppRadius.brLg,
      child: InkWell(
        borderRadius: AppRadius.brLg,
        onTap: () => context.push(RoutePaths.supervisorTasksCreate),
        child: Ink(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: AppRadius.brLg,
          ),
          child: Row(
            children: [
              const Icon(Icons.add_task, color: AppColors.white, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nova tarefa',
                        style: AppTypography.subtitle
                            .copyWith(color: AppColors.white)),
                    Text(
                      'Atribua um serviço a um funcionário',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementGrid extends ConsumerWidget {
  const _ManagementGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // O card "Supervisores" (vínculo de contratos) é só do gestor da empresa.
    final isManager =
        user != null && (user.isCompanyAdmin || user.isPlatformAdmin);
    final items = <({String label, IconData icon, String route})>[
      if (isManager)
        (label: 'Supervisores', icon: Icons.supervisor_account_outlined, route: RoutePaths.supervisorSupervisors),
      (label: 'Funcionários', icon: Icons.groups_outlined, route: RoutePaths.supervisorEmployees),
      // Clientes e contratos são do gestor (o supervisor só opera dentro deles).
      if (isManager)
        (label: 'Clientes', icon: Icons.apartment_outlined, route: RoutePaths.supervisorClients),
      if (isManager)
        (label: 'Contratos', icon: Icons.description_outlined, route: RoutePaths.supervisorContracts),
      (label: 'Locais', icon: Icons.location_on_outlined, route: RoutePaths.supervisorLocations),
      (label: 'Checklists', icon: Icons.checklist_outlined, route: RoutePaths.supervisorChecklists),
      (label: 'Relatórios', icon: Icons.bar_chart_outlined, route: RoutePaths.supervisorReports),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: [
        for (final item in items)
          Material(
            color: AppColors.white,
            borderRadius: AppRadius.brLg,
            child: InkWell(
              borderRadius: AppRadius.brLg,
              onTap: () => context.push(item.route),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.brMd,
                      ),
                      child: Icon(item.icon,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.label,
                          style: AppTypography.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
