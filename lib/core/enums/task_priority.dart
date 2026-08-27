import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Prioridade de uma tarefa (seção 15).
enum TaskPriority {
  low,
  normal,
  high,
  urgent;

  String get label => switch (this) {
        TaskPriority.low => 'Baixa',
        TaskPriority.normal => 'Normal',
        TaskPriority.high => 'Alta',
        TaskPriority.urgent => 'Urgente',
      };

  Color get color => switch (this) {
        TaskPriority.low => AppColors.textMuted,
        TaskPriority.normal => AppColors.secondary,
        TaskPriority.high => AppColors.warning,
        TaskPriority.urgent => AppColors.danger,
      };

  static TaskPriority fromName(String? value) => TaskPriority.values.firstWhere(
        (priority) => priority.name == value,
        orElse: () => TaskPriority.normal,
      );
}
