import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../models/task_view.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

/// Filtro do histórico do funcionário.
enum _HistoryFilter { concluidas, todas }

final _historyFilterProvider =
    StateProvider.autoDispose<_HistoryFilter>((ref) => _HistoryFilter.concluidas);

class EmployeeHistoryPage extends ConsumerWidget {
  const EmployeeHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(employeeTaskViewsProvider);
    final filter = ref.watch(_historyFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: SafeArea(
        child: tasksAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
            onRetry: () => ref.invalidate(employeeTaskViewsProvider),
          ),
          data: (all) {
            final items = _apply(all, filter);
            return Column(
              children: [
                _FilterBar(
                  selected: filter,
                  onChanged: (f) =>
                      ref.read(_historyFilterProvider.notifier).state = f,
                ),
                Expanded(
                  child: items.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.history,
                          title: 'Sem registros',
                          message: 'Suas tarefas finalizadas aparecerão aqui.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => refreshEmployeeTasks(ref),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => AppSpacing.gapSm,
                            itemBuilder: (context, i) {
                              final v = items[i];
                              return TaskCard(
                                view: v,
                                onTap: () => context.push(
                                    '${RoutePaths.employeeTasks}/${v.task.id}'),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<TaskView> _apply(List<TaskView> all, _HistoryFilter filter) {
    final list = all.where((v) {
      return switch (filter) {
        _HistoryFilter.concluidas => v.task.isCompleted,
        _HistoryFilter.todas => !v.task.status.isOpen, // concluídas + canceladas
      };
    }).toList()
      ..sort((a, b) {
        final byDate = b.task.scheduledDate.compareTo(a.task.scheduledDate);
        if (byDate != 0) return byDate;
        return (b.task.scheduledStartTime ?? '')
            .compareTo(a.task.scheduledStartTime ?? '');
      });
    return list;
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Row(
        children: [
          _chip('Concluídas', _HistoryFilter.concluidas),
          const SizedBox(width: 8),
          _chip('Todas', _HistoryFilter.todas),
        ],
      ),
    );
  }

  Widget _chip(String label, _HistoryFilter value) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected ? AppColors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
