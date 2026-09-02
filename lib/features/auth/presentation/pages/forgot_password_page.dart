import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/credentials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// "Esqueci minha senha".
///
/// Reset por e-mail (supervisor/gestor) via Firebase. Funcionário loga por CPF
/// com e-mail sintético que não recebe mensagens — para ele, a orientação é
/// procurar o supervisor (a redefinição assistida entra quando houver Cloud
/// Function).
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum _MsgKind { success, error, info }

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _identifier = TextEditingController();
  bool _busy = false;
  String? _msg;
  _MsgKind _kind = _MsgKind.info;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  void _setMsg(String msg, _MsgKind kind) =>
      setState(() {
        _msg = msg;
        _kind = kind;
      });

  Future<void> _submit() async {
    final value = _identifier.text.trim();
    if (value.isEmpty) {
      _setMsg('Informe seu e-mail ou CPF.', _MsgKind.error);
      return;
    }
    FocusScope.of(context).unfocus();

    // Funcionário (CPF) não recebe e-mail de reset.
    if (!Credentials.looksLikeEmail(value)) {
      _setMsg(
        'Funcionários redefinem a senha com o supervisor. Procure seu '
        'supervisor para gerar uma nova senha temporária.',
        _MsgKind.info,
      );
      return;
    }

    setState(() => _busy = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(value.toLowerCase());
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      _setMsg(error, _MsgKind.error);
      return;
    }
    _setMsg(
      'Se houver uma conta com esse e-mail, você receberá um link para '
      'redefinir a senha em instantes. Verifique também o spam.',
      _MsgKind.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informe o e-mail cadastrado e enviaremos um link para redefinir '
                'a sua senha.',
                style: AppTypography.bodyMuted,
              ),
              AppSpacing.gapLg,
              AppTextField(
                label: 'CPF ou e-mail',
                controller: _identifier,
                hint: 'Digite seu e-mail',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (_msg != null) ...[
                AppSpacing.gapMd,
                _MsgBanner(message: _msg!, kind: _kind),
              ],
              AppSpacing.gapLg,
              AppButton(
                label: 'Enviar link de redefinição',
                loading: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MsgBanner extends StatelessWidget {
  const _MsgBanner({required this.message, required this.kind});

  final String message;
  final _MsgKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (kind) {
      _MsgKind.success => (AppColors.successSoft, AppColors.success, Icons.check_circle_outline),
      _MsgKind.error => (AppColors.dangerSoft, AppColors.danger, Icons.error_outline),
      _MsgKind.info => (AppColors.surface, AppColors.textMuted, Icons.info_outline),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.brMd,
        border: kind == _MsgKind.info
            ? Border.all(color: AppColors.border)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTypography.body.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}
