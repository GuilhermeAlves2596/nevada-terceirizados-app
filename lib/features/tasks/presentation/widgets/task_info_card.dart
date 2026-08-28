import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../models/task_view.dart';

/// Card com as informações da tarefa, com rótulos alinhados numa coluna fixa
/// e valores à esquerda (legível e consistente).
class TaskInfoCard extends StatelessWidget {
  const TaskInfoCard({
    super.key,
    required this.view,
    this.showEmployee = false,
  });

  final TaskView view;
  final bool showEmployee;

  @override
  Widget build(BuildContext context) {
    final task = view.task;
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
                child: Icon(view.serviceType.icon,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(view.checklistName, style: AppTypography.title),
              ),
              AppStatusBadge(
                label: task.status.label,
                color: task.status.color,
                backgroundColor: task.status.softColor,
              ),
            ],
          ),
          const Divider(height: 24),
          _Row(icon: Icons.location_on_outlined, label: 'Local', value: view.locationName),
          _Row(icon: Icons.apartment_outlined, label: 'Cliente', value: view.clientName),
          if (showEmployee)
            _Row(icon: Icons.person_outline, label: 'Funcionário', value: view.employeeName),
          _Row(icon: Icons.event_outlined, label: 'Data', value: task.scheduledDate.ddMMyyyy),
          if (task.scheduledStartTime != null)
            _Row(icon: Icons.schedule_outlined, label: 'Horário', value: task.scheduledStartTime!),
          _Row(icon: Icons.badge_outlined, label: 'Supervisor', value: view.supervisorName),
          _Row(
            icon: Icons.flag_outlined,
            label: 'Prioridade',
            value: task.priority.label,
            valueColor: task.priority.color,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(label, style: AppTypography.bodyMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueColor == null
                  ? AppTypography.subtitle
                  : AppTypography.subtitle.copyWith(color: valueColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
