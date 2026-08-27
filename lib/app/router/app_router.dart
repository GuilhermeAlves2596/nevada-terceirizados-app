import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/employee_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/supervisor_dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
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
        path: RoutePaths.employeeProfile,
        builder: (context, state) => const ProfilePage(),
      ),

      // ---- Supervisor ----
      GoRoute(
        path: RoutePaths.supervisorDashboard,
        builder: (context, state) => const SupervisorDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.supervisorProfile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
