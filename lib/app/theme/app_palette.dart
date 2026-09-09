import 'package:flutter/material.dart';

/// Cores semânticas que mudam entre claro/escuro. Widgets leem via
/// `context.c` (ex.: `context.c.card`, `context.c.textMuted`). Cores de marca
/// e de status (primary, success, danger…) ficam em `AppColors` (não mudam).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.primarySoft,
  });

  final Color bg; // fundo da tela (scaffold)
  final Color surface; // preenchimento suave (inputs, chips)
  final Color card; // superfície elevada (cards)
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color primarySoft; // fundo suave de ícones/badges de marca

  static const light = AppPalette(
    bg: Color(0xFFEFEFEF),
    surface: Color(0xFFF4F4F4),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFDDDDDD),
    textPrimary: Color(0xFF2A2A2B),
    textMuted: Color(0xFF777777),
    primarySoft: Color(0xFFE8EEF6),
  );

  static const dark = AppPalette(
    bg: Color(0xFF0F172A), // slate-900
    surface: Color(0xFF273449),
    card: Color(0xFF1E293B), // slate-800
    border: Color(0xFF334155), // slate-700
    textPrimary: Color(0xFFE2E8F0), // slate-200
    textMuted: Color(0xFF94A3B8), // slate-400
    primarySoft: Color(0xFF1E3A5C),
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? primarySoft,
  }) =>
      AppPalette(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        card: card ?? this.card,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textMuted: textMuted ?? this.textMuted,
        primarySoft: primarySoft ?? this.primarySoft,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
    );
  }
}

/// Atalho: `context.c.card`, `context.c.textMuted`, etc.
extension AppPaletteX on BuildContext {
  AppPalette get c =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
