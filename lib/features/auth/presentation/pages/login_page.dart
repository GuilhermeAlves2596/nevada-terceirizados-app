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
  final _email = TextEditingController();
  final _password = TextEditingController(text: '123456');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).signIn(
          email: _email.text,
          password: _password.text,
        );
  }

  void _fill(String email) {
    _email.text = email;
    _password.text = '123456';
    ref.read(authControllerProvider.notifier).clearError();
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
                    label: 'E-mail',
                    controller: _email,
                    hint: 'seu@email.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
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
                  _DemoCredentials(onFill: _fill),
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
  const _DemoCredentials({required this.onFill});

  final ValueChanged<String> onFill;

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
              const Icon(Icons.science_outlined,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('Acesso de demonstração', style: AppTypography.subtitle),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Toque para preencher (senha: 123456)',
            style: AppTypography.caption,
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onFill('supervisor@teste.com'),
                  icon: const Icon(Icons.badge_outlined, size: 18),
                  label: const Text('Supervisor'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onFill('funcionario@teste.com'),
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text('Funcionário'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
