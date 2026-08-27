/// Situação da execução real de uma tarefa (seção 16).
enum ExecutionStatus {
  notStarted,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        ExecutionStatus.notStarted => 'Não iniciada',
        ExecutionStatus.inProgress => 'Em andamento',
        ExecutionStatus.completed => 'Concluída',
        ExecutionStatus.cancelled => 'Cancelada',
      };

  static ExecutionStatus fromName(String? value) => ExecutionStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ExecutionStatus.notStarted,
      );
}
