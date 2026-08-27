# Nevada — Gestão de Serviços Terceirizados

Aplicativo mobile (Flutter) para **gerenciamento, execução e fiscalização de
serviços terceirizados** (limpeza, jardinagem, portaria, etc.).

O supervisor cadastra clientes, contratos, locais e checklists, gera QR Codes e
atribui tarefas. O funcionário escaneia o QR Code do ambiente, executa o
checklist, registra foto e observação e finaliza — enquanto o supervisor
acompanha o progresso em tempo real.

Construído como **MVP para a Nevada Serviços Terceirizados**, mas com
arquitetura preparada para virar uma **plataforma SaaS multi-tenant**.

> **Status atual: Fase 1 concluída** — fundação, design system, dados mockados,
> autenticação mockada e dashboards dos dois perfis. Firebase ainda **não** está
> conectado (entra a partir da Fase 8).

---

## 🧱 Arquitetura

**Clean Architecture + Feature First + Repository Pattern.**

Cada feature é isolada em três camadas:

```
UI (presentation)  →  Domain (entities / repositories / use cases)  →  Data (repositories impl / data sources)
```

- A **UI nunca acessa dados diretamente** — sempre via repositório (hoje mock,
  amanhã Firebase).
- O **domínio é puro** (sem Flutter/Firebase), facilitando testes e troca de
  backend.
- A troca de mock → Firebase acontece em **um único lugar**:
  [`lib/app/di/repository_providers.dart`](lib/app/di/repository_providers.dart).

### Fluxo de dados (exemplo)

```
Widget → Controller (Riverpod) → UseCase → Repository → DataSource → (Firestore/Storage)
```

### Decisões de modelagem

- **Funcionário e supervisor** são o mesmo tipo (`AppUser`) diferenciados por
  `role` — reflete a coleção única `/users` e simplifica as regras de segurança.
- **Checklist ≠ Task ≠ TaskExecution**: o checklist é o *modelo*; a task é o
  *trabalho agendado*; a execution é o *trabalho real*. Essencial para tarefas
  recorrentes no futuro.
- Toda entidade de negócio carrega `companyId` (isolamento multi-tenant).

---

## 🛠️ Tecnologias

| Área | Escolha |
|------|---------|
| Framework | Flutter / Dart |
| Estado | Riverpod |
| Navegação | go_router (com route guards por perfil) |
| Modelos | freezed + json_serializable |
| Fontes | google_fonts (League Spartan + Roboto) |
| Datas | intl |
| IDs | uuid |
| Backend (futuro) | Firebase Auth, Firestore, Storage, FCM, Crashlytics |

---

## 📁 Estrutura de pastas

```
lib/
├── app/
│   ├── app.dart              # Widget raiz (MaterialApp.router)
│   ├── di/                   # Injeção de dependência (providers de repositório)
│   ├── providers/            # Providers transversais (ex.: catálogo da empresa)
│   ├── router/               # go_router + rotas + guards
│   └── theme/                # AppColors, AppTypography, AppTheme, AppSpacing...
├── core/
│   ├── enums/                # UserRole, TaskStatus, ServiceType, ...
│   ├── errors/               # Exceções de domínio
│   ├── extensions/           # Ex.: formatação de datas
│   ├── mock/                 # Banco em memória + seed de demonstração
│   └── widgets/              # Componentes reutilizáveis (AppButton, AppCard...)
├── features/
│   ├── auth/                 # login, sessão, entidade AppUser
│   ├── dashboard/            # dashboards do funcionário e do supervisor
│   ├── employees/            # usuários/funcionários
│   ├── clients/ contracts/ locations/ checklists/
│   ├── tasks/                # tarefas + view models
│   ├── executions/           # execução, itens, fotos
│   └── profile/
└── main.dart
```

Cada feature segue `data/ · domain/ · presentation/`.

---

## ▶️ Como executar

Pré-requisitos: Flutter 3.41+ (Dart 3.11+).

```bash
flutter pub get
dart run build_runner build   # gera os arquivos freezed (*.freezed.dart)
flutter run                   # escolha um device (Android/iOS/Chrome)
```

### Credenciais de demonstração (Fase mockada)

| Perfil | E-mail | Senha |
|--------|--------|-------|
| Supervisor | `supervisor@teste.com` | qualquer (ex.: `123456`) |
| Funcionário | `funcionario@teste.com` | qualquer |

> A tela de login tem botões que preenchem essas credenciais automaticamente.

### Geração de código

Sempre que alterar uma entidade `@freezed`, rode:

```bash
dart run build_runner build
# ou, durante o desenvolvimento:
dart run build_runner watch
```

---

## ✅ Testes

```bash
flutter analyze   # análise estática — deve ficar sem issues
flutter test      # testes unitários e de widget
```

Cobertos nesta fase: cálculo de progresso, agregação de estatísticas, regra de
tarefa atrasada e smoke test da inicialização.

---

## 🔥 Configuração Firebase (a partir da Fase 8)

Ainda **não** integrado. Quando entrar:

1. Criar o projeto no Firebase Console.
2. `flutterfire configure` (gera `lib/firebase_options.dart` — **não versionado**).
3. Adicionar `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
   — **ambos fora do Git** (ver `.gitignore`).
4. Publicar as **Security Rules** garantindo isolamento por `companyId`.

Nenhum segredo/chave deve ir para o repositório.

---

## 🌿 Estratégia de branches

- `main` — estável, sempre executável.
- `develop` — integração.
- `feature/<nome>` — cada funcionalidade/fase.

Regra: ao final de cada fase, `flutter analyze` e `flutter test` devem passar e o
app deve continuar executável.

---

## 🔒 Segurança (planejado)

- Regras do Firestore/Storage impedindo acesso entre empresas (`companyId`).
- Funcionário não altera `role`, `companyId` nem execuções de terceiros.
- Timestamps de início/fim usam o horário do **servidor**.
- Segredos fora do código e do Git; tokens em armazenamento seguro.
- LGPD: coletar o mínimo necessário e explicar o motivo das permissões.

---

## 🗺️ Roadmap (fases)

| Fase | Entrega | Status |
|------|---------|--------|
| 1 | Fundação, tema, mocks, auth mockada, dashboards | ✅ |
| 2 | Autenticação mockada refinada | ✅ (base) |
| 3 | Fluxo do funcionário (execução, checklist, progresso) | ⏳ |
| 4 | Fluxo do supervisor (cadastros, atribuição) | ⏳ |
| 5 | QR Code | ⏳ |
| 6 | Câmera / fotos | ⏳ |
| 7 | Persistência local / offline | ⏳ |
| 8–12 | Firebase (Auth, Firestore, Storage, FCM, Security Rules) | ⏳ |
| 13 | Tempo real | ⏳ |
| 14–15 | Relatórios + exportação PDF/Excel | ⏳ |
```
