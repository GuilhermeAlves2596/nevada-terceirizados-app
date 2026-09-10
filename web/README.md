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
cp .env.local.example .env.local   # e preencha os valores do Firebase
npm run dev
```

Abre em `http://localhost:3000`. A config do Firebase é lida de variáveis
`NEXT_PUBLIC_*` (ver `.env.local.example`) — o `.env.local` **não é
versionado**. Pegue os valores no Firebase Console → Configurações do projeto →
Seus apps → app Web. Os valores de config web não são segredo (vão pro bundle do
cliente); ficam fora do repositório só por higiene/secret-scanning. A proteção
real é das **Security Rules** + **restrição da API key** no Google Cloud
(referrer HTTP + APIs permitidas).

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

## Segurança e cache

### App Check (anti-abuso)
O painel inicializa o **App Check** com **reCAPTCHA Enterprise** (o v3 clássico
está sendo descontinuado) quando `NEXT_PUBLIC_APPCHECK_SITE_KEY` está definido —
ele atesta que a requisição vem do app real. Para ativar:

1. **Google Cloud Console** (mesmo projeto) → ativar a **reCAPTCHA Enterprise
   API** → **reCAPTCHA Enterprise → Criar chave**: tipo **Site**, domínios
   `localhost` (+ prod depois), **sem** desafio de caixa de seleção
   (score-based). Copie o **ID da chave**.
2. Firebase Console → **App Check** → registrar o app **Web** com provedor
   **reCAPTCHA Enterprise**, colando o ID da chave. Use o mesmo valor em
   `NEXT_PUBLIC_APPCHECK_SITE_KEY`.
3. **Dev/localhost:** com `NEXT_PUBLIC_APPCHECK_DEBUG=true`, o navegador imprime
   um *debug token* no console — registre-o em App Check → app Web → **Tokens de
   debug** (senão o localhost é bloqueado quando houver enforcement).
4. Quando validar, **force o App Check** por serviço (Firestore, Storage,
   Functions) no console. Antes disso fica em **modo monitor** (não bloqueia
   nada). Sem a site key, o App Check é ignorado.

> Defesa em camadas: App Check + Security Rules + restrição da API key +
> alertas de orçamento (GCP → Billing → Budgets).

### Cache offline (Firestore)
No navegador o Firestore usa **cache persistente** (IndexedDB, multi-aba) —
reduz leituras (custo) e dá resiliência offline. Configurado em
`src/lib/firebase.ts` (`persistentLocalCache`); no SSR usa a instância simples.

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
