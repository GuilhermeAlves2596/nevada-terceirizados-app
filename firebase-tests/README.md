# Testes das Security Rules (emulador)

Testes automatizados das regras de `firestore.rules` e `storage.rules` (Fase 12)
usando o **Firebase Emulator Suite** + `@firebase/rules-unit-testing`. Cobrem os
casos de **negação** que o Rules Playground do Console não consegue simular
(escritas com `get()`/`exists()`).

## Pré-requisitos
- Node 18+ e npm
- Java 11+ (o emulador do Firestore/Storage roda em JVM)
- Firebase CLI (`npm i -g firebase-tools`)

## Rodar

```bash
cd firebase-tests
npm install
npm run emulate
```

`npm run emulate` sobe os emuladores (Firestore 8080, Storage 9199) com um
projeto `demo-nevada` (nunca toca dados reais), roda `node --test` e derruba os
emuladores no fim. As regras testadas são lidas **direto** de `../firestore.rules`
e `../storage.rules` — ou seja, o teste valida exatamente o que é deployado.

Alternativa (a partir da raiz do repo):

```bash
firebase emulators:exec --project demo-nevada --only firestore,storage \
  "npm --prefix firebase-tests test"
```

## O que é coberto
- **Isolamento entre empresas** (clients, contracts, locations, checklists,
  tasks, taskExecutions): lê/escreve só o próprio `companyId`; nega o outro;
  nega não autenticado.
- **/users**: supervisor cria/edita/exclui **só** funcionário do próprio tenant
  (sem promover); companyAdmin cria supervisor/funcionário do tenant; self não
  altera `role`/`companyId` (anti-escalonamento).
- **Gate de assinatura**: empresa `suspended` tem escrita negada e leitura
  liberada.
- **companies**: só `platformAdmin` escreve; leitura só do próprio tenant.
- **storage**: upload só em `companies/{meuCompanyId}/...`, exige imagem e
  < 10 MB; nega cross-tenant; leitura isolada; empresa suspensa não escreve.

## Notas
- `node_modules/` é ignorado no git.
- Se o emulador não subir com erro de *loopback*/selector (comum em sandboxes
  ou ambientes com rede restrita), rode em uma máquina/shell normal.
