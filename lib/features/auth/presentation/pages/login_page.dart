import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).signIn(
          identifier: _identifier.text,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  AppSpacing.gapXl,
                  Text('Bem-vindo de volta', style: AppTypography.headline),
                  AppSpacing.gapXxs,
                  Text(
                    'Entre para acessar suas tarefas.',
                    style: AppTypography.bodyMuted,
                  ),
                  AppSpacing.gapLg,
                  AppTextField(
                    label: 'CPF ou e-mail',
                    controller: _identifier,
                    hint: 'Digite seu CPF',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) =>
                        ref.read(authControllerProvider.notifier).clearError(),
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Senha',
                    controller: _password,
                    hint: '••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  if (auth.errorMessage != null) ...[
                    AppSpacing.gapMd,
                    _ErrorBanner(message: auth.errorMessage!),
                  ],
                  AppSpacing.gapLg,
                  AppButton(
                    label: 'Entrar',
                    loading: auth.isBusy,
                    onPressed: _submit,
                  ),
                  AppSpacing.gapLg,
                  const _DemoCredentials(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.brXl,
          ),
          child: const Icon(Icons.cleaning_services_rounded,
              color: AppColors.white, size: 36),
        ),
        AppSpacing.gapMd,
        Text('Nevada', style: AppTypography.displayMedium),
        Text(
          'Gestão de Serviços Terceirizados',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCredentials extends StatelessWidget {
  const _DemoCredentials();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('Como acessar', style: AppTypography.subtitle),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Supervisor entra com e-mail e senha. Funcionário entra com o CPF '
            'e a senha temporária que o supervisor informar.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
