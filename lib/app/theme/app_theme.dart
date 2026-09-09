import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Monta o [ThemeData] da aplicação (claro/escuro) a partir do design system.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        palette: AppPalette.light,
        overlay: SystemUiOverlayStyle.dark,
        colorScheme: const ColorScheme.light(
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
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        palette: AppPalette.dark,
        overlay: SystemUiOverlayStyle.light,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          tertiary: AppColors.accent,
          surface: AppPalette.dark.card,
          onSurface: AppPalette.dark.textPrimary,
          error: AppColors.danger,
          onError: AppColors.white,
          outline: AppPalette.dark.border,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
    required ColorScheme colorScheme,
    required SystemUiOverlayStyle overlay,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.bg,
      extensions: [palette],
      textTheme: AppTypography.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: palette.textPrimary,
        titleTextStyle: AppTypography.title.copyWith(color: palette.textPrimary),
        systemOverlayStyle: overlay,
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMuted.copyWith(color: palette.textMuted),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.border),
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
          disabledBackgroundColor: palette.border,
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
        backgroundColor: palette.surface,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        labelStyle: AppTypography.caption.copyWith(color: palette.textMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: palette.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.card),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: palette.card),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
    );
  }
}
