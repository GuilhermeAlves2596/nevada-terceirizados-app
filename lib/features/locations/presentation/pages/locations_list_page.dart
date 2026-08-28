import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/company_catalog.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../providers/locations_providers.dart';

class LocationsListPage extends ConsumerWidget {
  const LocationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(locationsProvider);
    final clients = ref.watch(companyCatalogProvider).valueOrNull?.clientsById;

    return Scaffold(
      appBar: AppBar(title: const Text('Locais / Ambientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supervisorLocationsCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(locationsProvider)),
          data: (locations) {
            if (locations.isEmpty) {
              return const AppEmptyState(
                icon: Icons.location_on_outlined,
                title: 'Nenhum local',
                message: 'Cadastre o primeiro ambiente no botão abaixo.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(locationsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
                itemCount: locations.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, i) {
                  final l = locations[i];
                  return AppCard(
                    onTap: () => context
                        .push('${RoutePaths.supervisorLocations}/${l.id}/qr'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadius.brMd,
                          ),
                          child: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.name, style: AppTypography.subtitle),
                              const SizedBox(height: 2),
                              Text(
                                clients?[l.clientId]?.name ?? 'Cliente',
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (l.qrCodeId != null)
                          Row(
                            children: [
                              const Icon(Icons.qr_code_2,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(l.qrCodeId!, style: AppTypography.caption),
                            ],
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
