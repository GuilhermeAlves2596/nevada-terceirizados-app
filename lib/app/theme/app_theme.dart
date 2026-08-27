import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Monta o [ThemeData] da aplicação a partir do design system.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      tertiary: AppColors.accent,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.white,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.title,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMuted,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button.copyWith(fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        labelStyle: AppTypography.caption,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
    );
  }
}
