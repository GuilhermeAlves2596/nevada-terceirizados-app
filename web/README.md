# Painel Web do Gestor (Nevada)

Painel administrativo do **gestor da empresa** (`companyAdmin`) e, futuramente,
do **admin da plataforma** (`platformAdmin`). Projeto separado do app Flutter
(que fica só com supervisor + funcionário em campo) — ver
[ADR 0003](../docs/adr/0003-backend-e-frontends.md).

**Stack:** Next.js 14 (App Router) + TypeScript + Tailwind. Acessa o Firebase
(Auth, Firestore, Cloud Functions) diretamente pela rede, igual ao mobile. O
isolamento multi-tenant é garantido pelas Security Rules, não pelo frontend.

## Rodar em dev

```bash
cd web
npm install
npm run dev
```

Abre em `http://localhost:3000`. A config **pública** do Firebase (`nevada-dev`)
já vem embutida em `src/lib/firebase.ts`; para apontar a outro projeto, use um
`.env.local` (ver `.env.local.example`).

## O que já tem (fatia inicial)

- **Login** do gestor por e-mail/senha (`/login`).
- **Guarda de papel:** só `companyAdmin`/`platformAdmin` entram no painel; outros
  papéis são barrados.
- **Supervisores** (`/supervisors`): lista os supervisores da empresa e cadastra
  um novo, chamando a Cloud Function **`createSupervisor`** (Admin SDK) — que
  cria a conta no Auth + o perfil `/users` e devolve a senha temporária.

## Pré-requisitos no Firebase

1. **Deployar a function** `createSupervisor` (senão o cadastro falha):
   ```bash
   firebase deploy --only functions:createSupervisor
   ```
2. **Ter uma conta de gestor** para logar. Como as Security Rules não permitem
   auto-provisionamento, crie no **Console** (uma vez):
   - Authentication → adicionar usuário (e-mail/senha).
   - Firestore → coleção `users` → doc com ID = **uid** desse usuário:
     `{ name, role: "companyAdmin", companyId: "<id da empresa>", active: true }`.
3. O supervisor criado loga por **e-mail** e cai na troca de senha obrigatória no
   1º acesso (fluxo `mustChangePassword`, já existente no app mobile).

## Troubleshooting

- **`EXDEV: cross-device link not permitted` no build** (telemetria do Next
  gravando em `AppData`): rode com a telemetria desligada —
  `set NEXT_TELEMETRY_DISABLED=1` (PowerShell: `$env:NEXT_TELEMETRY_DISABLED=1`)
  antes do `npm run build`, ou `npx next telemetry disable` uma vez.

## Próximos passos (migração incremental do Flutter → web)

- Vínculo de contratos ao supervisor (hoje na `SupervisorsPage` do Flutter).
- CRUD de Clientes e Contratos (hoje stopgap no Flutter).
- Relatórios.

Conforme cada tela migra para cá, ela é **removida** do app Flutter.
