import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../providers/checklists_providers.dart';

class ChecklistsListPage extends ConsumerWidget {
  const ChecklistsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(checklistsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supervisorChecklistsCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.playlist_add),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(checklistsProvider)),
          data: (checklists) {
            if (checklists.isEmpty) {
              return const AppEmptyState(
                icon: Icons.checklist_outlined,
                title: 'Nenhum checklist',
                message: 'Crie o primeiro modelo de rotina no botão abaixo.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(checklistsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
                itemCount: checklists.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final c = checklists[i];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: AppRadius.brMd,
                          ),
                          child: Icon(c.serviceType.icon,
                              color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: AppTypography.subtitle),
                              const SizedBox(height: 2),
                              Text(
                                '${c.serviceType.label} • ${c.totalItems} itens',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
