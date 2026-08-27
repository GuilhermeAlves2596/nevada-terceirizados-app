import 'package:flutter/widgets.dart';

/// Escala de espaçamentos (múltiplos de 4) usada em paddings, margens e gaps.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Padding horizontal padrão das telas.
  static const double screenH = md;

  // Gaps verticais reutilizáveis.
  static const SizedBox gapXxs = SizedBox(height: xxs);
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);

  // Gaps horizontais reutilizáveis.
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
}
