import '../../domain/entities/app_user.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

/// Estado da sessão de autenticação, observado pelo roteador para decidir a
/// navegação (login vs. área logada).
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.unauthenticated({String? error})
      : this(status: AuthStatus.unauthenticated, errorMessage: error);
  const AuthState.authenticating() : this(status: AuthStatus.authenticating);
  const AuthState.authenticated(AppUser user)
      : this(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isBusy => status == AuthStatus.authenticating;
}
