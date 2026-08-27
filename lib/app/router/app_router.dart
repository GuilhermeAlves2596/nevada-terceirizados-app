import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../core/widgets/coming_soon_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/clients/presentation/pages/client_form_page.dart';
import '../../features/clients/presentation/pages/clients_list_page.dart';
import '../../features/dashboard/presentation/pages/employee_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/supervisor_dashboard_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/employees/presentation/pages/employees_list_page.dart';
import '../../features/executions/presentation/pages/task_execution_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tasks/presentation/pages/employee_history_page.dart';
import '../../features/tasks/presentation/pages/new_task_page.dart';
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
    initialLocation: RoutePaths.login,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final isLoginRoute = loc == RoutePaths.login;

      if (!auth.isAuthenticated) {
        return isLoginRoute ? null : RoutePaths.login;
      }

      final role = auth.user!.role;
      final home = role.isSupervisor
          ? RoutePaths.supervisorDashboard
          : RoutePaths.employeeDashboard;

      // Já autenticado tentando ver o login → manda pra home do perfil.
      if (isLoginRoute) return home;

      // Guardas: cada perfil só acessa sua própria árvore de rotas.
      if (loc.startsWith(RoutePaths.supervisorPrefix) && !role.isSupervisor) {
        return RoutePaths.employeeDashboard;
      }
      if (loc.startsWith(RoutePaths.employeePrefix) && !role.isEmployee) {
        return RoutePaths.supervisorDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),

      // ---- Funcionário ----
      GoRoute(
        path: RoutePaths.employeeDashboard,
        builder: (context, state) => const EmployeeDashboardPage(),
      ),
      GoRoute(
        path: '${RoutePaths.employeeTasks}/:id',
        builder: (context, state) =>
            TaskExecutionPage(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.employeeHistory,
        builder: (context, state) => const EmployeeHistoryPage(),
      ),
      GoRoute(
        path: RoutePaths.employeeProfile,
        builder: (context, state) => const ProfilePage(),
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
        builder: (context, state) => const EmployeeFormPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorClients,
        builder: (context, state) => const ClientsListPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorClientsCreate,
        builder: (context, state) => const ClientFormPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorTasksCreate,
        builder: (context, state) => const NewTaskPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorContracts,
        builder: (context, state) =>
            const ComingSoonPage(title: 'Contratos'),
      ),
      GoRoute(
        path: RoutePaths.supervisorLocations,
        builder: (context, state) => const ComingSoonPage(title: 'Locais'),
      ),
      GoRoute(
        path: RoutePaths.supervisorChecklists,
        builder: (context, state) =>
            const ComingSoonPage(title: 'Checklists'),
      ),
      GoRoute(
        path: RoutePaths.supervisorReports,
        builder: (context, state) =>
            const ComingSoonPage(title: 'Relatórios'),
      ),
      GoRoute(
        path: RoutePaths.supervisorProfile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
