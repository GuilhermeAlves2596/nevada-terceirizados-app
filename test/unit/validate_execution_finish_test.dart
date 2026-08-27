import 'package:flutter_test/flutter_test.dart';
import 'package:nevada_terceirizados/features/executions/domain/entities/execution_item.dart';
import 'package:nevada_terceirizados/features/executions/domain/entities/execution_photo.dart';
import 'package:nevada_terceirizados/features/executions/domain/entities/task_execution.dart';
import 'package:nevada_terceirizados/features/executions/domain/usecases/validate_execution_finish.dart';

final _now = DateTime(2026, 8, 27);

ExecutionItem _item(int i, {required bool completed, bool required = true}) =>
    ExecutionItem(
      id: 'i$i',
      checklistItemId: 'ci$i',
      description: 'Item $i',
      order: i,
      required: required,
      completed: completed,
    );

TaskExecution _exec({
  required List<ExecutionItem> items,
  bool withPhoto = false,
}) =>
    TaskExecution(
      id: 'e1',
      companyId: 'c1',
      taskId: 't1',
      employeeId: 'u1',
      items: items,
      photos: [
        if (withPhoto)
          ExecutionPhoto(
            id: 'p1',
            companyId: 'c1',
            taskExecutionId: 'e1',
            storagePath: 'mock',
            createdAt: _now,
          ),
      ],
      createdAt: _now,
      updatedAt: _now,
    );

void main() {
  const validate = ValidateExecutionFinish();

  test('bloqueia quando há item obrigatório pendente', () {
    final result = validate(_exec(
      items: [_item(0, completed: true), _item(1, completed: false)],
      withPhoto: true,
    ));
    expect(result.canFinish, isFalse);
    expect(result.message, contains('1 atividade obrigatória'));
  });

  test('mensagem no plural para múltiplos pendentes', () {
    final result = validate(_exec(
      items: [_item(0, completed: false), _item(1, completed: false)],
      withPhoto: true,
    ));
    expect(result.canFinish, isFalse);
    expect(result.message, contains('2 atividades obrigatórias'));
  });

  test('item opcional pendente não bloqueia', () {
    final result = validate(_exec(
      items: [
        _item(0, completed: true),
        _item(1, completed: false, required: false),
      ],
      withPhoto: true,
    ));
    expect(result.canFinish, isTrue);
  });

  test('bloqueia quando falta foto', () {
    final result = validate(_exec(
      items: [_item(0, completed: true)],
      withPhoto: false,
    ));
    expect(result.canFinish, isFalse);
    expect(result.message, contains('foto'));
  });

  test('permite finalizar com obrigatórios concluídos e foto', () {
    final result = validate(_exec(
      items: [_item(0, completed: true), _item(1, completed: true)],
      withPhoto: true,
    ));
    expect(result.canFinish, isTrue);
    expect(result.message, isNull);
  });
}
