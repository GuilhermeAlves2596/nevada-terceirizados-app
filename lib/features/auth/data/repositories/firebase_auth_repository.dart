import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_firestore.dart';

/// Implementação real da autenticação (Fase 8).
///
/// Autentica via Firebase Authentication e carrega o perfil do usuário
/// (role/companyId) do Firestore em `/users/{uid}`.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// DEV: empresa padrão usada ao provisionar o primeiro acesso, para o app
  /// continuar demonstrável com os dados mock (mesmo `companyId`).
  static const _devCompanyId = 'company_nevada';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      return _loadOrProvision(user.uid, user.email ?? email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_messageFor(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;
    return appUserFromFirestore(user.uid, doc.data()!);
  }

  /// Carrega o perfil do Firestore; se ainda não existir, cria um perfil de
  /// desenvolvimento (supervisor da empresa mock) para o primeiro acesso.
  Future<AppUser> _loadOrProvision(String uid, String email) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) return appUserFromFirestore(uid, doc.data()!);

    final now = DateTime.now();
    final provisioned = AppUser(
      id: uid,
      name: email.split('@').first,
      email: email,
      role: UserRole.supervisor,
      companyId: _devCompanyId,
      createdAt: now,
      updatedAt: now,
    );
    await _users.doc(uid).set(appUserToFirestore(provisioned));
    return provisioned;
  }

  String _messageFor(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'E-mail inválido.',
        'user-disabled' => 'Este usuário está desativado.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-mail ou senha inválidos.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um momento e tente novamente.',
        'network-request-failed' =>
          'Sem conexão. Verifique sua internet e tente novamente.',
        _ => 'Não foi possível entrar. Tente novamente.',
      };
}
