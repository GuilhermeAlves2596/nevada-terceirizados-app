import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/credentials.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../contracts/presentation/providers/contracts_providers.dart';
import '../providers/employees_providers.dart';

class EmployeeFormPage extends ConsumerStatefulWidget {
  const EmployeeFormPage({super.key, this.existing});

  final AppUser? existing;

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _cpf = TextEditingController();
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _jobTitle;
  bool _saving = false;

  /// Contrato/cliente herdados pelo funcionário (passo 4). Preenchidos a partir
  /// do escopo do supervisor; auto-selecionados quando há apenas 1 contrato.
  String? _contractId;
  String? _clientId;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _name = TextEditingController(text: u?.name ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _jobTitle = TextEditingController(text: u?.jobTitle ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _cpf.dispose();
    _email.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    super.dispose();
  }

  void _invalidate() {
    ref.invalidate(employeesProvider);
    ref.invalidate(companyCatalogProvider);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          userId: widget.existing!.id,
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          jobTitle: _jobTitle.text,
        );
        _invalidate();
        if (!mounted) return;
        showSuccessSnack(context, 'Funcionário atualizado!');
        context.pop();
      } else {
        if (_contractId == null || _clientId == null) {
          if (mounted) {
            showErrorSnack(context, 'Selecione um contrato para o funcionário.');
          }
          return;
        }
        final result = await repo.createEmployee(
          companyId: companyId,
          contractId: _contractId!,
          clientId: _clientId!,
          name: _name.text,
          cpf: _cpf.text,
          email: _email.text,
          phone: _phone.text,
          jobTitle: _jobTitle.text,
        );
        _invalidate();
        if (!mounted) return;
        await _showCredentials(result.user, result.temporaryPassword);
        if (!mounted) return;
        context.pop();
      }
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir funcionário',
      message:
          'Excluir "${widget.existing!.name}"? O acesso dele deixa de funcionar.',
      confirmLabel: 'Excluir',
      danger: true,
    );
    if (!ok) return;
    await ref.read(userRepositoryProvider).delete(widget.existing!.id);
    _invalidate();
    if (!mounted) return;
    showSuccessSnack(context, 'Funcionário excluído.');
    context.pop();
  }

  Future<void> _showCredentials(AppUser user, String tempPassword) {
    final login = Credentials.formatCpf(user.cpf ?? '');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Funcionário cadastrado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repasse estes dados ao funcionário. No primeiro acesso, o app '
              'vai pedir para ele trocar a senha.',
              style: AppTypography.bodyMuted,
            ),
            AppSpacing.gapMd,
            _CredentialRow(label: 'Login (CPF)', value: login),
            AppSpacing.gapSm,
            _CredentialRow(label: 'Senha temporária', value: tempPassword),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'Login (CPF): $login\nSenha temporária: $tempPassword',
              ));
              showInfoSnack(context, 'Dados copiados.');
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copiar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  /// Campo de contrato (só no cadastro). Auto-seleciona quando o supervisor tem
  /// apenas 1 contrato; vira dropdown quando há vários; avisa quando não há.
  Widget _buildContractField() {
    final async = ref.watch(contractsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Text(
        'Não foi possível carregar os contratos.',
        style: AppTypography.bodyMuted,
      ),
      data: (contracts) {
        if (contracts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: AppRadius.brMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 20, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Você não tem contratos vinculados. Peça ao gestor para '
                    'vinculá-lo antes de cadastrar funcionários.',
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          );
        }
        if (contracts.length == 1) {
          final only = contracts.first;
          if (_contractId != only.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _contractId = only.id;
                  _clientId = only.clientId;
                });
              }
            });
          }
          return _ReadOnlyRow(label: 'Contrato', value: only.name);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contrato', style: AppTypography.subtitle),
            AppSpacing.gapXs,
            DropdownButtonFormField<String>(
              initialValue: _contractId,
              isExpanded: true,
              items: [
                for (final c in contracts)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() {
                _contractId = v;
                _clientId = v == null
                    ? null
                    : contracts.firstWhere((c) => c.id == v).clientId;
              }),
              validator: (v) => v == null ? 'Selecione um contrato' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.description_outlined,
                    color: AppColors.textMuted, size: 20),
                hintText: 'Selecione',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScaffold(
      title: _isEditing ? 'Editar funcionário' : 'Novo funcionário',
      formKey: _formKey,
      submitLabel: _isEditing ? 'Salvar' : 'Cadastrar',
      submitting: _saving,
      onSubmit: _save,
      actions: [
        if (_isEditing)
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _delete,
          ),
      ],
      children: [
        AppTextFormField(
          label: 'Nome',
          controller: _name,
          required: true,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        if (_isEditing)
          _ReadOnlyRow(
            label: 'CPF (login)',
            value: Credentials.formatCpf(widget.existing!.cpf ?? '—'),
          )
        else
          AppTextFormField(
            label: 'CPF',
            controller: _cpf,
            required: true,
            hint: 'Somente números',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final digits = Credentials.cpfDigits(v ?? '');
              if (digits.isEmpty) return 'Campo obrigatório';
              if (digits.length != 11) return 'CPF deve ter 11 dígitos';
              return null;
            },
          ),
        AppSpacing.gapMd,
        if (!_isEditing) ...[
          _buildContractField(),
          AppSpacing.gapMd,
        ],
        AppTextFormField(
          label: 'E-mail (opcional)',
          controller: _email,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Telefone',
          controller: _phone,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Cargo',
          controller: _jobTitle,
          hint: 'Ex.: Auxiliar de Limpeza',
          prefixIcon: Icons.work_outline,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text('$label: ', style: AppTypography.bodyMuted),
          Text(value, style: AppTypography.subtitle),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: AppTypography.title.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
