import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../models/task_view.dart';

/// Card de tarefa reutilizável nos dashboards e listas.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.view,
    this.onTap,
    this.showEmployee = false,
  });

  final TaskView view;
  final VoidCallback? onTap;

  /// Exibe o nome do funcionário (visão do supervisor).
  final bool showEmployee;

  @override
  Widget build(BuildContext context) {
    final task = view.task;
    final isLate = task.isLate(DateTime.now());

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(view.serviceType.icon,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.checklistName,
                      style: AppTypography.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      view.locationName,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppStatusBadge(
                label: task.status.label,
                color: task.status.color,
                backgroundColor: task.status.softColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _meta(Icons.event_outlined, task.scheduledDate.relativeLabel),
              if (task.scheduledStartTime != null) ...[
                const SizedBox(width: 14),
                _meta(Icons.schedule_outlined, task.scheduledStartTime!),
              ],
              if (showEmployee) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: _meta(Icons.person_outline, view.employeeName,
                      ellipsis: true),
                ),
              ],
              if (isLate) ...[
                const Spacer(),
                const AppStatusBadge(
                  label: 'Atrasada',
                  color: AppColors.danger,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(progress: task.progress, showLabel: true),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text, {bool ellipsis = false}) {
    final label = Text(
      text,
      style: AppTypography.caption,
      maxLines: 1,
      overflow: ellipsis ? TextOverflow.ellipsis : TextOverflow.clip,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        ellipsis ? Flexible(child: label) : label,
      ],
    );
  }
}
