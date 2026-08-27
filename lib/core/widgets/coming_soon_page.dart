import 'package:flutter/material.dart';

import 'app_state_views.dart';

/// Página temporária para rotas ainda não implementadas na fase atual.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppEmptyState(
        icon: Icons.construction_outlined,
        title: 'Em breve',
        message: message ?? 'Esta área será implementada em uma próxima fase.',
      ),
    );
  }
}
