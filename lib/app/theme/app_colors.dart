import 'package:flutter/material.dart';

/// Paleta central do aplicativo.
///
/// Nunca use cores "hardcoded" dentro dos widgets. Sempre referencie
/// [AppColors] (ou o [ColorScheme] do tema) para manter consistência.
abstract final class AppColors {
  const AppColors._();

  // Cores da marca (seção 44 do briefing).
  static const Color primary = Color(0xFF1D4F91);
  static const Color secondary = Color(0xFF0076B0);
  static const Color accent = Color(0xFF279989);

  static const Color dark = Color(0xFF2A2A2B);
  static const Color textMuted = Color(0xFF777777);
  static const Color border = Color(0xFFDDDDDD);
  static const Color background = Color(0xFFEFEFEF);
  static const Color surface = Color(0xFFF4F4F4);
  static const Color light = Color(0xFFFBFBFB);

  static const Color white = Color(0xFFFFFFFF);

  // Cores semânticas de status.
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE8A317);
  static const Color danger = Color(0xFFD64545);
  static const Color info = secondary;

  // Texto.
  static const Color textPrimary = dark;
  static const Color textSecondary = textMuted;
  static const Color textOnPrimary = white;

  /// Tons derivados usados em fundos suaves de badges e cards.
  static const Color primarySoft = Color(0xFFE8EEF6);
  static const Color accentSoft = Color(0xFFE3F1EE);
  static const Color successSoft = Color(0xFFE4F3EA);
  static const Color warningSoft = Color(0xFFFBF1DC);
  static const Color dangerSoft = Color(0xFFF8E4E4);
}
