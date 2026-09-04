import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/credentials.dart';
import '../../../../firebase_options.dart';
import '../../../auth/data/models/app_user_firestore.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/new_employee_result.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  @override
  Future<AppUser?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? appUserFromFirestore(doc.id, doc.data()!) : null;
  }

  @override
  Future<List<AppUser>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    return snap.docs.map((d) => appUserFromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<List<AppUser>> getEmployees({required String companyId}) async {
    final all = await getAll(companyId: companyId);
    return all.where((u) => u.role == UserRole.employee).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
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
    final digits = Credentials.cpfDigits(cpf);
    if (digits.length != 11) {
      throw const ValidationException('CPF inválido (11 dígitos).');
    }

    final syntheticEmail = Credentials.syntheticEmailForCpf(digits);
    final tempPassword = Credentials.generateTempPassword();

    // Cria a conta de acesso sem deslogar o supervisor (app secundário).
    final String uid;
    try {
      uid = await _createAuthAccount(
        email: syntheticEmail,
        password: tempPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const ValidationException('Já existe um funcionário com este CPF.');
      }
      throw ValidationException('Não foi possível criar o acesso (${e.code}).');
    }

    final trimmedEmail = email?.trim();
    final now = DateTime.now();
    final user = AppUser(
      id: uid,
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
    await _col.doc(uid).set(appUserToFirestore(user));
    return NewEmployeeResult(user: user, temporaryPassword: tempPassword);
  }

  /// Cria o usuário no Firebase Auth usando uma instância **secundária**, para
  /// que a sessão do supervisor (instância padrão) não seja afetada.
  Future<String> _createAuthAccount({
    required String email,
    required String password,
  }) async {
    FirebaseApp secondary;
    try {
      secondary = Firebase.app('employeeCreator');
    } catch (_) {
      secondary = await Firebase.initializeApp(
        name: 'employeeCreator',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
    try {
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user!.uid;
    } finally {
      await secondaryAuth.signOut();
    }
  }

  @override
  Future<AppUser> update({
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? jobTitle,
  }) async {
    final ref = _col.doc(userId);
    final doc = await ref.get();
    if (!doc.exists) throw const NotFoundException('Usuário não encontrado.');
    final trimmedEmail = email?.trim();
    final updated = appUserFromFirestore(doc.id, doc.data()!).copyWith(
      name: name.trim(),
      email: (trimmedEmail == null || trimmedEmail.isEmpty) ? null : trimmedEmail,
      phone: phone?.trim(),
      jobTitle: jobTitle?.trim(),
      updatedAt: DateTime.now(),
    );
    await ref.set(appUserToFirestore(updated));
    return updated;
  }

  @override
  Future<void> delete(String userId) async {
    await _col.doc(userId).delete();
  }

  @override
  Future<AppUser> setActive({
    required String userId,
    required bool active,
  }) async {
    final ref = _col.doc(userId);
    await ref.update({'active': active, 'updatedAt': Timestamp.now()});
    final doc = await ref.get();
    return appUserFromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<String> resetEmployeePassword(String employeeId) async {
    try {
      final result = await _functions
          .httpsCallable('resetEmployeePassword')
          .call({'employeeId': employeeId});
      final data = (result.data as Map).cast<String, dynamic>();
      final pwd = data['temporaryPassword'] as String?;
      if (pwd == null || pwd.isEmpty) {
        throw const ValidationException('Resposta inválida do servidor.');
      }
      return pwd;
    } on FirebaseFunctionsException catch (e) {
      throw ValidationException(
          e.message ?? 'Não foi possível redefinir a senha.');
    }
  }

  @override
  Future<AppUser> setContracts({
    required String userId,
    required List<String> contractIds,
    required List<String> clientIds,
  }) async {
    final ref = _col.doc(userId);
    await ref.update({
      'contractIds': contractIds,
      'clientIds': clientIds,
      'updatedAt': Timestamp.now(),
    });
    final doc = await ref.get();
    return appUserFromFirestore(doc.id, doc.data()!);
  }
}
