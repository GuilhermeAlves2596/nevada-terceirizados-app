import '../entities/task_execution.dart';

/// Resultado da validação de finalização de uma execução.
class FinishValidation {
  const FinishValidation._(this.canFinish, this.message);

  const FinishValidation.ok() : this._(true, null);
  const FinishValidation.blocked(String message) : this._(false, message);

  final bool canFinish;
  final String? message;
}

/// Regra de negócio da finalização (seção 25):
/// todos os itens **obrigatórios** concluídos **e** ao menos uma foto.
class ValidateExecutionFinish {
  const ValidateExecutionFinish();

  FinishValidation call(TaskExecution execution) {
    final pendingRequired =
        execution.items.where((i) => i.required && !i.completed).length;

    if (pendingRequired > 0) {
      final plural = pendingRequired == 1 ? 'atividade obrigatória' : 'atividades obrigatórias';
      final pend = pendingRequired == 1 ? 'pendente' : 'pendentes';
      return FinishValidation.blocked(
        'Você ainda possui $pendingRequired $plural $pend.',
      );
    }

    if (!execution.hasPhoto) {
      return const FinishValidation.blocked(
        'É necessário adicionar uma foto antes de finalizar.',
      );
    }

    return const FinishValidation.ok();
  }
}
