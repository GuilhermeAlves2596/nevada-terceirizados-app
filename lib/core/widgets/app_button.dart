import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline }

/// Botão padrão do app, com estado de carregamento embutido.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !loading;
    final child = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(AppColors.white),
            ),
          )
        : _content();

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: loading ? _spinner() : _content(),
        ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _spinner() => const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      );

  Widget _content() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
