import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/service_type.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_form_fields.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/checklists_providers.dart';

class _ItemDraft {
  _ItemDraft(this.id, this.description);
  final int id;
  String description;
  bool required = true;
}

class ChecklistFormPage extends ConsumerStatefulWidget {
  const ChecklistFormPage({super.key});

  @override
  ConsumerState<ChecklistFormPage> createState() => _ChecklistFormPageState();
}

class _ChecklistFormPageState extends ConsumerState<ChecklistFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _newItem = TextEditingController();
  ServiceType _serviceType = ServiceType.limpeza;
  final List<_ItemDraft> _items = [];
  int _seq = 0;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _newItem.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _newItem.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(_ItemDraft(_seq++, text));
      _newItem.clear();
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      showErrorSnack(context, 'Adicione ao menos um item ao checklist.');
      return;
    }
    final companyId = ref.read(currentUserProvider)?.companyId;
    if (companyId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(checklistRepositoryProvider).create(
            companyId: companyId,
            name: _name.text,
            serviceType: _serviceType,
            description: _description.text,
            items: [
              for (final d in _items)
                (description: d.description, required: d.required),
            ],
          );
      ref.invalidate(checklistsProvider);
      ref.invalidate(companyCatalogProvider);
      if (!mounted) return;
      showSuccessSnack(context, 'Checklist criado!');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo checklist')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextFormField(
              label: 'Nome',
              controller: _name,
              required: true,
              hint: 'Ex.: Limpeza de Banheiro',
              prefixIcon: Icons.checklist_outlined,
            ),
            AppSpacing.gapMd,
            AppDropdownField<ServiceType>(
              label: 'Tipo de serviço',
              value: _serviceType,
              icon: Icons.category_outlined,
              items: [
                for (final s in ServiceType.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => _serviceType = v ?? _serviceType),
            ),
            AppSpacing.gapMd,
            AppTextFormField(
              label: 'Descrição',
              controller: _description,
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                Text('Itens', style: AppTypography.title),
                const SizedBox(width: 8),
                Text('${_items.length}', style: AppTypography.bodyMuted),
                const Spacer(),
                Text('★ = obrigatório', style: AppTypography.caption),
              ],
            ),
            AppSpacing.gapSm,
            _AddItemRow(controller: _newItem, onAdd: _addItem),
            AppSpacing.gapSm,
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  'Nenhum item ainda. Adicione acima e arraste para ordenar.',
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _items.length,
                onReorder: _reorder,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return _ItemTile(
                    key: ValueKey(item.id),
                    index: i,
                    number: i + 1,
                    description: item.description,
                    required: item.required,
                    onToggleRequired: () =>
                        setState(() => item.required = !item.required),
                    onDelete: () => setState(() => _items.removeAt(i)),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: 'Criar checklist',
          icon: Icons.check,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}

class _AddItemRow extends StatelessWidget {
  const _AddItemRow({required this.controller, required this.onAdd});

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
            style: AppTypography.body,
            decoration: const InputDecoration(
              hintText: 'Descreva um item e toque em +',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColors.primary,
          borderRadius: AppRadius.brMd,
          child: InkWell(
            borderRadius: AppRadius.brMd,
            onTap: onAdd,
            child: const SizedBox(
              height: 52,
              width: 52,
              child: Icon(Icons.add, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.index,
    required this.number,
    required this.description,
    required this.required,
    required this.onToggleRequired,
    required this.onDelete,
  });

  final int index;
  final int number;
  final String description;
  final bool required;
  final VoidCallback onToggleRequired;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.drag_indicator, color: AppColors.textMuted),
              ),
            ),
            Text('$number.', style: AppTypography.caption),
            const SizedBox(width: 8),
            Expanded(child: Text(description, style: AppTypography.body)),
            IconButton(
              tooltip: required ? 'Obrigatório' : 'Opcional',
              visualDensity: VisualDensity.compact,
              onPressed: onToggleRequired,
              icon: Icon(
                required ? Icons.star : Icons.star_border,
                color: required ? AppColors.warning : AppColors.textMuted,
                size: 20,
              ),
            ),
            IconButton(
              tooltip: 'Remover',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: const Icon(Icons.close, color: AppColors.danger, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
