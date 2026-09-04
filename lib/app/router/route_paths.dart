/// Caminhos de rota centralizados (seção 46).
///
/// Nem todas as rotas estão implementadas na Fase 1 — as demais entram nas
/// próximas fases. Mantê-las aqui evita strings mágicas espalhadas.
abstract final class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';

  // Funcionário
  static const employeeDashboard = '/employee/dashboard';
  static const employeeTasks = '/employee/tasks';
  static const employeeQrScanner = '/employee/qr-scanner';
  static const employeeHistory = '/employee/history';
  static const employeeProfile = '/employee/profile';
  static const employeeProfileEdit = '/employee/profile/edit';

  // Supervisor
  static const supervisorDashboard = '/supervisor/dashboard';
  static const supervisorEmployees = '/supervisor/employees';
  static const supervisorEmployeesCreate = '/supervisor/employees/create';
  static const supervisorClients = '/supervisor/clients';
  static const supervisorClientsCreate = '/supervisor/clients/create';
  static const supervisorContracts = '/supervisor/contracts';
  static const supervisorContractsCreate = '/supervisor/contracts/create';
  static const supervisorLocations = '/supervisor/locations';
  static const supervisorLocationsCreate = '/supervisor/locations/create';
  static const supervisorChecklists = '/supervisor/checklists';
  static const supervisorChecklistsCreate = '/supervisor/checklists/create';
  static const supervisorTasks = '/supervisor/tasks';
  static const supervisorTasksCreate = '/supervisor/tasks/create';
  static const supervisorReports = '/supervisor/reports';
  static const supervisorSupervisors = '/supervisor/supervisors';
  static const supervisorProfile = '/supervisor/profile';
  static const supervisorProfileEdit = '/supervisor/profile/edit';

  static const employeePrefix = '/employee';
  static const supervisorPrefix = '/supervisor';
}
