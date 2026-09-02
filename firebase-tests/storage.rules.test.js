import { before, after, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes } from 'firebase/storage';
import { createTestEnv } from './env.js';
import { seedBaseline } from './seed.js';

let testEnv;

before(async () => {
  testEnv = await createTestEnv();
});
after(async () => {
  await testEnv.cleanup();
});
beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    // Storage lê o Firestore (papel/companyId) — precisa dos /users e /companies.
    await seedBaseline(ctx.firestore());
    // Arquivo semente no tenant A, para os testes de leitura.
    await uploadBytes(
      ref(ctx.storage(), 'companies/company_a/executions/e1/seed.jpg'),
      new Uint8Array([1, 2, 3]),
      { contentType: 'image/jpeg' },
    );
  });
});

const st = (uid) => testEnv.authenticatedContext(uid).storage();
const img = { contentType: 'image/jpeg' };
const small = () => new Uint8Array([1, 2, 3, 4]);

describe('storage — isolamento e validação', () => {
  test('upload no próprio tenant (imagem pequena) ok', async () => {
    await assertSucceeds(
      uploadBytes(ref(st('sup_a'), 'companies/company_a/executions/e2/p.jpg'), small(), img),
    );
  });

  test('upload em outro tenant negado', async () => {
    await assertFails(
      uploadBytes(ref(st('sup_a'), 'companies/company_b/executions/e2/p.jpg'), small(), img),
    );
  });

  test('upload de não-imagem negado', async () => {
    await assertFails(
      uploadBytes(ref(st('sup_a'), 'companies/company_a/executions/e2/p.txt'), small(), {
        contentType: 'text/plain',
      }),
    );
  });

  test('upload acima de 10MB negado', async () => {
    const big = new Uint8Array(10 * 1024 * 1024 + 1024);
    await assertFails(
      uploadBytes(ref(st('sup_a'), 'companies/company_a/executions/e2/big.jpg'), big, img),
    );
  });

  test('leitura: próprio tenant ok, outro tenant negado', async () => {
    await assertSucceeds(getBytes(ref(st('sup_a'), 'companies/company_a/executions/e1/seed.jpg')));
    await assertFails(getBytes(ref(st('sup_b'), 'companies/company_a/executions/e1/seed.jpg')));
  });

  test('empresa suspensa: escrita negada', async () => {
    await assertFails(
      uploadBytes(ref(st('sup_susp'), 'companies/company_susp/executions/e1/p.jpg'), small(), img),
    );
  });
});
