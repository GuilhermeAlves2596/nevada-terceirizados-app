import '../../../../core/enums/user_role.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  MockUserRepository(this._db);

  final MockDatabase _db;

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

  Future<void> _tick() =>
      Future<void>.delayed(const Duration(milliseconds: 250));
}
