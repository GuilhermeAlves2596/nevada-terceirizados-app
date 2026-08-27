import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/employees_providers.dart';

class EmployeeFormPage extends ConsumerStatefulWidget {
  const EmployeeFormPage({super.key});

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _jobTitle = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).createEmployee(
            companyId: companyId,
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            jobTitle: _jobTitle.text,
          );
      ref.invalidate(employeesProvider);
      ref.invalidate(companyCatalogProvider);
      if (!mounted) return;
      showSuccessSnack(context, 'Funcionário cadastrado!');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScaffold(
      title: 'Novo funcionário',
      formKey: _formKey,
      submitLabel: 'Cadastrar',
      submitting: _saving,
      onSubmit: _save,
      children: [
        AppTextFormField(
          label: 'Nome',
          controller: _name,
          required: true,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'E-mail',
          controller: _email,
          required: true,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (v) {
            final value = (v ?? '').trim();
            if (value.isEmpty) return 'Campo obrigatório';
            if (!value.contains('@') || !value.contains('.')) {
              return 'E-mail inválido';
            }
            return null;
          },
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
