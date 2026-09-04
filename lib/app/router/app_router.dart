import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../core/widgets/coming_soon_page.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/checklists/domain/entities/checklist.dart';
import '../../features/clients/domain/entities/client.dart';
import '../../features/contracts/domain/entities/contract.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/checklists/presentation/pages/checklist_form_page.dart';
import '../../features/checklists/presentation/pages/checklists_list_page.dart';
import '../../features/clients/presentation/pages/client_form_page.dart';
import '../../features/clients/presentation/pages/clients_list_page.dart';
import '../../features/contracts/presentation/pages/contract_form_page.dart';
import '../../features/contracts/presentation/pages/contracts_list_page.dart';
import '../../features/dashboard/presentation/pages/employee_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/supervisor_dashboard_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/employees/presentation/pages/employees_list_page.dart';
import '../../features/executions/presentation/pages/task_execution_page.dart';
import '../../features/locations/presentation/pages/location_form_page.dart';
import '../../features/locations/presentation/pages/locations_list_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/qr_code/presentation/pages/qr_code_view_page.dart';
import '../../features/supervisors/presentation/pages/supervisor_contracts_page.dart';
import '../../features/supervisors/presentation/pages/supervisors_page.dart';
import '../../features/qr_code/presentation/pages/qr_scanner_page.dart';
import '../../features/tasks/presentation/pages/employee_history_page.dart';
import '../../features/tasks/presentation/pages/employee_tasks_page.dart';
import '../../features/tasks/presentation/pages/new_task_page.dart';
import '../../features/tasks/presentation/pages/supervisor_task_detail_page.dart';
import '../../features/tasks/presentation/pages/supervisor_tasks_page.dart';
import 'route_paths.dart';

/// Roteador da aplicação com guardas por perfil (seção 46).
final routerProvider = Provider<GoRouter>((ref) {
  // Ponte para o go_router "escutar" mudanças de autenticação e reavaliar o
  // redirect (login → área logada e vice-versa).
  final refresh = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref.onDispose(refresh.dispose);
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    refresh.value = next;
  });

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final isLoginRoute = loc == RoutePaths.login;
      final isSplashRoute = loc == RoutePaths.splash;

      // Ainda verificando a sessão persistida → mantém na splash.
      if (auth.status == AuthStatus.unknown) {
        return isSplashRoute ? null : RoutePaths.splash;
      }

      if (!auth.isAuthenticated) {
        final isPublic = isLoginRoute || loc == RoutePaths.forgotPassword;
        return isPublic ? null : RoutePaths.login;
      }

      final role = auth.user!.role;
      // Só o funcionário tem árvore própria; supervisor, gestor (companyAdmin)
      // e admin da plataforma compartilham a árvore do supervisor por ora.
      final home = role.isEmployee
          ? RoutePaths.employeeDashboard
          : RoutePaths.supervisorDashboard;

      // Troca de senha obrigatória (1º acesso com senha temporária).
      final isChangePw = loc == RoutePaths.changePassword;
      if (auth.user!.mustChangePassword) {
        return isChangePw ? null : RoutePaths.changePassword;
      }
      if (isChangePw) return home;

      // Autenticado na splash ou no login → vai pra home do perfil.
      if (isLoginRoute || isSplashRoute) return home;

      // Guardas: cada perfil só acessa sua própria árvore de rotas.
      if (loc.startsWith(RoutePaths.supervisorPrefix) && role.isEmployee) {
        return RoutePaths.employeeDashboard;
      }
      if (loc.startsWith(RoutePaths.employeePrefix) && !role.isEmployee) {
        return RoutePaths.supervisorDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // ---- Funcionário ----
      GoRoute(
        path: RoutePaths.employeeDashboard,
        builder: (context, state) => const EmployeeDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.employeeTasks,
        builder: (context, state) =>
            EmployeeTasksPage(filter: state.uri.queryParameters['filter']),
      ),
      GoRoute(
        path: '${RoutePaths.employeeTasks}/:id',
        builder: (context, state) =>
            TaskExecutionPage(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.employeeQrScanner,
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: RoutePaths.employeeHistory,
        builder: (context, state) => const EmployeeHistoryPage(),
      ),
      GoRoute(
        path: RoutePaths.employeeProfile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.employeeProfileEdit,
        builder: (context, state) => const ProfileEditPage(),
      ),

      // ---- Supervisor ----
      GoRoute(
        path: RoutePaths.supervisorDashboard,
        builder: (context, state) => const SupervisorDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorEmployees,
        builder: (context, state) => const EmployeesListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorEmployeesCreate,
        builder: (context, state) =>
            EmployeeFormPage(existing: state.extra as AppUser?),
      ),
      GoRoute(
        path: RoutePaths.supervisorClients,
        builder: (context, state) => const ClientsListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorClientsCreate,
        builder: (context, state) =>
            ClientFormPage(existing: state.extra as Client?),
      ),
      GoRoute(
        path: RoutePaths.supervisorTasks,
        builder: (context, state) =>
            SupervisorTasksPage(filter: state.uri.queryParameters['filter']),
      ),
      GoRoute(
        path: RoutePaths.supervisorTasksCreate,
        builder: (context, state) =>
            NewTaskPage(existing: state.extra as Task?),
      ),
      GoRoute(
        path: '${RoutePaths.supervisorTasks}/:id',
        builder: (context, state) =>
            SupervisorTaskDetailPage(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.supervisorContracts,
        builder: (context, state) => const ContractsListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorContractsCreate,
        builder: (context, state) =>
            ContractFormPage(existing: state.extra as Contract?),
      ),
      GoRoute(
        path: RoutePaths.supervisorLocations,
        builder: (context, state) => const LocationsListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorLocationsCreate,
        builder: (context, state) => const LocationFormPage(),
      ),
      GoRoute(
        path: '${RoutePaths.supervisorLocations}/:id/qr',
        builder: (context, state) =>
            QrCodeViewPage(locationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.supervisorChecklists,
        builder: (context, state) => const ChecklistsListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorChecklistsCreate,
        builder: (context, state) =>
            ChecklistFormPage(existing: state.extra as Checklist?),
      ),
      GoRoute(
        path: RoutePaths.supervisorReports,
        builder: (context, state) =>
            const ComingSoonPage(title: 'Relatórios'),
      ),
      GoRoute(
        path: RoutePaths.supervisorSupervisors,
        builder: (context, state) => const SupervisorsPage(),
      ),
      GoRoute(
        path: '${RoutePaths.supervisorSupervisors}/:id',
        builder: (context, state) =>
            SupervisorContractsPage(supervisor: state.extra as AppUser),
      ),
      GoRoute(
        path: RoutePaths.supervisorProfile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorProfileEdit,
        builder: (context, state) => const ProfileEditPage(),
      ),
    ],
  );
});
