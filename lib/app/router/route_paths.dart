/// Caminhos de rota centralizados (seção 46).
///
/// Nem todas as rotas estão implementadas na Fase 1 — as demais entram nas
/// próximas fases. Mantê-las aqui evita strings mágicas espalhadas.
abstract final class RoutePaths {
  const RoutePaths._();

  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  // Funcionário
  static const employeeDashboard = '/employee/dashboard';
  static const employeeTasks = '/employee/tasks';
  static const employeeQrScanner = '/employee/qr-scanner';
  static const employeeHistory = '/employee/history';
  static const employeeProfile = '/employee/profile';

  // Supervisor
  static const supervisorDashboard = '/supervisor/dashboard';
  static const supervisorEmployees = '/supervisor/employees';
  static const supervisorEmployeesCreate = '/supervisor/employees/create';
  static const supervisorClients = '/supervisor/clients';
  static const supervisorClientsCreate = '/supervisor/clients/create';
  static const supervisorContracts = '/supervisor/contracts';
  static const supervisorLocations = '/supervisor/locations';
  static const supervisorChecklists = '/supervisor/checklists';
  static const supervisorTasks = '/supervisor/tasks';
  static const supervisorTasksCreate = '/supervisor/tasks/create';
  static const supervisorReports = '/supervisor/reports';
  static const supervisorProfile = '/supervisor/profile';

  static const employeePrefix = '/employee';
  static const supervisorPrefix = '/supervisor';
}
