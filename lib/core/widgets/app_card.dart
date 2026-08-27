import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

/// Container branco arredondado com sombra sutil — base visual dos cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.white,
      borderRadius: AppRadius.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.white,
            borderRadius: AppRadius.brLg,
            border: border,
            boxShadow: AppShadows.card,
          ),
          child: child,
        ),
      ),
    );
  }
}
