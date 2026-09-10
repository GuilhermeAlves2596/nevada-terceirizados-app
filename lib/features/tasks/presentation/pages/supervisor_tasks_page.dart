import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../models/task_view.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

const _statusLabels = <String, String>{
  'all': 'Todas',
  'pending': 'Pendentes',
  'inProgress': 'Em andamento',
  'completed': 'Concluídas',
  'cancelled': 'Canceladas',
  'late': 'Atrasadas',
};

class SupervisorTasksPage extends ConsumerStatefulWidget {
  const SupervisorTasksPage({super.key, this.filter});

  /// Status inicial (via query param): all | pending | inProgress | completed
  /// | cancelled | late.
  final String? filter;

  @override
  ConsumerState<SupervisorTasksPage> createState() =>
      _SupervisorTasksPageState();
}

class _SupervisorTasksPageState extends ConsumerState<SupervisorTasksPage> {
  late String _status;
  String? _employeeId;
  String? _locationId;
  String? _checklistId;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _status = widget.filter ?? 'all';
  }

  int get _activeCount =>
      (_status != 'all' ? 1 : 0) +
      (_employeeId != null ? 1 : 0) +
      (_locationId != null ? 1 : 0) +
      (_checklistId != null ? 1 : 0) +
      (_range != null ? 1 : 0);

  bool _matches(TaskView v, DateTime now) {
    final t = v.task;
    switch (_status) {
      case 'pending':
        if (!t.isPending) return false;
      case 'inProgress':
        if (!t.isInProgress) return false;
      case 'completed':
        if (!t.isCompleted) return false;
      case 'cancelled':
        if (!t.isCancelled) return false;
      case 'late':
        if (!t.isLate(now)) return false;
    }
    if (_employeeId != null && t.assignedTo != _employeeId) return false;
    if (_locationId != null && t.locationId != _locationId) return false;
    if (_checklistId != null && t.checklistId != _checklistId) return false;
    if (_range != null) {
      final d = DateTime(
          t.scheduledDate.year, t.scheduledDate.month, t.scheduledDate.day);
      if (d.isBefore(_range!.start) || d.isAfter(_range!.end)) return false;
    }
    return true;
  }

  void _clear() {
    setState(() {
      _status = 'all';
      _employeeId = null;
      _locationId = null;
      _checklistId = null;
      _range = null;
    });
  }

  Future<void> _openFilters(List<TaskView> all) async {
    final employees = <String, String>{};
    final locations = <String, String>{};
    final checklists = <String, String>{};
    for (final v in all) {
      employees[v.task.assignedTo] = v.employeeName;
      locations[v.task.locationId] = v.locationName;
      checklists[v.task.checklistId] = v.checklistName;
    }

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        status: _status,
        employeeId: _employeeId,
        locationId: _locationId,
        checklistId: _checklistId,
        range: _range,
        employees: employees,
        locations: locations,
        checklists: checklists,
      ),
    );
    if (result != null) {
      setState(() {
        _status = result.status;
        _employeeId = result.employeeId;
        _locationId = result.locationId;
        _checklistId = result.checklistId;
        _range = result.range;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(supervisorTaskViewsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _status == 'all' ? 'Tarefas' : _statusLabels[_status] ?? 'Tarefas',
        ),
        actions: [
          async.maybeWhen(
            data: (all) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Filtrar',
                  onPressed: () => _openFilters(all),
                  icon: Icon(_activeCount > 0
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined),
                ),
                if (_activeCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_activeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
              onRetry: () => ref.invalidate(supervisorTaskViewsProvider)),
          data: (all) {
            final items = all.where((v) => _matches(v, now)).toList();
            return Column(
              children: [
                if (_activeCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                        AppSpacing.sm, AppSpacing.md, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${items.length} tarefa(s) · $_activeCount filtro(s)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: _clear,
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.assignment_outlined,
                          message: 'Nenhuma tarefa com esses filtros.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => refreshSupervisorTasks(ref),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => AppSpacing.gapSm,
                            itemBuilder: (context, i) {
                              final v = items[i];
                              return TaskCard(
                                view: v,
                                showEmployee: true,
                                onTap: () => context.push(
                                    '${RoutePaths.supervisorTasks}/${v.task.id}'),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({
    required this.status,
    this.employeeId,
    this.locationId,
    this.checklistId,
    this.range,
  });
  final String status;
  final String? employeeId;
  final String? locationId;
  final String? checklistId;
  final DateTimeRange? range;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.status,
    required this.employeeId,
    required this.locationId,
    required this.checklistId,
    required this.range,
    required this.employees,
    required this.locations,
    required this.checklists,
  });

  final String status;
  final String? employeeId;
  final String? locationId;
  final String? checklistId;
  final DateTimeRange? range;
  final Map<String, String> employees;
  final Map<String, String> locations;
  final Map<String, String> checklists;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _status = widget.status;
  late String? _employeeId = widget.employeeId;
  late String? _locationId = widget.locationId;
  late String? _checklistId = widget.checklistId;
  late DateTimeRange? _range = widget.range;

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.xs,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
            AppSpacing.gapMd,
            DropdownButtonFormField<String>(
              initialValue: _status,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statusLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? 'all'),
            ),
            AppSpacing.gapSm,
            _optionDropdown(
              label: 'Funcionário',
              value: _employeeId,
              options: widget.employees,
              onChanged: (v) => setState(() => _employeeId = v),
            ),
            AppSpacing.gapSm,
            _optionDropdown(
              label: 'Local',
              value: _locationId,
              options: widget.locations,
              onChanged: (v) => setState(() => _locationId = v),
            ),
            AppSpacing.gapSm,
            _optionDropdown(
              label: 'Checklist',
              value: _checklistId,
              options: widget.checklists,
              onChanged: (v) => setState(() => _checklistId = v),
            ),
            AppSpacing.gapSm,
            InkWell(
              borderRadius: AppRadius.brMd,
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 3),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: _range,
                );
                if (picked != null) setState(() => _range = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Período (início – fim)',
                  prefixIcon: const Icon(Icons.date_range_outlined),
                  suffixIcon: _range == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _range = null),
                        ),
                ),
                child: Text(
                  _range == null
                      ? 'Qualquer data'
                      : '${_d(_range!.start)} – ${_d(_range!.end)}',
                ),
              ),
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const _FilterResult(status: 'all'),
                    ),
                    child: const Text('Limpar'),
                  ),
                ),
                AppSpacing.hGapSm,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _FilterResult(
                        status: _status,
                        employeeId: _employeeId,
                        locationId: _locationId,
                        checklistId: _checklistId,
                        range: _range,
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionDropdown({
    required String label,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final entries = options.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...entries.map(
          (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
