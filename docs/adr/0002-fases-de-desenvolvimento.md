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

### 🔄 Fase 3 — Fluxo do funcionário
- [x] Detalhe da tarefa
- [x] Iniciar tarefa (startedAt, status IN_PROGRESS)
- [x] Checklist interativo + cálculo de progresso
- [x] Foto obrigatória (simulada; câmera real na Fase 6)
- [x] Observação opcional
- [x] Finalizar com validações (itens obrigatórios + foto)
- [ ] Histórico próprio

### ⏳ Fase 4 — Fluxo do supervisor
- [ ] Cadastros: funcionários, clientes, contratos, locais
- [ ] Criação de checklists (com itens ordenáveis)
- [ ] Atribuição de tarefas
- [ ] Acompanhamento

### ⏳ Fase 5 — QR Code
- [ ] Geração de QR por ambiente
- [ ] Leitura (mobile_scanner) + validação de permissão/empresa

### ⏳ Fase 6 — Câmera / fotos
- [ ] Captura, revisão, compressão
- [ ] Substituir foto / múltiplas fotos (estrutura)

### ⏳ Fase 7 — Persistência local / offline
- [ ] Não perder checklist/foto sem conexão
- [ ] Sincronização quando a internet voltar

### ⏳ Fase 8 — Firebase Authentication
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
