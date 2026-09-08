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
///
/// **Isolamento assimétrico por `projectId`.** O `node --test` roda os arquivos
/// em paralelo contra o MESMO emulador, e ambos dão `clearFirestore()` no
/// `beforeEach` (o Storage também lê os `/users`); com projectId compartilhado o
/// clear de um apagava o seed do outro no meio de um teste → falha intermitente.
/// Por isso o `firestore.rules.test.js` usa um projectId próprio
/// (`demo-nevada-fs`). Já o `storage.rules.test.js` DEVE ficar no `--project`
/// (`demo-nevada`): o `firestore.get(/users)` das storage.rules lê, no emulador,
/// o Firestore fixado no `--project`, não o do testEnv — num projectId diferente
/// a regra não acharia os `/users` e negaria tudo.
export function createTestEnv(projectId = 'demo-nevada') {
  return initializeTestEnvironment({
    projectId,
    firestore: { host: '127.0.0.1', port: 8080, rules: firestoreRules },
    storage: { host: '127.0.0.1', port: 9199, rules: storageRules },
  });
}
