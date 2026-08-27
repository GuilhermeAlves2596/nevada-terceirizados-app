import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Avatar circular com iniciais como fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 22,
    this.backgroundColor = AppColors.primarySoft,
    this.foregroundColor = AppColors.primary,
  });

  final String initials;
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.7,
              ),
            ),
    );
  }
}
