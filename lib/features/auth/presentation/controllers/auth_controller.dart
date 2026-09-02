import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import 'auth_state.dart';

/// Controla o ciclo de vida da sessão do usuário.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Agenda a restauração para depois do build (não altera estado no build).
    Future.microtask(_restore);
    return const AuthState.unknown();
  }

  /// Restaura a sessão persistida do Firebase (se houver) ao abrir o app.
  Future<void> _restore() async {
    try {
      final user = await ref.read(authRepositoryProvider).currentUser();
      state = user != null
          ? AuthState.authenticated(user)
          : const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(identifier: identifier, password: password);
      state = AuthState.authenticated(user);
    } on AppException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
    } catch (_) {
      state = const AuthState.unauthenticated(
        error: 'Não foi possível entrar. Tente novamente.',
      );
    }
  }

  /// Troca a senha do usuário logado (fluxo de 1º acesso). Retorna a mensagem
  /// de erro, ou `null` em caso de sucesso.
  Future<String?> changePassword(String newPassword) async {
    try {
      final user =
          await ref.read(authRepositoryProvider).changePassword(newPassword);
      state = AuthState.authenticated(user);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível trocar a senha. Tente novamente.';
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.unauthenticated();
  }

  /// Limpa a mensagem de erro (ex.: ao editar o formulário novamente).
  void clearError() {
    if (state.errorMessage != null) {
      state = AuthState.unauthenticated(error: null);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Usuário autenticado atual (ou `null`). Usado amplamente na apresentação.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).user;
});
