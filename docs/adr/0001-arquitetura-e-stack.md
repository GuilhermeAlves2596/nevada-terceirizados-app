# 0001 — Arquitetura e stack tecnológica

- **Status:** Aceito
- **Data:** 2026-08-27

## Contexto

O produto começa como um MVP para a Nevada Serviços Terceirizados, mas precisa
evoluir para uma plataforma SaaS multi-tenant sem reescrita. Precisamos de uma
base testável, que permita trocar o backend (mock → Firebase → talvez outro) e
crescer feature a feature.

## Decisão

**Clean Architecture + Feature First + Repository Pattern.**

- Camadas por feature: `data/` · `domain/` · `presentation/`.
- A UI nunca acessa dados diretamente — sempre via repositório.
- O domínio é puro (sem Flutter/Firebase).
- A composição de dependências fica num único ponto
  (`lib/app/di/repository_providers.dart`): hoje aponta para `Mock*Repository`;
  nas fases de Firebase, troca-se ali por `Firebase*Repository`.

**Stack:**

| Área | Escolha |
|------|---------|
| Estado | Riverpod (sem codegen) |
| Navegação | go_router + route guards por perfil |
| Modelos | freezed (data classes; JSON entra nos models de dados) |
| Fontes | google_fonts (League Spartan / Roboto) |
| Datas/i18n | intl (pt_BR) |
| Backend (futuro) | Firebase Auth, Firestore, Storage, FCM, Crashlytics |

**Modelagem de domínio:**

- Funcionário e supervisor são o mesmo tipo `AppUser`, diferenciados por `role`
  (reflete a coleção única `/users` e simplifica as regras de segurança).
- Separação **Checklist (modelo) ≠ Task (agendada) ≠ TaskExecution (real)** —
  essencial para tarefas recorrentes.
- Toda entidade carrega `companyId` (isolamento multi-tenant).

## Consequências

- **Positivas:** testável, baixo acoplamento, troca de backend localizada,
  evolução incremental.
- **Custos:** mais camadas/arquivos por feature; freezed exige rodar
  `build_runner` ao alterar entidades.
- Regra de qualidade: ao fim de cada fase, `flutter analyze` e `flutter test`
  limpos e app executável.
