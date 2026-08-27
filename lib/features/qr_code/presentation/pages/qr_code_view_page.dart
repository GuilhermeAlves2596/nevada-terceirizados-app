import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/qr_payload.dart';

class QrCodeViewPage extends ConsumerWidget {
  const QrCodeViewPage({super.key, required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(companyCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code do ambiente')),
      body: catalog.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            AppErrorState(onRetry: () => ref.invalidate(companyCatalogProvider)),
        data: (data) {
          final location = data.locationsById[locationId];
          if (location == null) {
            return const AppEmptyState(message: 'Ambiente não encontrado.');
          }
          if (location.qrCodeId == null) {
            return const AppEmptyState(
              icon: Icons.qr_code_2_outlined,
              title: 'Sem QR Code',
              message:
                  'Este local é estrutural e não possui um QR próprio. Gere o QR nos ambientes finais (ex.: uma sala ou banheiro).',
            );
          }

          final client = data.clientsById[location.clientId]?.name ?? '';
          final payload = QrPayload(code: location.qrCodeId!).encode();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(location.name,
                        style: AppTypography.headline,
                        textAlign: TextAlign.center),
                    if (client.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(client, style: AppTypography.bodyMuted),
                    ],
                    AppSpacing.gapLg,
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.brMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: QrImageView(
                        data: payload,
                        version: QrVersions.auto,
                        size: 230,
                        backgroundColor: AppColors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(location.qrCodeId!,
                          style: AppTypography.subtitle),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Imprima e fixe este QR Code no ambiente. O funcionário o escaneia para abrir a tarefa.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
