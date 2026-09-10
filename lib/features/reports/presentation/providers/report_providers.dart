import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../executions/domain/entities/task_execution.dart';
import '../../../tasks/domain/entities/task.dart';

/// Uma execução concluída resolvida para o relatório do supervisor.
class ReportRow {
  const ReportRow({
    required this.execution,
    required this.task,
    required this.checklistName,
    required this.locationName,
    required this.contractId,
    required this.contractName,
    required this.clientName,
    required this.employeeId,
    required this.employeeName,
    required this.date,
  });

  final TaskExecution execution;
  final Task task;
  final String checklistName;
  final String locationName;
  final String contractId;
  final String contractName;
  final String clientName;
  final String employeeId;
  final String employeeName;

  /// Data de conclusão (fallback: início).
  final DateTime? date;
}

/// Execuções concluídas da empresa, **recortadas pelo escopo do supervisor**
/// (só contratos/clientes vinculados) — companyAdmin/platformAdmin veem tudo.
final supervisorReportRowsProvider =
    FutureProvider.autoDispose<List<ReportRow>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];

  final scope = ref.watch(dataScopeProvider);
  final catalog = await ref.watch(companyCatalogProvider.future);
  final tasks =
      await ref.watch(taskRepositoryProvider).getForCompany(companyId: companyId);
  final tasksById = {for (final t in tasks) t.id: t};

  final execs = await ref
      .watch(taskExecutionRepositoryProvider)
      .findCompletedForCompany(companyId: companyId);

  final rows = <ReportRow>[];
  for (final e in execs) {
    final task = tasksById[e.taskId];
    if (task == null) continue;
    if (!scope.allowsContract(task.contractId)) continue;
    final checklist = catalog.checklistsById[task.checklistId];
    rows.add(ReportRow(
      execution: e,
      task: task,
      checklistName: checklist?.name ?? 'Checklist',
      locationName: catalog.locationsById[task.locationId]?.name ?? 'Ambiente',
      contractId: task.contractId,
      contractName: catalog.contractsById[task.contractId]?.name ?? 'Contrato',
      clientName: catalog.clientsById[task.clientId]?.name ?? 'Cliente',
      employeeId: e.employeeId,
      employeeName: catalog.usersById[e.employeeId]?.name ?? 'Funcionário',
      date: e.finishedAt ?? e.startedAt,
    ));
  }
  rows.sort((a, b) =>
      (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
  return rows;
});
