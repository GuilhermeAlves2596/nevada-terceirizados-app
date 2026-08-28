import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/qr_resolver.dart';
import '../providers/qr_providers.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final _manual = TextEditingController();
  bool _handling = false;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _process(String? raw) async {
    if (_handling) return;
    if (raw == null || raw.trim().isEmpty) return;
    setState(() => _handling = true);

    final user = ref.read(currentUserProvider);
    final companyId = user?.companyId;
    if (user == null || companyId == null) {
      setState(() => _handling = false);
      return;
    }

    final result = await ref.read(qrResolverProvider).resolve(
          companyId: companyId,
          employeeId: user.id,
          rawPayload: raw,
        );
    if (!mounted) return;

    switch (result) {
      case QrResolveSuccess(:final taskId):
        context.pushReplacement('${RoutePaths.employeeTasks}/$taskId');
      case QrResolveFailure(:final message):
        showErrorSnack(context, message);
        setState(() => _handling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR Code')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: kIsWeb
                  ? const _CameraUnavailable()
                  : _ScannerView(onDetect: _process),
            ),
            _ManualEntry(
              controller: _manual,
              busy: _handling,
              onSubmit: () => _process(_manual.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerView extends StatelessWidget {
  const _ScannerView({required this.onDetect});

  final void Function(String? raw) onDetect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          onDetect: (capture) {
            final code = capture.barcodes.isNotEmpty
                ? capture.barcodes.first.rawValue
                : null;
            onDetect(code);
          },
        ),
        // Moldura de mira.
        Container(
          height: 220,
          width: 220,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 3),
            borderRadius: AppRadius.brLg,
          ),
        ),
        const Positioned(
          bottom: 24,
          child: Text(
            'Aponte para o QR Code do ambiente',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.dark,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_camera_front_outlined,
              color: AppColors.white, size: 56),
          AppSpacing.gapMd,
          Text(
            'A câmera está disponível no aplicativo (Android/iOS).',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.white),
          ),
          AppSpacing.gapXs,
          Text(
            'Neste preview web, use a digitação do código abaixo.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  const _ManualEntry({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.white),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Digitar código do ambiente', style: AppTypography.subtitle),
            const SizedBox(height: 4),
            Text('Ex.: QR-NVD-0001', style: AppTypography.caption),
            AppSpacing.gapSm,
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(hintText: 'Código do QR'),
            ),
            AppSpacing.gapSm,
            AppButton(
              label: 'Abrir tarefa',
              icon: Icons.arrow_forward,
              loading: busy,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
