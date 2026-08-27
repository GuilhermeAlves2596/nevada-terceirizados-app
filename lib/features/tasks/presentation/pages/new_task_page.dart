import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/task_priority.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/task_providers.dart';

class NewTaskPage extends ConsumerStatefulWidget {
  const NewTaskPage({super.key});

  @override
  ConsumerState<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends ConsumerState<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();

  String? _employeeId;
  String? _clientId;
  String? _contractId;
  String? _locationId;
  String? _checklistId;
  DateTime _date = DateTime.now();
  TimeOfDay? _time;
  TaskPriority _priority = TaskPriority.normal;
  bool _saving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    final companyId = user?.companyId;
    if (user == null || companyId == null) return;

    setState(() => _saving = true);
    try {
      final time = _time == null
          ? null
          : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';
      await ref.read(taskRepositoryProvider).create(
            companyId: companyId,
            clientId: _clientId!,
            contractId: _contractId!,
            locationId: _locationId!,
            checklistId: _checklistId!,
            assignedTo: _employeeId!,
            assignedBy: user.id,
            scheduledDate: DateTime(_date.year, _date.month, _date.day),
            scheduledStartTime: time,
            priority: _priority,
          );
      ref.invalidate(supervisorTaskViewsProvider);
      ref.invalidate(employeeTaskViewsProvider);
      if (!mounted) return;
      showSuccessSnack(context, 'Tarefa atribuída com sucesso!');
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(companyCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova tarefa')),
      body: catalogAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            AppErrorState(onRetry: () => ref.invalidate(companyCatalogProvider)),
        data: (catalog) {
          final employees = catalog.usersById.values
              .where((u) => u.role.isEmployee && u.active)
              .toList();
          final clients = catalog.clientsById.values.toList();
          final contracts = catalog.contractsById.values
              .where((c) => c.clientId == _clientId)
              .toList();
          final locations = catalog.locationsById.values
              .where((l) => l.contractId == _contractId)
              .toList();
          final checklists =
              catalog.checklistsById.values.where((c) => c.active).toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _dropdown<String>(
                  label: 'Funcionário',
                  value: _employeeId,
                  icon: Icons.person_outline,
                  items: [
                    for (final e in employees)
                      DropdownMenuItem(value: e.id, child: Text(e.name)),
                  ],
                  onChanged: (v) => setState(() => _employeeId = v),
                ),
                AppSpacing.gapMd,
                _dropdown<String>(
                  label: 'Cliente',
                  value: _clientId,
                  icon: Icons.apartment_outlined,
                  items: [
                    for (final c in clients)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() {
                    _clientId = v;
                    _contractId = null;
                    _locationId = null;
                  }),
                ),
                AppSpacing.gapMd,
                _dropdown<String>(
                  label: 'Contrato',
                  fieldKey: ValueKey('contract_$_clientId'),
                  value: _contractId,
                  icon: Icons.description_outlined,
                  enabled: _clientId != null,
                  emptyHint: 'Selecione um cliente primeiro',
                  items: [
                    for (final c in contracts)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() {
                    _contractId = v;
                    _locationId = null;
                  }),
                ),
                AppSpacing.gapMd,
                _dropdown<String>(
                  label: 'Local / Ambiente',
                  fieldKey: ValueKey('location_$_contractId'),
                  value: _locationId,
                  icon: Icons.location_on_outlined,
                  enabled: _contractId != null,
                  emptyHint: 'Selecione um contrato primeiro',
                  items: [
                    for (final l in locations)
                      DropdownMenuItem(value: l.id, child: Text(l.name)),
                  ],
                  onChanged: (v) => setState(() => _locationId = v),
                ),
                AppSpacing.gapMd,
                _dropdown<String>(
                  label: 'Checklist',
                  value: _checklistId,
                  icon: Icons.checklist_outlined,
                  items: [
                    for (final c in checklists)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _checklistId = v),
                ),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(
                      child: _pickerField(
                        label: 'Data',
                        icon: Icons.event_outlined,
                        value: _date.ddMMyyyy,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickerField(
                        label: 'Horário',
                        icon: Icons.schedule_outlined,
                        value: _time == null ? 'Opcional' : _time!.format(context),
                        muted: _time == null,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                _dropdown<TaskPriority>(
                  label: 'Prioridade',
                  value: _priority,
                  icon: Icons.flag_outlined,
                  items: [
                    for (final p in TaskPriority.values)
                      DropdownMenuItem(value: p, child: Text(p.label)),
                  ],
                  onChanged: (v) => setState(() => _priority = v ?? _priority),
                  validator: (_) => null,
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: 'Atribuir tarefa',
          icon: Icons.assignment_turned_in_outlined,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
    String? emptyHint,
    String? Function(T?)? validator,
    Key? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.subtitle),
        AppSpacing.gapXs,
        DropdownButtonFormField<T>(
          key: fieldKey,
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator ?? (v) => v == null ? 'Selecione uma opção' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            hintText: enabled ? 'Selecione' : (emptyHint ?? 'Indisponível'),
          ),
        ),
      ],
    );
  }

  Widget _pickerField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    bool muted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.subtitle),
        AppSpacing.gapXs,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            ),
            child: Text(
              value,
              style: muted ? AppTypography.bodyMuted : AppTypography.body,
            ),
          ),
        ),
      ],
    );
  }
}
