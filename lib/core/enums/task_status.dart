import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Situação de uma tarefa agendada (seção 15).
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        TaskStatus.pending => 'Pendente',
        TaskStatus.inProgress => 'Em andamento',
        TaskStatus.completed => 'Concluída',
        TaskStatus.cancelled => 'Cancelada',
      };

  Color get color => switch (this) {
        TaskStatus.pending => AppColors.warning,
        TaskStatus.inProgress => AppColors.secondary,
        TaskStatus.completed => AppColors.success,
        TaskStatus.cancelled => AppColors.textMuted,
      };

  Color get softColor => switch (this) {
        TaskStatus.pending => AppColors.warningSoft,
        TaskStatus.inProgress => AppColors.primarySoft,
        TaskStatus.completed => AppColors.successSoft,
        TaskStatus.cancelled => AppColors.surface,
      };

  bool get isOpen => this == TaskStatus.pending || this == TaskStatus.inProgress;

  static TaskStatus fromName(String? value) => TaskStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => TaskStatus.pending,
      );
}
