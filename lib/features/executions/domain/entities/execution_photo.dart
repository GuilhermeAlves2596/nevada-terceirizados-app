import 'package:freezed_annotation/freezed_annotation.dart';

part 'execution_photo.freezed.dart';

/// Metadados de uma foto de execução (seção 18).
///
/// O arquivo em si vai para o Firebase Storage; o Firestore guarda apenas a
/// referência ([storagePath] / [downloadUrl]).
@freezed
abstract class ExecutionPhoto with _$ExecutionPhoto {
  const factory ExecutionPhoto({
    required String id,
    required String companyId,
    required String taskExecutionId,
    required String storagePath,
    String? downloadUrl,

    /// Caminho de um arquivo local ainda não enviado (suporte a modo offline).
    String? localPath,
    required DateTime createdAt,
    String? createdBy,
  }) = _ExecutionPhoto;
}
