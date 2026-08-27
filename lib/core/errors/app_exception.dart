/// Exceções de domínio com mensagens amigáveis ao usuário (seção 48).
///
/// Nunca exponha stack trace ou detalhes internos ao usuário final.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Mensagem pronta para exibição na interface.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Falha na autenticação.']);
}

class PermissionException extends AppException {
  const PermissionException([
    super.message = 'Você não possui permissão para esta ação.',
  ]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Sem conexão. Verifique sua internet e tente novamente.',
  ]);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Falha ao salvar o arquivo.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Registro não encontrado.']);
}
