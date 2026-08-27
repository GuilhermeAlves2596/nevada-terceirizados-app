import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

/// Layout padrão de telas de cadastro: título, formulário rolável e botão de
/// salvar fixo no rodapé com estado de carregamento.
class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    this.submitLabel = 'Salvar',
    this.submitting = false,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ...children,
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: submitLabel,
          icon: Icons.check,
          loading: submitting,
          onPressed: onSubmit,
        ),
      ),
    );
  }
}
