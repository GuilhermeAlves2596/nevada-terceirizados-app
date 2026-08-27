import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_button.dart';

/// Indicador de carregamento centralizado.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          if (message != null) ...[
            AppSpacing.gapMd,
            Text(message!, style: AppTypography.bodyMuted),
          ],
        ],
      ),
    );
  }
}

/// Estado vazio amigável para listas sem itens.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final String? title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.border),
            AppSpacing.gapMd,
            if (title != null) ...[
              Text(title!, style: AppTypography.title, textAlign: TextAlign.center),
              AppSpacing.gapXs,
            ],
            Text(
              message,
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[AppSpacing.gapLg, action!],
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com opção de tentar novamente.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message = 'Algo deu errado. Tente novamente.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            AppSpacing.gapMd,
            Text(
              message,
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.gapLg,
              AppButton(
                label: 'Tentar novamente',
                icon: Icons.refresh,
                variant: AppButtonVariant.outline,
                expanded: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
