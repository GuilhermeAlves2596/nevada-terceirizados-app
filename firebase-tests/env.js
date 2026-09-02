import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

// Lê as rules REAIS do repositório (garante que o teste valida o que é
// deployado, não uma cópia).
const firestoreRules = readFileSync(
  fileURLToPath(new URL('../firestore.rules', import.meta.url)),
  'utf8',
);
const storageRules = readFileSync(
  fileURLToPath(new URL('../storage.rules', import.meta.url)),
  'utf8',
);

/// Cria o ambiente de teste conectado aos emuladores (Firestore 8080,
/// Storage 9199). Usa um projectId `demo-*` para nunca tocar em dados reais.
export function createTestEnv() {
  return initializeTestEnvironment({
    projectId: 'demo-nevada',
    firestore: { host: '127.0.0.1', port: 8080, rules: firestoreRules },
    storage: { host: '127.0.0.1', port: 9199, rules: storageRules },
  });
}
