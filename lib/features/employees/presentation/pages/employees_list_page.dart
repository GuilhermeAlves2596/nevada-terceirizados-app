import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../providers/employees_providers.dart';

class EmployeesListPage extends ConsumerWidget {
  const EmployeesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supervisorEmployeesCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(employeesProvider)),
          data: (employees) {
            if (employees.isEmpty) {
              return const AppEmptyState(
                icon: Icons.groups_outlined,
                title: 'Nenhum funcionário',
                message: 'Cadastre o primeiro funcionário no botão abaixo.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(employeesProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
                itemCount: employees.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final e = employees[i];
                  return AppCard(
                    child: Row(
                      children: [
                        AppAvatar(initials: e.initials, imageUrl: e.photoUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.name, style: AppTypography.subtitle),
                              const SizedBox(height: 2),
                              Text(
                                e.jobTitle ?? e.email,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (!e.active)
                          const AppStatusBadge(
                            label: 'Inativo',
                            color: AppColors.textMuted,
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
