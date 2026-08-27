import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/features/executions/domain/entities/execution_item.dart';
import 'package:nevada_terceirizados/features/executions/domain/entities/task_execution.dart';

TaskExecution _exec(List<bool> completed) {
  final now = DateTime(2026, 8, 27);
  return TaskExecution(
    id: 'e1',
    companyId: 'c1',
    taskId: 't1',
    employeeId: 'u1',
    items: [
      for (var i = 0; i < completed.length; i++)
        ExecutionItem(
          id: 'i$i',
          checklistItemId: 'ci$i',
          description: 'Item $i',
          order: i,
          completed: completed[i],
        ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TaskExecution.progress', () {
    test('sem itens retorna 0', () {
      expect(_exec([]).progress, 0);
    });

    test('6 de 8 itens concluídos retorna 75', () {
      final exec = _exec([true, true, true, true, true, true, false, false]);
      expect(exec.completedItems, 6);
      expect(exec.totalItems, 8);
      expect(exec.progress, 75);
    });

    test('todos concluídos retorna 100', () {
      expect(_exec([true, true, true]).progress, 100);
    });

    test('nenhum concluído retorna 0', () {
      expect(_exec([false, false]).progress, 0);
    });

    test('arredondamento: 1 de 3 ≈ 33', () {
      expect(_exec([true, false, false]).progress, 33);
    });
  });
}
