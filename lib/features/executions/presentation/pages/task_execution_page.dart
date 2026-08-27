import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/execution_status.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../tasks/presentation/models/task_view.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/task_execution.dart';
import '../controllers/task_execution_controller.dart';
import '../widgets/checklist_execution_tile.dart';
import '../widgets/execution_photo_strip.dart';

class TaskExecutionPage extends ConsumerStatefulWidget {
  const TaskExecutionPage({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends ConsumerState<TaskExecutionPage> {
  final _obs = TextEditingController();
  bool _obsInitialized = false;
  bool _busy = false;

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  TaskExecutionController get _controller =>
      ref.read(taskExecutionControllerProvider(widget.taskId).notifier);

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() => _runBusy(_controller.start);

  Future<void> _addPhoto() => _runBusy(_controller.addPhoto);

  Future<void> _finish() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    String? error;
    try {
      await _controller.setObservation(_obs.text);
      error = await _controller.finish();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    if (error != null) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: AppColors.danger,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(error)),
            ],
          ),
        ));
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 20),
            SizedBox(width: 10),
            Text('Tarefa finalizada com sucesso!'),
          ],
        ),
      ));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final execAsync = ref.watch(taskExecutionControllerProvider(widget.taskId));
    final view = ref.watch(taskViewByIdProvider(widget.taskId)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(view?.checklistName ?? 'Tarefa'),
      ),
      body: execAsync.when(
        loading: () => const AppLoading(message: 'Carregando tarefa...'),
        error: (e, _) => AppErrorState(
          message: 'Não foi possível carregar a tarefa.',
          onRetry: () =>
              ref.invalidate(taskExecutionControllerProvider(widget.taskId)),
        ),
        data: (execution) {
          if (!_obsInitialized) {
            _obs.text = execution.observation ?? '';
            _obsInitialized = true;
          }
          return _Body(execution: execution, view: view, obsController: _obs, onToggle: _controller.toggleItem, onAddPhoto: _addPhoto, onRemovePhoto: _controller.removePhoto, busy: _busy);
        },
      ),
      bottomNavigationBar: execAsync.maybeWhen(
        data: (execution) => _ActionBar(
          execution: execution,
          busy: _busy,
          onStart: _start,
          onFinish: _finish,
        ),
        orElse: () => null,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.execution,
    required this.view,
    required this.obsController,
    required this.onToggle,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.busy,
  });

  final TaskExecution execution;
  final TaskView? view;
  final TextEditingController obsController;
  final void Function(String executionItemId, bool completed) onToggle;
  final VoidCallback onAddPhoto;
  final void Function(String photoId) onRemovePhoto;
  final bool busy;

  bool get _isInProgress => execution.status == ExecutionStatus.inProgress;
  bool get _isCompleted => execution.status == ExecutionStatus.completed;

  @override
  Widget build(BuildContext context) {
    final items = [...execution.items]..sort((a, b) => a.order.compareTo(b.order));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _InfoCard(view: view, execution: execution),
        AppSpacing.gapMd,
        _ProgressCard(execution: execution),
        AppSpacing.gapLg,
        Row(
          children: [
            Text('Checklist', style: AppTypography.title),
            const SizedBox(width: 8),
            Text(
              '${execution.completedItems}/${execution.totalItems}',
              style: AppTypography.bodyMuted,
            ),
          ],
        ),
        if (!_isInProgress && !_isCompleted) ...[
          AppSpacing.gapXs,
          Text(
            'Inicie a tarefa para marcar os itens.',
            style: AppTypography.caption,
          ),
        ],
        AppSpacing.gapSm,
        ...items.map((item) => ChecklistExecutionTile(
              item: item,
              enabled: _isInProgress,
              onChanged: (v) => onToggle(item.id, v),
            )),
        AppSpacing.gapLg,
        ExecutionPhotoStrip(
          photos: execution.photos,
          editable: _isInProgress,
          busy: busy,
          onAdd: onAddPhoto,
          onRemove: onRemovePhoto,
        ),
        AppSpacing.gapLg,
        Text('Observação', style: AppTypography.title),
        AppSpacing.gapSm,
        TextField(
          controller: obsController,
          enabled: _isInProgress,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
          style: AppTypography.body,
          decoration: const InputDecoration(
            hintText: 'Ex.: Foi encontrado um vazamento na pia.',
          ),
        ),
        const SizedBox(height: 90),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.view, required this.execution});

  final TaskView? view;
  final TaskExecution execution;

  @override
  Widget build(BuildContext context) {
    final task = view?.task;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(view?.serviceType.icon ?? Icons.task_alt,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  view?.checklistName ?? 'Tarefa',
                  style: AppTypography.title,
                ),
              ),
              if (task != null)
                AppStatusBadge(
                  label: task.status.label,
                  color: task.status.color,
                  backgroundColor: task.status.softColor,
                ),
            ],
          ),
          const Divider(height: 24),
          _row(Icons.location_on_outlined, 'Local', view?.locationName ?? '—'),
          _row(Icons.apartment_outlined, 'Cliente', view?.clientName ?? '—'),
          _row(Icons.event_outlined, 'Data',
              task != null ? task.scheduledDate.ddMMyyyy : '—'),
          if (task?.scheduledStartTime != null)
            _row(Icons.schedule_outlined, 'Horário', task!.scheduledStartTime!),
          _row(Icons.badge_outlined, 'Supervisor', view?.supervisorName ?? '—'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label, style: AppTypography.bodyMuted),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTypography.subtitle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.execution});

  final TaskExecution execution;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progresso', style: AppTypography.subtitle),
              Text(
                '${execution.progress}%',
                style: AppTypography.title.copyWith(
                  color: execution.progress >= 100
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          AppProgressBar(progress: execution.progress, height: 10),
          AppSpacing.gapXs,
          Text(
            '${execution.completedItems} de ${execution.totalItems} itens concluídos',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.execution,
    required this.busy,
    required this.onStart,
    required this.onFinish,
  });

  final TaskExecution execution;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: switch (execution.status) {
        ExecutionStatus.notStarted => AppButton(
            label: 'Iniciar tarefa',
            icon: Icons.play_arrow_rounded,
            loading: busy,
            onPressed: onStart,
          ),
        ExecutionStatus.inProgress => AppButton(
            label: 'Finalizar tarefa',
            icon: Icons.check_rounded,
            loading: busy,
            onPressed: onFinish,
          ),
        ExecutionStatus.completed => Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: AppRadius.brMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    execution.finishedAt != null
                        ? 'Concluída em ${execution.finishedAt!.fullDateTime}'
                        : 'Tarefa concluída',
                    style: AppTypography.subtitle
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ExecutionStatus.cancelled => const SizedBox.shrink(),
      },
    );
  }
}
