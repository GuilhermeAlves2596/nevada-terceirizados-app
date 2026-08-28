# 0002 — Fases de desenvolvimento (roadmap)

- **Status:** Em andamento
- **Data:** 2026-08-27

## Contexto

O desenvolvimento é **incremental**: primeiro o funcionário executa uma tarefa,
depois o supervisor acompanha, depois a empresa administra, depois a plataforma
administra várias empresas. Nada de Firebase antes de validar o fluxo principal
com dados mockados.

## Definição de "pronto" (por fase)

- [ ] `flutter analyze` sem issues
- [ ] `flutter test` verde
- [ ] App executável ao final da fase
- [ ] ADR/README atualizados

## Fases

> Marque as caixas conforme concluímos cada item.

### ✅ Fase 1 — Fundação
- [x] Projeto Flutter (Android/iOS/Web)
- [x] Clean Architecture + Feature First
- [x] Design System (tema, cores, tipografia)
- [x] Entidades de domínio + enums
- [x] Interfaces de repositório + mocks + seed
- [x] Navegação (go_router) + guards por perfil
- [x] Componentes reutilizáveis

### ✅ Fase 2 — Autenticação mockada
- [x] Login por e-mail (mock) e logout
- [x] Diferenciação de perfil (employee/supervisor) e redirecionamento
- [ ] Recuperação de senha (tela) — pendente

### ✅ Fase 3 — Fluxo do funcionário
- [x] Detalhe da tarefa
- [x] Iniciar tarefa (startedAt, status IN_PROGRESS)
- [x] Checklist interativo + cálculo de progresso
- [x] Foto obrigatória (simulada; câmera real na Fase 6)
- [x] Observação opcional
- [x] Finalizar com validações (itens obrigatórios + foto)
- [x] Histórico próprio (tela /employee/history com filtro)

### ✅ Fase 4 — Fluxo do supervisor
- [x] Hub de Gestão no dashboard do supervisor
- [x] Cadastro de funcionários (listar + criar + ativar/desativar via repo)
- [x] Cadastro de clientes (listar + criar)
- [x] Atribuição de tarefas (Nova Tarefa, com seleções em cascata)
- [x] Cadastro de contratos (listar + criar)
- [x] Cadastro de locais/ambientes (listar + criar, gera qrCodeId)
- [x] Construtor de checklists (adicionar/remover/reordenar itens + obrigatório)
- [x] Acompanhamento (dashboard já reflete tarefas atribuídas)

### ✅ Fase 5 — QR Code
- [x] Geração/visualização de QR por ambiente (qr_flutter) para o supervisor
- [x] Leitura com a câmera (mobile_scanner) no fluxo do funcionário
- [x] Resolver com validação de empresa/permissão (QrResolver + testes)
- [x] Fallback de digitação do código (demo sem câmera) + permissões Android/iOS

### ✅ Fase 6 — Câmera / fotos
- [x] Captura via câmera ou galeria (image_picker)
- [x] Revisão antes de usar + "Refazer"
- [x] Compressão na captura (maxWidth/imageQuality)
- [x] Exibição da foto real (import condicional io/web) + visualização em tela cheia
- [x] Múltiplas fotos (a estrutura já suporta lista de fotos)
- [ ] Upload real para Storage — vem na Fase 10 (hoje guarda o caminho local)

### ⏳ Fase 7 — Persistência local / offline
- [ ] Não perder checklist/foto sem conexão
- [ ] Sincronização quando a internet voltar

### 🔄 Fase 8 — Firebase Authentication
- [x] `flutterfire configure` (projeto `nevada-dev`) + init do Firebase no main
- [x] `FirebaseAuthRepository` (login/logout reais) + perfil no Firestore `/users/{uid}`
- [x] Troca mock→Firebase no ponto único de DI (auth)
- [x] Restauração de sessão no início (splash) — mantém logado
- [x] minSdk Android elevado para 23 (exigência do firebase_auth)
- [ ] Criar usuário de teste no console e validar no emulador

> **Nota (ambiente):** o preview Flutter Web deixou de compilar após o Firebase
> (incompatibilidade `firebase_core_web` × Dart SDK — método `isA`). Não afeta
> Android/iOS. Como o painel web do produto é separado (React, ADR 0003), a
> validação passa a ser no **emulador Android**.

### ⏳ Fase 9 — Cloud Firestore
### ⏳ Fase 10 — Firebase Storage
### ⏳ Fase 11 — Firebase Cloud Messaging (notificações)
### ⏳ Fase 12 — Security Rules (isolamento por companyId)
### ⏳ Fase 13 — Tempo real (listeners/streams)
### ⏳ Fase 14 — Relatórios
### ⏳ Fase 15 — Exportação PDF / Excel

## Consequências

O app permanece demonstrável em qualquer ponto. Cada fase entrega valor
observável, priorizando o fluxo "funcionário executa uma tarefa" — o pedaço mais
importante para apresentar ao cliente.
