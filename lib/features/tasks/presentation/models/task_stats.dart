import '../../../../core/enums/task_status.dart';
import '../../domain/entities/task.dart';

/// Agrega contagens de tarefas para os dashboards (seções 21 e 28).
class TaskStats {
  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
    required this.late,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int cancelled;
  final int late;

  factory TaskStats.from(List<Task> tasks, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    var pending = 0, inProgress = 0, completed = 0, cancelled = 0, late = 0;
    for (final t in tasks) {
      switch (t.status) {
        case TaskStatus.pending:
          pending++;
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.completed:
          completed++;
        case TaskStatus.cancelled:
          cancelled++;
      }
      if (t.isLate(reference)) late++;
    }
    return TaskStats(
      total: tasks.length,
      pending: pending,
      inProgress: inProgress,
      completed: completed,
      cancelled: cancelled,
      late: late,
    );
  }
}
