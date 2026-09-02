import { before, after, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { createTestEnv } from './env.js';
import { seedBaseline, COLLECTIONS } from './seed.js';

let testEnv;

before(async () => {
  testEnv = await createTestEnv();
});
after(async () => {
  await testEnv.cleanup();
});
beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await seedBaseline(ctx.firestore());
  });
});

const db = (uid) => testEnv.authenticatedContext(uid).firestore();
const anon = () => testEnv.unauthenticatedContext().firestore();

describe('isolamento entre empresas', () => {
  for (const col of COLLECTIONS) {
    test(`${col}: lê o próprio tenant, nega o outro`, async () => {
      await assertSucceeds(getDoc(doc(db('sup_a'), `${col}/${col}_a`)));
      await assertFails(getDoc(doc(db('sup_a'), `${col}/${col}_b`)));
    });

    test(`${col}: escreve no próprio tenant, nega no outro`, async () => {
      await assertSucceeds(
        setDoc(doc(db('sup_a'), `${col}/new_a`), { companyId: 'company_a', name: 'n' }),
      );
      await assertFails(
        setDoc(doc(db('sup_a'), `${col}/new_b`), { companyId: 'company_b', name: 'n' }),
      );
      await assertFails(updateDoc(doc(db('sup_a'), `${col}/${col}_b`), { name: 'z' }));
    });
  }

  test('não autenticado é negado', async () => {
    await assertFails(getDoc(doc(anon(), 'clients/clients_a')));
  });
});

describe('/users — criação e papéis', () => {
  test('supervisor cria só funcionário no próprio tenant', async () => {
    await assertSucceeds(
      setDoc(doc(db('sup_a'), 'users/novo_emp'), { role: 'employee', companyId: 'company_a', name: 'x' }),
    );
    await assertFails(
      setDoc(doc(db('sup_a'), 'users/novo_sup'), { role: 'supervisor', companyId: 'company_a', name: 'x' }),
    );
    await assertFails(
      setDoc(doc(db('sup_a'), 'users/emp_outro'), { role: 'employee', companyId: 'company_b', name: 'x' }),
    );
  });

  test('companyAdmin cria supervisor/funcionário no próprio tenant, nega outro', async () => {
    await assertSucceeds(
      setDoc(doc(db('admin_a'), 'users/novo_sup'), { role: 'supervisor', companyId: 'company_a', name: 'x' }),
    );
    await assertSucceeds(
      setDoc(doc(db('admin_a'), 'users/novo_emp'), { role: 'employee', companyId: 'company_a', name: 'x' }),
    );
    await assertFails(
      setDoc(doc(db('admin_a'), 'users/intruso'), { role: 'employee', companyId: 'company_b', name: 'x' }),
    );
  });

  test('anti-escalonamento: self não altera role/companyId', async () => {
    await assertSucceeds(updateDoc(doc(db('emp_a'), 'users/emp_a'), { name: 'Novo Nome' }));
    await assertFails(updateDoc(doc(db('emp_a'), 'users/emp_a'), { role: 'platformAdmin' }));
    await assertFails(updateDoc(doc(db('emp_a'), 'users/emp_a'), { companyId: 'company_b' }));
  });

  test('supervisor edita/exclui funcionário do tenant, sem promover nem cross-tenant', async () => {
    await assertSucceeds(updateDoc(doc(db('sup_a'), 'users/emp_a'), { name: 'Editado' }));
    await assertFails(updateDoc(doc(db('sup_a'), 'users/emp_a'), { role: 'supervisor' }));
    await assertFails(updateDoc(doc(db('sup_a'), 'users/sup_b'), { name: 'x' }));
    await assertSucceeds(deleteDoc(doc(db('sup_a'), 'users/emp_a')));
  });
});

describe('gate de assinatura (bloqueia só escrita)', () => {
  test('empresa suspensa: leitura ok, escrita negada', async () => {
    await assertSucceeds(getDoc(doc(db('sup_susp'), 'clients/clients_susp')));
    await assertFails(
      setDoc(doc(db('sup_susp'), 'tasks/nova_susp'), { companyId: 'company_susp', name: 'n' }),
    );
  });

  test('empresa ativa: escrita ok', async () => {
    await assertSucceeds(
      setDoc(doc(db('sup_a'), 'tasks/nova_a'), { companyId: 'company_a', name: 'n' }),
    );
  });
});

describe('companies (assinatura só a plataforma controla)', () => {
  test('só platformAdmin escreve; leitura só do próprio tenant', async () => {
    await assertFails(updateDoc(doc(db('admin_a'), 'companies/company_a'), { name: 'novo' }));
    await assertSucceeds(updateDoc(doc(db('plat'), 'companies/company_a'), { name: 'novo' }));
    await assertSucceeds(getDoc(doc(db('sup_a'), 'companies/company_a')));
    await assertFails(getDoc(doc(db('sup_b'), 'companies/company_a')));
  });
});
