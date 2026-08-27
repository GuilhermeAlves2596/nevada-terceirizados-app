import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_fields.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/locations_providers.dart';

class LocationFormPage extends ConsumerStatefulWidget {
  const LocationFormPage({super.key});

  @override
  ConsumerState<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends ConsumerState<LocationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  String? _clientId;
  String? _contractId;
  String? _parentLocationId;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      final created = await ref.read(locationRepositoryProvider).create(
            companyId: companyId,
            clientId: _clientId!,
            contractId: _contractId!,
            name: _name.text,
            description: _description.text,
            address: _address.text,
            parentLocationId: _parentLocationId,
          );
      ref.invalidate(locationsProvider);
      ref.invalidate(companyCatalogProvider);
      if (!mounted) return;
      showSuccessSnack(context, 'Ambiente cadastrado! QR: ${created.qrCodeId}');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(companyCatalogProvider).valueOrNull;
    final clients = catalog?.clientsById.values ?? const [];
    final contracts = (catalog?.contractsById.values ?? const [])
        .where((c) => c.clientId == _clientId)
        .toList();
    final parents = (catalog?.locationsById.values ?? const [])
        .where((l) => l.contractId == _contractId)
        .toList();

    return AppFormScaffold(
      title: 'Novo ambiente',
      formKey: _formKey,
      submitLabel: 'Cadastrar',
      submitting: _saving,
      onSubmit: _save,
      children: [
        AppDropdownField<String>(
          label: 'Cliente',
          required: true,
          value: _clientId,
          icon: Icons.apartment_outlined,
          items: [
            for (final c in clients)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: (v) => setState(() {
            _clientId = v;
            _contractId = null;
            _parentLocationId = null;
          }),
        ),
        AppSpacing.gapMd,
        AppDropdownField<String>(
          label: 'Contrato',
          required: true,
          fieldKey: ValueKey('contract_$_clientId'),
          value: _contractId,
          icon: Icons.description_outlined,
          enabled: _clientId != null,
          hint: _clientId == null ? 'Selecione um cliente primeiro' : null,
          items: [
            for (final c in contracts)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: (v) => setState(() {
            _contractId = v;
            _parentLocationId = null;
          }),
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Nome do ambiente',
          controller: _name,
          required: true,
          hint: 'Ex.: Banheiro Bloco A',
          prefixIcon: Icons.meeting_room_outlined,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Descrição',
          controller: _description,
          prefixIcon: Icons.notes_outlined,
          maxLines: 2,
        ),
        AppSpacing.gapMd,
        AppTextFormField(
          label: 'Endereço',
          controller: _address,
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        AppSpacing.gapMd,
        AppDropdownField<String?>(
          label: 'Local pai (opcional)',
          fieldKey: ValueKey('parent_$_contractId'),
          value: _parentLocationId,
          icon: Icons.account_tree_outlined,
          enabled: _contractId != null,
          hint: 'Nenhum',
          items: [
            const DropdownMenuItem(value: null, child: Text('Nenhum')),
            for (final l in parents)
              DropdownMenuItem(value: l.id, child: Text(l.name)),
          ],
          onChanged: (v) => setState(() => _parentLocationId = v),
        ),
        AppSpacing.gapSm,
      ],
    );
  }
}
