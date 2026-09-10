import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // successSoft é um verde claro fixo; no escuro usamos um verde escuro para
    // o texto (claro) continuar legível.
    final doneBg =
        isDark ? const Color(0xFF16351F) : AppColors.successSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: done ? doneBg : context.c.card,
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
                color: done ? AppColors.success : context.c.border,
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
                          ? context.c.textPrimary
                          : context.c.textMuted,
                      decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: context.c.textMuted,
                    ),
                  ),
                ),
                if (!item.required)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.c.surface,
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
              : (enabled ? context.c.textMuted : context.c.border),
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: AppColors.white)
          : null,
    );
  }
}
