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
import '../../../tasks/presentation/models/task_view.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/dashboard_header.dart';

class EmployeeDashboardPage extends ConsumerWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(employeeTaskViewsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(employeeTaskViewsProvider.future),
          child: tasksAsync.when(
            loading: () => const _DashboardScroll(
              children: [SizedBox(height: 240, child: AppLoading())],
            ),
            error: (e, _) => _DashboardScroll(
              children: [
                SizedBox(
                  height: 240,
                  child: AppErrorState(
                    onRetry: () => ref.invalidate(employeeTaskViewsProvider),
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

class _DashboardScroll extends StatelessWidget {
  const _DashboardScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        DashboardHeader(
          subtitle: 'Suas tarefas de hoje',
          profilePath: ProfilePaths.employee,
          actions: [
            IconButton(
              tooltip: 'Histórico',
              onPressed: () => context.push(RoutePaths.employeeHistory),
              icon: const Icon(Icons.history),
            ),
          ],
        ),
        AppSpacing.gapLg,
        ...children,
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.tasks});

  final List<TaskView> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    bool isToday(TaskView v) {
      final d = v.task.scheduledDate;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }

    final today = tasks.where(isToday).toList();
    final late = tasks.where((v) => v.task.isLate(now)).toList();

    final pending =
        today.where((v) => v.task.isPending).length;
    final inProgress =
        today.where((v) => v.task.isInProgress).length;
    final completed =
        today.where((v) => v.task.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        DashboardHeader(
          subtitle: 'Suas tarefas de hoje',
          profilePath: ProfilePaths.employee,
          actions: [
            IconButton(
              tooltip: 'Histórico',
              onPressed: () => context.push(RoutePaths.employeeHistory),
              icon: const Icon(Icons.history),
            ),
          ],
        ),
        AppSpacing.gapLg,
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                value: '$pending',
                label: 'Pendentes',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '$inProgress',
                label: 'Em andamento',
                icon: Icons.play_circle_outline,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppStatCard(
                value: '$completed',
                label: 'Concluídas',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,
        const _ScanQrButton(),
        AppSpacing.gapLg,
        if (late.isNotEmpty) ...[
          _SectionTitle('Atrasadas', count: late.length, color: AppColors.danger),
          AppSpacing.gapSm,
          ...late.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TaskCard(
                  view: v,
                  onTap: () =>
                      context.push('${RoutePaths.employeeTasks}/${v.task.id}'),
                ),
              )),
          AppSpacing.gapMd,
        ],
        _SectionTitle('Tarefas de hoje', count: today.length),
        AppSpacing.gapSm,
        if (today.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppEmptyState(
              icon: Icons.task_alt,
              title: 'Tudo em dia!',
              message: 'Você não possui tarefas para hoje.',
            ),
          )
        else
          ...today.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TaskCard(
                  view: v,
                  onTap: () =>
                      context.push('${RoutePaths.employeeTasks}/${v.task.id}'),
                ),
              )),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.count, this.color});

  final String title;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.title),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.12),
              borderRadius: AppRadius.brPill,
            ),
            child: Text(
              '$count',
              style: AppTypography.caption.copyWith(
                color: color ?? AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppRadius.brLg,
      child: InkWell(
        borderRadius: AppRadius.brLg,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leitor de QR Code chega na próxima fase 🚧'),
            ),
          );
        },
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
              const Icon(Icons.qr_code_scanner, color: AppColors.white, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear QR Code',
                      style: AppTypography.subtitle.copyWith(color: AppColors.white),
                    ),
                    Text(
                      'Acesse a tarefa do ambiente',
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
