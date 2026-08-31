import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../executions/presentation/widgets/checklist_execution_tile.dart';
import '../../../executions/presentation/widgets/execution_photo_strip.dart';
import '../models/task_view.dart';
import '../providers/task_providers.dart';
import '../widgets/task_info_card.dart';

class SupervisorTaskDetailPage extends ConsumerWidget {
  const SupervisorTaskDetailPage({super.key, required this.taskId});

  final String taskId;

  void _invalidate(WidgetRef ref) {
    ref.invalidate(supervisorTaskViewsProvider);
    ref.invalidate(employeeTaskViewsProvider);
    ref.invalidate(taskViewByIdProvider(taskId));
    ref.invalidate(taskExecutionReadProvider(taskId));
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Cancelar tarefa',
      message: 'A tarefa será marcada como cancelada. Deseja continuar?',
      confirmLabel: 'Cancelar tarefa',
    );
    if (ok != true) return;
    await ref
        .read(taskRepositoryProvider)
        .setStatus(taskId: taskId, status: TaskStatus.cancelled);
    _invalidate(ref);
    if (context.mounted) {
      showSuccessSnack(context, 'Tarefa cancelada.');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Excluir tarefa',
      message: 'Esta ação não pode ser desfeita. Excluir a tarefa?',
      confirmLabel: 'Excluir',
      danger: true,
    );
    if (ok != true) return;
    await ref.read(taskRepositoryProvider).delete(taskId);
    _invalidate(ref);
    if (context.mounted) {
      showSuccessSnack(context, 'Tarefa excluída.');
      if (context.canPop()) context.pop();
    }
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: danger ? AppColors.danger : AppColors.primary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(taskViewByIdProvider(taskId));
    final task = viewAsync.valueOrNull?.task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da tarefa'),
        actions: [
          if (task != null)
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    context.push(RoutePaths.supervisorTasksCreate, extra: task);
                  case 'qr':
                    context.push(
                        '${RoutePaths.supervisorLocations}/${task.locationId}/qr');
                  case 'cancel':
                    _cancel(context, ref);
                  case 'delete':
                    _delete(context, ref);
                }
              },
              itemBuilder: (context) => [
                if (task.isPending)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar tarefa'),
                  ),
                const PopupMenuItem(
                  value: 'qr',
                  child: Text('Ver QR do ambiente'),
                ),
                if (task.status.isOpen)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Text('Cancelar tarefa'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Excluir tarefa',
                      style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
        ],
      ),
      body: viewAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            AppErrorState(onRetry: () => ref.invalidate(taskViewByIdProvider(taskId))),
        data: (view) {
          if (view == null) {
            return const AppEmptyState(message: 'Tarefa não encontrada.');
          }
          return _Content(taskId: taskId, view: view);
        },
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.taskId, required this.view});

  final String taskId;
  final TaskView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.watch(taskExecutionReadProvider(taskId)).valueOrNull;
    final checklist = ref
        .watch(companyCatalogProvider)
        .valueOrNull
        ?.checklistsById[view.task.checklistId];
    final progress = execution?.progress ?? view.task.progress;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TaskInfoCard(view: view, showEmployee: true),
        AppSpacing.gapMd,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progresso', style: AppTypography.subtitle),
                  Text('$progress%',
                      style: AppTypography.title.copyWith(
                        color: progress >= 100
                            ? AppColors.success
                            : AppColors.primary,
                      )),
                ],
              ),
              AppSpacing.gapSm,
              AppProgressBar(progress: progress, height: 10),
            ],
          ),
        ),
        AppSpacing.gapLg,
        Text('Checklist', style: AppTypography.title),
        AppSpacing.gapSm,
        if (execution != null && execution.items.isNotEmpty)
          ...(<Widget>[
            for (final item in ([...execution.items]
              ..sort((a, b) => a.order.compareTo(b.order))))
              ChecklistExecutionTile(
                item: item,
                enabled: false,
                onChanged: (_) {},
              ),
          ])
        else if (checklist != null)
          ...(<Widget>[
            Text('Ainda não iniciada pelo funcionário.',
                style: AppTypography.caption),
            AppSpacing.gapSm,
            for (final item in checklist.orderedItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.radio_button_unchecked,
                        size: 20, color: AppColors.border),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item.description, style: AppTypography.body)),
                  ],
                ),
              ),
          ]),
        if (execution != null && execution.photos.isNotEmpty) ...[
          AppSpacing.gapLg,
          ExecutionPhotoStrip(
            photos: execution.photos,
            editable: false,
            busy: false,
            onAdd: () {},
            onRemove: (_) {},
          ),
        ],
        if (execution?.observation != null &&
            execution!.observation!.isNotEmpty) ...[
          AppSpacing.gapLg,
          Text('Observação', style: AppTypography.title),
          AppSpacing.gapSm,
          AppCard(
            child: Text(execution.observation!, style: AppTypography.body),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
