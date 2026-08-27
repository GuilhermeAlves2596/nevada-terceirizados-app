import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/execution_item.dart';

/// Item de checklist marcável durante a execução.
class ChecklistExecutionTile extends StatelessWidget {
  const ChecklistExecutionTile({
    super.key,
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final ExecutionItem item;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final done = item.completed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: done ? AppColors.successSoft : AppColors.white,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          borderRadius: AppRadius.brMd,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(!done);
                }
              : null,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: done ? AppColors.success : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                _Checkbox(done: done, enabled: enabled),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.description,
                    style: AppTypography.body.copyWith(
                      color: enabled || done
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                ),
                if (!item.required)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.brPill,
                    ),
                    child: Text('opcional', style: AppTypography.caption),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.done, required this.enabled});

  final bool done;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: done ? AppColors.success : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: done
              ? AppColors.success
              : (enabled ? AppColors.textMuted : AppColors.border),
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: AppColors.white)
          : null,
    );
  }
}
