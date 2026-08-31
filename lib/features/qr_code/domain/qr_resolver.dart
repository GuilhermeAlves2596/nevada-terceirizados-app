import '../../tasks/domain/entities/task.dart';
import '../../locations/domain/repositories/location_repository.dart';
import '../../tasks/domain/repositories/task_repository.dart';
import 'qr_payload.dart';

/// Resultado da resolução de um QR Code escaneado.
sealed class QrResolveResult {
  const QrResolveResult();
}

/// Sucesso: as tarefas **abertas do funcionário** neste ambiente (1 ou mais).
class QrResolveSuccess extends QrResolveResult {
  const QrResolveSuccess({required this.tasks, required this.locationName});
  final List<Task> tasks;
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
          'Você não tem tarefa pendente em ${location.name} '
          '(as suas já foram concluídas ou canceladas).',
        );
      }
      return QrResolveFailure(
        'Você não tem tarefa atribuída em ${location.name}.',
      );
    }

    // Em andamento primeiro; depois a mais antiga agendada.
    open.sort((a, b) {
      if (a.isInProgress != b.isInProgress) return a.isInProgress ? -1 : 1;
      return a.scheduledDate.compareTo(b.scheduledDate);
    });

    return QrResolveSuccess(tasks: open, locationName: location.name);
  }
}
