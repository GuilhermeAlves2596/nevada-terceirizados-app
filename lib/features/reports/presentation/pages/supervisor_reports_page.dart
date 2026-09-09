import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/report_providers.dart';

/// Relatório de tarefas executadas do supervisor — recortado pelo escopo dele
/// (contratos/clientes vinculados). Filtros por período, contrato e funcionário.
class SupervisorReportsPage extends ConsumerStatefulWidget {
  const SupervisorReportsPage({super.key});

  @override
  ConsumerState<SupervisorReportsPage> createState() =>
      _SupervisorReportsPageState();
}

class _SupervisorReportsPageState
    extends ConsumerState<SupervisorReportsPage> {
  late DateTimeRange _range;
  String? _contractId;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 30)),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  bool _inRange(DateTime? d) {
    if (d == null) return false;
    final day = DateTime(d.year, d.month, d.day);
    return !day.isBefore(_range.start) && !day.isAfter(_range.end);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  void _clearFilters() {
    final now = DateTime.now();
    setState(() {
      _range = DateTimeRange(
        start: DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 30)),
        end: DateTime(now.year, now.month, now.day),
      );
      _contractId = null;
      _employeeId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(supervisorReportRowsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Não foi possível carregar o relatório.'),
        ),
        data: (rows) {
          // Opções de filtro derivadas do escopo (só o que o supervisor vê).
          final contracts = <String, String>{};
          final employees = <String, String>{};
          for (final r in rows) {
            contracts[r.contractId] = r.contractName;
            employees[r.employeeId] = r.employeeName;
          }

          final filtered = rows.where((r) {
            if (!_inRange(r.date)) return false;
            if (_contractId != null && r.contractId != _contractId) return false;
            if (_employeeId != null && r.employeeId != _employeeId) return false;
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _FiltersCard(
                rangeLabel:
                    '${_fmtDate(_range.start)} – ${_fmtDate(_range.end)}',
                onPickRange: _pickRange,
                contractId: _contractId,
                contracts: contracts,
                onContract: (v) => setState(() => _contractId = v),
                employeeId: _employeeId,
                employees: employees,
                onEmployee: (v) => setState(() => _employeeId = v),
                onClear: _clearFilters,
              ),
              AppSpacing.gapMd,
              Text(
                '${filtered.length} tarefa(s) executada(s)',
                style: TextStyle(
                  color: context.c.textMuted,
                  fontSize: 13,
                ),
              ),
              AppSpacing.gapSm,
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: context.c.border),
                  ),
                  child: Text(
                    'Nenhuma tarefa executada no período/filtros.',
                    style: TextStyle(color: context.c.textMuted),
                  ),
                )
              else
                ...filtered.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ReportCard(
                        row: r,
                        onTap: () => _openDetail(r),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(ReportRow r) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _DetailSheet(row: r),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtDateTime(DateTime? d) {
  if (d == null) return '—';
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${_fmtDate(d)} $h:$m';
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.rangeLabel,
    required this.onPickRange,
    required this.contractId,
    required this.contracts,
    required this.onContract,
    required this.employeeId,
    required this.employees,
    required this.onEmployee,
    required this.onClear,
  });

  final String rangeLabel;
  final VoidCallback onPickRange;
  final String? contractId;
  final Map<String, String> contracts;
  final ValueChanged<String?> onContract;
  final String? employeeId;
  final Map<String, String> employees;
  final ValueChanged<String?> onEmployee;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.c.card,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: context.c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: AppRadius.brMd,
            onTap: onPickRange,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Período',
                prefixIcon: Icon(Icons.date_range_outlined),
              ),
              child: Text(rangeLabel),
            ),
          ),
          AppSpacing.gapSm,
          DropdownButtonFormField<String?>(
            initialValue: contractId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Contrato'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...contracts.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: onContract,
          ),
          AppSpacing.gapSm,
          DropdownButtonFormField<String?>(
            initialValue: employeeId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Funcionário'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...employees.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: onEmployee,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClear,
              child: const Text('Limpar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.row, required this.onTap});

  final ReportRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photos = row.execution.photos
        .where((p) => (p.downloadUrl ?? '').isNotEmpty)
        .toList();
    return Material(
      color: context.c.card,
      borderRadius: AppRadius.brLg,
      child: InkWell(
        borderRadius: AppRadius.brLg,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            border: Border.all(color: context.c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${row.checklistName} · ${row.locationName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${row.contractName} · ${row.employeeName}',
                          style: TextStyle(
                            color: context.c.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    row.date == null ? '—' : _fmtDate(row.date!),
                    style: TextStyle(
                      color: context.c.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (photos.isNotEmpty) ...[
                AppSpacing.gapSm,
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length > 6 ? 6 : photos.length,
                    separatorBuilder: (_, _) => AppSpacing.hGapXs,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: AppRadius.brSm,
                      child: Image.network(
                        photos[i].downloadUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 56,
                          height: 56,
                          color: context.c.surface,
                          child: Icon(Icons.broken_image_outlined,
                              size: 20, color: context.c.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.row});

  final ReportRow row;

  @override
  Widget build(BuildContext context) {
    final e = row.execution;
    final photos =
        e.photos.where((p) => (p.downloadUrl ?? '').isNotEmpty).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.c.border,
                borderRadius: AppRadius.brPill,
              ),
            ),
          ),
          Text(
            row.checklistName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.c.textPrimary,
            ),
          ),
          Text(
            row.locationName,
            style: TextStyle(color: context.c.textMuted),
          ),
          AppSpacing.gapMd,
          _kv(context, 'Cliente', row.clientName),
          _kv(context, 'Contrato', row.contractName),
          _kv(context, 'Funcionário', row.employeeName),
          _kv(context, 'Início', _fmtDateTime(e.startedAt)),
          _kv(context, 'Conclusão', _fmtDateTime(e.finishedAt)),
          if (e.items.isNotEmpty) ...[
            AppSpacing.gapMd,
            const Text('Checklist',
                style: TextStyle(fontWeight: FontWeight.w600)),
            AppSpacing.gapXs,
            ...e.items.map((it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        it.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: it.completed
                            ? AppColors.success
                            : context.c.border,
                      ),
                      AppSpacing.hGapXs,
                      Expanded(
                        child: Text(
                          it.description,
                          style: TextStyle(
                            color: it.completed
                                ? context.c.textPrimary
                                : context.c.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if ((e.observation ?? '').isNotEmpty) ...[
            AppSpacing.gapMd,
            const Text('Observação',
                style: TextStyle(fontWeight: FontWeight.w600)),
            AppSpacing.gapXs,
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.c.surface,
                borderRadius: AppRadius.brMd,
              ),
              child: Text(e.observation!),
            ),
          ],
          if (photos.isNotEmpty) ...[
            AppSpacing.gapMd,
            Text('Fotos (${photos.length})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            AppSpacing.gapXs,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: photos
                  .map((p) => GestureDetector(
                        onTap: () => _openPhoto(context, p.downloadUrl!),
                        child: ClipRRect(
                          borderRadius: AppRadius.brSm,
                          child: Image.network(
                            p.downloadUrl!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 96,
                              height: 96,
                              color: context.c.surface,
                              child: Icon(Icons.broken_image_outlined,
                                  color: context.c.textMuted),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          AppSpacing.gapLg,
        ],
      ),
    );
  }

  static Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(k,
                  style: TextStyle(color: context.c.textMuted)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );

  void _openPhoto(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
