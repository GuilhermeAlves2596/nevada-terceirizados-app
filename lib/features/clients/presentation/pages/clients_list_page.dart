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
import '../providers/clients_providers.dart';

class ClientsListPage extends ConsumerWidget {
  const ClientsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supervisorClientsCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(clientsProvider)),
          data: (clients) {
            if (clients.isEmpty) {
              return const AppEmptyState(
                icon: Icons.apartment_outlined,
                title: 'Nenhum cliente',
                message: 'Cadastre o primeiro cliente no botão abaixo.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(clientsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
                itemCount: clients.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final c = clients[i];
                  return AppCard(
                    onTap: () => context.push(
                        RoutePaths.supervisorClientsCreate, extra: c),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadius.brMd,
                          ),
                          child: const Icon(Icons.apartment,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: AppTypography.subtitle),
                              const SizedBox(height: 2),
                              Text(
                                c.document ?? c.address ?? c.phone ?? '—',
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
