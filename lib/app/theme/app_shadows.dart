import 'package:flutter/widgets.dart';

/// Sombras sutis padronizadas para dar profundidade sem poluir a interface.
abstract final class AppShadows {
  const AppShadows._();

  /// Sombra leve para cards.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // preto ~8%
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Sombra um pouco mais forte para elementos elevados (bottom sheets, FAB).
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000), // preto ~12%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
