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
import '../providers/clients_providers.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _document = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _document.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(clientRepositoryProvider).create(
            companyId: companyId,
            name: _name.text,
            document: _document.text,
            phone: _phone.text,
            email: _email.text,
            address: _address.text,
          );
      ref.invalidate(clientsProvider);
      ref.invalidate(companyCatalogProvider);
      if (!mounted) return;
      showSuccessSnack(context, 'Cliente cadastrado!');
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
      title: 'Novo cliente',
      formKey: _formKey,
      submitLabel: 'Cadastrar',
      submitting: _saving,
      onSubmit: _save,
      children: [
        AppTextFormField(
          label: 'Nome',
          controller: _name,
          required: true,
          hint: 'Ex.: Prefeitura Municipal',
          prefixIcon: Icons.apartment_outlined,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Documento (CNPJ/CPF)',
          controller: _document,
          prefixIcon: Icons.badge_outlined,
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
          label: 'E-mail',
          controller: _email,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Endereço',
          controller: _address,
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
