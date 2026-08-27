import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Barra de progresso visual (0–100).
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.showLabel = false,
  });

  /// Valor de 0 a 100.
  final int progress;
  final double height;
  final Color? color;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0, 100);
    final barColor = color ??
        (clamped >= 100 ? AppColors.success : AppColors.primary);

    final bar = ClipRRect(
      borderRadius: AppRadius.brPill,
      child: LinearProgressIndicator(
        value: clamped / 100,
        minHeight: height,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation(barColor),
      ),
    );

    if (!showLabel) return bar;

    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 8),
        Text(
          '$clamped%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
