import 'package:uuid/uuid.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../auth/domain/entities/app_user.dart';
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
  Future<AppUser> createEmployee({
    required String companyId,
    required String name,
    required String email,
    String? phone,
    String? jobTitle,
  }) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    final exists = _db.users.any((u) => u.email.toLowerCase() == normalized);
    if (exists) {
      throw const ValidationException('Já existe um usuário com este e-mail.');
    }
    final now = DateTime.now();
    final user = AppUser(
      id: _uuid.v4(),
      companyId: companyId,
      name: name.trim(),
      email: normalized,
      role: UserRole.employee,
      phone: phone?.trim(),
      jobTitle: jobTitle?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _db.upsertUser(user);
    return user;
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

  Future<void> _tick() =>
      Future<void>.delayed(const Duration(milliseconds: 250));
}
