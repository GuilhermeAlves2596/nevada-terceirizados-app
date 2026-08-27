import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia central.
///
/// Títulos usam **League Spartan** e textos usam **Roboto** (seção 44).
/// As fontes são carregadas via `google_fonts`. Na fase de produção podemos
/// empacotá-las localmente para funcionar 100% offline.
abstract final class AppTypography {
  const AppTypography._();

  static const String _displayFont = 'League Spartan';

  static TextStyle _title(double size, FontWeight weight) => GoogleFonts.leagueSpartan(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.textPrimary,
        height: 1.15,
      );

  static TextStyle _body(double size, FontWeight weight, Color color) => GoogleFonts.roboto(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.35,
      );

  static TextStyle get displayLarge => _title(32, FontWeight.w700);
  static TextStyle get displayMedium => _title(28, FontWeight.w700);
  static TextStyle get headline => _title(22, FontWeight.w600);
  static TextStyle get title => _title(18, FontWeight.w600);
  static TextStyle get subtitle => _body(15, FontWeight.w600, AppColors.textPrimary);

  static TextStyle get body => _body(14, FontWeight.w400, AppColors.textPrimary);
  static TextStyle get bodyMuted => _body(14, FontWeight.w400, AppColors.textSecondary);
  static TextStyle get caption => _body(12, FontWeight.w400, AppColors.textSecondary);
  static TextStyle get button => GoogleFonts.leagueSpartan(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  /// [TextTheme] completo para o [ThemeData].
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineMedium: headline,
        titleLarge: title,
        titleMedium: subtitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button.copyWith(color: AppColors.textPrimary),
      );

  /// Nome da família de fontes de título para uso pontual em widgets.
  static String get displayFontFamily => _displayFont;
}
