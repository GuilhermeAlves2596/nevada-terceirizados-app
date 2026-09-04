import 'package:uuid/uuid.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../../core/utils/credentials.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/new_employee_result.dart';
import '../../domain/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  MockUserRepository(this._db);

  final MockDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<AppUser?> getById(String id) async {
    await _tick();
    for (final u in _db.users) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  Future<List<AppUser>> getAll({required String companyId}) async {
    await _tick();
    return _db.users.where((u) => u.companyId == companyId).toList();
  }

  @override
  Future<List<AppUser>> getEmployees({required String companyId}) async {
    await _tick();
    return _db.users
        .where((u) => u.companyId == companyId && u.role == UserRole.employee)
        .toList();
  }

  @override
  Future<NewEmployeeResult> createEmployee({
    required String companyId,
    required String contractId,
    required String clientId,
    required String name,
    required String cpf,
    String? email,
    String? phone,
    String? jobTitle,
  }) async {
    await _tick();
    final digits = Credentials.cpfDigits(cpf);
    if (digits.length != 11) {
      throw const ValidationException('CPF inválido (11 dígitos).');
    }
    if (_db.users.any((u) => u.cpf == digits)) {
      throw const ValidationException('Já existe um funcionário com este CPF.');
    }
    final trimmedEmail = email?.trim();
    final now = DateTime.now();
    final user = AppUser(
      id: _uuid.v4(),
      companyId: companyId,
      contractIds: [contractId],
      clientIds: [clientId],
      name: name.trim(),
      email: (trimmedEmail == null || trimmedEmail.isEmpty) ? null : trimmedEmail,
      cpf: digits,
      role: UserRole.employee,
      phone: phone?.trim(),
      jobTitle: jobTitle?.trim(),
      mustChangePassword: true,
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertUser(user);
    return NewEmployeeResult(
      user: user,
      temporaryPassword: Credentials.generateTempPassword(),
    );
  }

  @override
  Future<AppUser> update({
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? jobTitle,
  }) async {
    await _tick();
    final current = _db.users.firstWhere((u) => u.id == userId);
    final trimmedEmail = email?.trim();
    final updated = current.copyWith(
      name: name.trim(),
      email: (trimmedEmail == null || trimmedEmail.isEmpty) ? null : trimmedEmail,
      phone: phone?.trim(),
      jobTitle: jobTitle?.trim(),
      updatedAt: DateTime.now(),
    );
    _db.upsertUser(updated);
    return updated;
  }

  @override
  Future<void> delete(String userId) async {
    await _tick();
    _db.users.removeWhere((u) => u.id == userId);
  }

  @override
  Future<AppUser> setActive({
    required String userId,
    required bool active,
  }) async {
    await _tick();
    final user = _db.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw const NotFoundException('Usuário não encontrado.'),
    );
    final updated = user.copyWith(active: active, updatedAt: DateTime.now());
    _db.upsertUser(updated);
    return updated;
  }

  @override
  Future<AppUser> setContracts({
    required String userId,
    required List<String> contractIds,
    required List<String> clientIds,
  }) async {
    await _tick();
    final user = _db.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw const NotFoundException('Usuário não encontrado.'),
    );
    final updated = user.copyWith(
      contractIds: contractIds,
      clientIds: clientIds,
      updatedAt: DateTime.now(),
    );
    _db.upsertUser(updated);
    return updated;
  }

  Future<void> _tick() =>
      Future<void>.delayed(const Duration(milliseconds: 250));
}
