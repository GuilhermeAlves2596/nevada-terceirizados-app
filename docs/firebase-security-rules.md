# Firebase Security Rules (Fase 12)

Isolamento multi-tenant **server-side** para Firestore e Storage. Antes desta
fase o isolamento por `companyId` só existia no cliente (burlável) e as bases
estavam em "modo de teste". Estas regras são a garantia real de que a empresa X
nunca lê/altera dados da empresa Y.

## Arquivos
- `firestore.rules` — regras do Firestore.
- `storage.rules` — regras do Storage.
- `firestore.indexes.json` — índices (vazio; as queries usam filtro único por `companyId`).
- `firebase.json` / `.firebaserc` — apontam os arquivos e fixam o projeto `nevada-dev`.

## Modelo
- Papel e `companyId` do solicitante vêm SEMPRE de `/users/{uid}` lido no servidor.
- Fronteira dura: **companyId + papel**. Escopo por contrato (supervisor só vê
  seus contratos) fica no app por ora — endurecimento futuro.
- **Gate de assinatura**: bloqueia *escritas* quando `companies/{id}.subscriptionStatus`
  não é `active`/`trial`. Leitura segue liberada (o app mostra o aviso de suspensão).
- Anti-escalonamento: `self` não pode alterar `role`/`companyId` no próprio doc.
- Quem cria quem em `/users`: plataforma → qualquer; companyAdmin → companyAdmin/
  supervisor/funcionário do seu tenant; supervisor → só funcionário do seu tenant.

## Deploy
Requer o Firebase CLI (uma vez): `npm i -g firebase-tools` e `firebase login`.

```bash
firebase deploy --only firestore:rules,storage
```

Alternativa sem CLI: colar o conteúdo de `firestore.rules` e `storage.rules`
direto no Console (Firestore → Regras / Storage → Regras) e publicar.

## Bootstrap (ovo-e-galinha)
Com as regras publicadas **não há mais auto-provisionamento** no 1º login. Para
criar o primeiro acesso, escreva o doc manualmente no **Console** (escrita no
Console ignora as regras):

1. Authentication → criar o usuário (e-mail/senha).
2. Firestore → coleção `users` → doc com ID = **uid** desse usuário:
   `{ name, role: "platformAdmin" | "companyAdmin", companyId: "company_nevada", active: true, createdAt, updatedAt }`.
3. A partir daí, esse usuário cria os demais pelo app (ou pelo painel web, quando existir).

> **Seeder:** o `FirestoreSeeder` grava pré-login (sem auth) e, com as regras
> travadas, essas escritas passam a ser negadas. Como os dados de demonstração
> já existem no `nevada-dev`, o seeder é idempotente e não tenta reescrever. Em
> base nova, semear em modo de teste **antes** de publicar as regras, ou mover a
> semeadura para um caminho autenticado/admin.

## Testes automatizados (emulador)
Os casos de **negação** (cross-tenant, escalonamento, gate de assinatura) têm
testes automatizados em `firebase-tests/` (Firebase Emulator +
`@firebase/rules-unit-testing`). Rodar: `cd firebase-tests && npm install &&
npm run emulate`. Ver `firebase-tests/README.md`.

## Checklist de teste manual (emulador ou projeto de teste)
Rodar com dois usuários de empresas diferentes (A e B).

Isolamento entre tenants:
- [ ] Usuário de A **lê** clients/contracts/tasks/... de A. ✅ permitido
- [ ] Usuário de A **lê** dados de B (get por id conhecido). ❌ negado
- [ ] Usuário de A **escreve** em doc de B. ❌ negado
- [ ] Query de A sem filtro `companyId` (tentando varrer tudo). ❌ negado

Papéis / `/users`:
- [ ] `self` edita nome/telefone. ✅ | `self` tenta mudar `role` p/ companyAdmin. ❌
- [ ] supervisor cria funcionário no seu tenant. ✅ | supervisor cria supervisor. ❌
- [ ] companyAdmin cria supervisor no seu tenant. ✅ | em outro tenant. ❌
- [ ] usuário comum edita `companies/{id}` (assinatura). ❌ (só platformAdmin)

Gate de assinatura (setar `subscriptionStatus: "suspended"` na empresa):
- [ ] usuário do tenant suspenso **lê** dados. ✅ (leitura liberada)
- [ ] usuário do tenant suspenso **escreve** (criar tarefa, etc.). ❌ negado

Storage:
- [ ] upload de foto em `companies/{meuCompanyId}/...`. ✅
- [ ] upload em `companies/{outroCompanyId}/...`. ❌
- [ ] upload de arquivo não-imagem ou > 10MB. ❌
- [ ] leitura de foto de outro tenant. ❌

Login/bootstrap:
- [ ] login de Auth sem doc em `/users`. → deslogado + "acesso não liberado".
