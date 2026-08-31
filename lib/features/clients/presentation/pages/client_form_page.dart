import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_providers.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key, this.existing});

  final Client? existing;

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _document;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _document = TextEditingController(text: c?.document ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _document.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  void _invalidate() {
    ref.invalidate(clientsProvider);
    ref.invalidate(companyCatalogProvider);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(clientRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          id: widget.existing!.id,
          name: _name.text,
          document: _document.text,
          phone: _phone.text,
          email: _email.text,
          address: _address.text,
        );
      } else {
        await repo.create(
          companyId: companyId,
          name: _name.text,
          document: _document.text,
          phone: _phone.text,
          email: _email.text,
          address: _address.text,
        );
      }
      _invalidate();
      if (!mounted) return;
      showSuccessSnack(context, _isEditing ? 'Cliente atualizado!' : 'Cliente cadastrado!');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir cliente',
      message: 'Excluir "${widget.existing!.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(clientRepositoryProvider).delete(widget.existing!.id);
      _invalidate();
      if (!mounted) return;
      showSuccessSnack(context, 'Cliente excluído.');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScaffold(
      title: _isEditing ? 'Editar cliente' : 'Novo cliente',
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
