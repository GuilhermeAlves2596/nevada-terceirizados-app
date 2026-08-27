import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/company_catalog.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/contract_status.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../providers/contracts_providers.dart';

class ContractsListPage extends ConsumerWidget {
  const ContractsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contractsProvider);
    final clients = ref.watch(companyCatalogProvider).valueOrNull?.clientsById;

    return Scaffold(
      appBar: AppBar(title: const Text('Contratos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supervisorContractsCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(contractsProvider)),
          data: (contracts) {
            if (contracts.isEmpty) {
              return const AppEmptyState(
                icon: Icons.description_outlined,
                title: 'Nenhum contrato',
                message: 'Cadastre o primeiro contrato no botão abaixo.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(contractsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
                itemCount: contracts.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final c = contracts[i];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(c.name,
                                  style: AppTypography.subtitle),
                            ),
                            AppStatusBadge(
                              label: c.status.label,
                              color: _statusColor(c.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clients?[c.clientId]?.name ?? 'Cliente',
                          style: AppTypography.caption,
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

  Color _statusColor(ContractStatus s) => switch (s) {
        ContractStatus.active => AppColors.success,
        ContractStatus.inactive => AppColors.textMuted,
        ContractStatus.expired => AppColors.danger,
      };
}
