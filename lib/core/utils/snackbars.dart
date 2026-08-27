import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

void _show(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: color,
      content: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}

void showSuccessSnack(BuildContext context, String message) =>
    _show(context, message, AppColors.success, Icons.check_circle);

void showErrorSnack(BuildContext context, String message) =>
    _show(context, message, AppColors.danger, Icons.error_outline);

void showInfoSnack(BuildContext context, String message) =>
    _show(context, message, AppColors.dark, Icons.info_outline);
