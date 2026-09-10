import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'app_exception.dart';

/// Mensagem amigável para qualquer erro capturado numa ação de escrita.
///
/// Cobre os três casos que chegam à UI do supervisor:
/// - [AppException]: já traz mensagem pronta;
/// - [FirebaseFunctionsException]: erro de Cloud Function (ex.: assinatura
///   inativa), com mensagem em PT definida no servidor;
/// - [FirebaseException] `permission-denied`: escrita bloqueada pelas Security
///   Rules — normalmente assinatura inativa da empresa ou acesso limitado.
String messageForError(Object error) {
  if (error is AppException) return error.message;
  if (error is FirebaseFunctionsException) {
    return error.message ?? 'Não foi possível concluir a ação.';
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Sem permissão para esta ação. A assinatura da empresa pode '
          'estar inativa ou seu acesso foi limitado.';
    }
    return error.message ?? 'Não foi possível concluir a ação.';
  }
  return 'Não foi possível concluir a ação. Tente novamente.';
}
