import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Primeiro acesso: o funcionário troca a senha temporária por uma definitiva.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final error =
        await ref.read(authControllerProvider.notifier).changePassword(_password.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showErrorSnack(context, error);
    } else {
      showSuccessSnack(context, 'Senha atualizada!');
      // O roteador redireciona automaticamente para a home do perfil.
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Definir nova senha'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Olá, ${user?.firstName ?? ''}!', style: AppTypography.headline),
            AppSpacing.gapXs,
            Text(
              'Este é seu primeiro acesso. Crie uma senha pessoal para continuar.',
              style: AppTypography.bodyMuted,
            ),
            AppSpacing.gapLg,
            AppTextFormField(
              label: 'Nova senha',
              controller: _password,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Campo obrigatório';
                if ((v ?? '').length < 6) {
                  return 'A senha deve ter ao menos 6 caracteres';
                }
                return null;
              },
            ),
            AppSpacing.gapMd,
            AppTextFormField(
              label: 'Confirmar senha',
              controller: _confirm,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) =>
                  v != _password.text ? 'As senhas não conferem' : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: 'Salvar nova senha',
          icon: Icons.check,
          loading: _saving,
          onPressed: _submit,
        ),
      ),
    );
  }
}
