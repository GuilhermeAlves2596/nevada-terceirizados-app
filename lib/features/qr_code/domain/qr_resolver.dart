import '../../locations/domain/repositories/location_repository.dart';
import '../../tasks/domain/repositories/task_repository.dart';
import 'qr_payload.dart';

/// Resultado da resolução de um QR Code escaneado.
sealed class QrResolveResult {
  const QrResolveResult();
}

/// Sucesso: há uma tarefa aberta do funcionário neste ambiente.
class QrResolveSuccess extends QrResolveResult {
  const QrResolveSuccess({required this.taskId, required this.locationName});
  final String taskId;
  final String locationName;
}

/// Falha com mensagem amigável (inválido, outra empresa, sem tarefa...).
class QrResolveFailure extends QrResolveResult {
  const QrResolveFailure(this.message);
  final String message;
}

/// Resolve um QR Code em uma tarefa executável, aplicando as validações do
/// fluxo (seção 19): identifica o ambiente, garante que pertence à empresa do
/// usuário e que existe uma tarefa aberta atribuída a ele ali.
class QrResolver {
  const QrResolver(this._locations, this._tasks);

  final LocationRepository _locations;
  final TaskRepository _tasks;

  Future<QrResolveResult> resolve({
    required String companyId,
    required String employeeId,
    required String rawPayload,
  }) async {
    final payload = QrPayload.tryDecode(rawPayload);
    if (payload == null) {
      return const QrResolveFailure('QR Code inválido ou não reconhecido.');
    }

    // A busca por companyId garante o isolamento entre empresas: um QR de outra
    // empresa simplesmente não resolve para este usuário.
    final location = await _locations.getByQrCodeId(
      companyId: companyId,
      qrCodeId: payload.code,
    );
    if (location == null) {
      return const QrResolveFailure(
        'Ambiente não encontrado para a sua empresa.',
      );
    }

    final myTasks =
        await _tasks.getForEmployee(companyId: companyId, employeeId: employeeId);
    final here = myTasks.where((t) => t.locationId == location.id).toList();
    final open = here.where((t) => t.status.isOpen).toList();

    if (open.isEmpty) {
      if (here.isNotEmpty) {
        return QrResolveFailure(
          'Não há tarefa pendente para você em ${location.name}.',
        );
      }
      return const QrResolveFailure(
        'Você não possui permissão para acessar este ambiente.',
      );
    }

    // Em andamento primeiro; depois a mais antiga agendada.
    open.sort((a, b) {
      if (a.status.isOpen != b.status.isOpen) return a.status.isOpen ? -1 : 1;
      if (a.isInProgress != b.isInProgress) return a.isInProgress ? -1 : 1;
      return a.scheduledDate.compareTo(b.scheduledDate);
    });

    return QrResolveSuccess(taskId: open.first.id, locationName: location.name);
  }
}
