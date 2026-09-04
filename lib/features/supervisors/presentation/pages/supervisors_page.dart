import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../employees/presentation/providers/employees_providers.dart';

/// Lista de supervisores da empresa (visão do gestor). Tocar em um supervisor
/// abre a tela de vínculo de contratos.
class SupervisorsPage extends ConsumerWidget {
  const SupervisorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(companySupervisorsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Supervisores')),
      body: async.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorState(
          onRetry: () => ref.invalidate(companySupervisorsProvider),
        ),
        data: (supervisors) {
          if (supervisors.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhum supervisor cadastrado ainda.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(companySupervisorsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: supervisors.length,
              separatorBuilder: (_, _) => AppSpacing.gapSm,
              itemBuilder: (context, i) {
                final s = supervisors[i];
                final n = s.contractIds.length;
                return Material(
                  color: AppColors.white,
                  borderRadius: AppRadius.brLg,
                  child: InkWell(
                    borderRadius: AppRadius.brLg,
                    onTap: () => context.push(
                      '${RoutePaths.supervisorSupervisors}/${s.id}',
                      extra: s,
                    ),
                    child: Ink(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.brLg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          AppAvatar(initials: s.initials, radius: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: AppTypography.subtitle),
                                const SizedBox(height: 2),
                                Text(
                                  n == 0
                                      ? 'Sem contratos vinculados'
                                      : '$n contrato(s) vinculado(s)',
                                  style: AppTypography.caption.copyWith(
                                    color: n == 0
                                        ? AppColors.warning
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
