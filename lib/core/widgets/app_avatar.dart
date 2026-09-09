import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_palette.dart';

/// Avatar circular com iniciais como fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 22,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String initials;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? context.c.primarySoft,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: foregroundColor ?? AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.7,
              ),
            ),
    );
  }
}
