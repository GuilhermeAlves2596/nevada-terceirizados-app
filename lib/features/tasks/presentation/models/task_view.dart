import '../../../../app/providers/company_catalog.dart';
import '../../../../core/enums/service_type.dart';
import '../../domain/entities/task.dart';

/// Modelo de apresentação: uma [Task] enriquecida com os nomes resolvidos a
/// partir do [CompanyCatalog]. Evita colocar lógica de "join" nos widgets.
class TaskView {
  const TaskView({
    required this.task,
    required this.locationName,
    required this.clientName,
    required this.checklistName,
    required this.serviceType,
    required this.employeeName,
    required this.supervisorName,
  });

  final Task task;
  final String locationName;
  final String clientName;
  final String checklistName;
  final ServiceType serviceType;
  final String employeeName;
  final String supervisorName;

  factory TaskView.resolve(Task task, CompanyCatalog catalog) {
    final checklist = catalog.checklistsById[task.checklistId];
    return TaskView(
      task: task,
      locationName: catalog.locationsById[task.locationId]?.name ?? 'Ambiente',
      clientName: catalog.clientsById[task.clientId]?.name ?? 'Cliente',
      checklistName: checklist?.name ?? 'Checklist',
      serviceType: checklist?.serviceType ?? ServiceType.limpeza,
      employeeName:
          catalog.usersById[task.assignedTo]?.name ?? 'Funcionário',
      supervisorName:
          catalog.usersById[task.assignedBy]?.name ?? 'Supervisor',
    );
  }

  static List<TaskView> resolveAll(List<Task> tasks, CompanyCatalog catalog) =>
      tasks.map((t) => TaskView.resolve(t, catalog)).toList();
}
