import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/mock/mock_database.dart';
import '../core/utils/firestore_converters.dart';
import '../features/auth/data/models/app_user_firestore.dart';
import '../features/checklists/data/repositories/firebase_checklist_repository.dart';
import '../features/clients/data/repositories/firebase_client_repository.dart';
import '../features/contracts/data/repositories/firebase_contract_repository.dart';
import '../features/locations/data/repositories/firebase_location_repository.dart';
import '../features/tasks/data/repositories/firebase_task_repository.dart';

/// Popula o Firestore com os dados de demonstração (empresa Nevada, usuários,
/// clientes, contrato, locais, checklists e tarefas) na primeira execução.
///
/// Idempotente: se o documento da empresa já existe, não faz nada. Assim o
/// dashboard já abre com conteúdo e o que for cadastrado depois persiste.
class FirestoreSeeder {
  FirestoreSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seedIfNeeded() async {
    final companyRef =
        _firestore.collection('companies').doc(MockDatabase.companyNevada);
    if ((await companyRef.get()).exists) return;

    final db = MockDatabase.seeded();
    final batch = _firestore.batch();

    final company = db.companies.first;
    batch.set(companyRef, {
      'name': company.name,
      'document': company.document,
      'logoUrl': company.logoUrl,
      'plan': company.plan,
      'subscriptionStatus': company.subscriptionStatus.name,
      'seats': company.seats,
      'active': company.active,
      'createdAt': fsTs(company.createdAt),
      'updatedAt': fsTs(company.updatedAt),
    });

    for (final u in db.users) {
      batch.set(_firestore.collection('users').doc(u.id), appUserToFirestore(u));
    }
    for (final c in db.clients) {
      batch.set(_firestore.collection('clients').doc(c.id), clientToMap(c));
    }
    for (final c in db.contracts) {
      batch.set(_firestore.collection('contracts').doc(c.id), contractToMap(c));
    }
    for (final l in db.locations) {
      batch.set(_firestore.collection('locations').doc(l.id), locationToMap(l));
    }
    for (final c in db.checklists) {
      batch.set(_firestore.collection('checklists').doc(c.id), checklistToMap(c));
    }
    for (final t in db.tasks) {
      batch.set(_firestore.collection('tasks').doc(t.id), taskToMap(t));
    }

    await batch.commit();
  }
}
