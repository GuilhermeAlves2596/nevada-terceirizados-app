import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/enums/contract_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_fields.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/contract.dart';
import '../providers/contracts_providers.dart';

class ContractFormPage extends ConsumerStatefulWidget {
  const ContractFormPage({super.key, this.existing});

  final Contract? existing;

  @override
  ConsumerState<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends ConsumerState<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  String? _clientId;
  DateTime? _startDate;
  DateTime? _endDate;
  late ContractStatus _status;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _clientId = c?.clientId;
    _startDate = c?.startDate;
    _endDate = c?.endDate;
    _status = c?.status ?? ContractStatus.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _invalidate() {
    ref.invalidate(contractsProvider);
    ref.invalidate(companyCatalogProvider);
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (start ? _startDate : _endDate) ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => start ? _startDate = picked : _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(contractRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          id: widget.existing!.id,
          clientId: _clientId!,
          name: _name.text,
          description: _description.text,
          startDate: _startDate,
          endDate: _endDate,
          status: _status,
        );
      } else {
        await repo.create(
          companyId: companyId,
          clientId: _clientId!,
          name: _name.text,
          description: _description.text,
          startDate: _startDate,
          endDate: _endDate,
          status: _status,
        );
      }
      _invalidate();
      if (!mounted) return;
      showSuccessSnack(context, _isEditing ? 'Contrato atualizado!' : 'Contrato cadastrado!');
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
      title: 'Excluir contrato',
      message: 'Excluir "${widget.existing!.name}"?',
      confirmLabel: 'Excluir',
      danger: true,
    );
    if (!ok) return;
    await ref.read(contractRepositoryProvider).delete(widget.existing!.id);
    _invalidate();
    if (!mounted) return;
    showSuccessSnack(context, 'Contrato excluído.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final clients =
        ref.watch(companyCatalogProvider).valueOrNull?.clientsById ?? const {};

    return AppFormScaffold(
      title: _isEditing ? 'Editar contrato' : 'Novo contrato',
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
        AppDropdownField<String>(
          label: 'Cliente',
          required: true,
          value: _clientId,
          icon: Icons.apartment_outlined,
          items: [
            for (final c in clients.values)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: (v) => setState(() => _clientId = v),
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Nome do contrato',
          controller: _name,
          required: true,
          hint: 'Ex.: Contrato de Limpeza 2026',
          prefixIcon: Icons.description_outlined,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Descrição',
          controller: _description,
          prefixIcon: Icons.notes_outlined,
          maxLines: 3,
        ),
        AppSpacing.gapMd,
        Row(
          children: [
            Expanded(
              child: AppDatePickerField(
                label: 'Início',
                value: _startDate?.ddMMyyyy,
                onTap: () => _pickDate(start: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppDatePickerField(
                label: 'Término',
                value: _endDate?.ddMMyyyy,
                onTap: () => _pickDate(start: false),
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,
        AppDropdownField<ContractStatus>(
          label: 'Situação',
          value: _status,
          icon: Icons.flag_outlined,
          items: [
            for (final s in ContractStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
      ],
    );
  }
}
