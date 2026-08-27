# 0003 — Backend compartilhado e frontends (mobile + painel web)

- **Status:** Aceito
- **Data:** 2026-08-27

## Contexto

Havia dúvida sobre o que é a "versão web". Esclarecendo: a execução via
`flutter run -d web-server` é apenas uma **pré-visualização do app mobile no
navegador** — não é o painel administrativo. O produto precisa, no futuro, de um
**painel web separado** para o supervisor (no computador) e para o **admin
master** da plataforma, além do app mobile para o funcionário/supervisor em
campo.

Decisão-chave: *quem é o backend* que ambos os frontends acessam?

## Decisão

**Firebase como backend compartilhado (BaaS).** Sem servidor próprio no MVP.

- **App mobile:** Flutter (funcionário + supervisor em campo).
- **Painel web (projeto separado):** **React / Next.js (TypeScript)** —
  supervisor no desktop + admin master (`platformAdmin`).
- **Backend/dados:** Firebase (Cloud Firestore, Authentication, Storage, FCM).
  Mobile **e** web acessam o Firebase **diretamente** pela rede.

```
   App Mobile (Flutter)          Painel Web (React/Next, TS)
            \                          /
             \                        /
              ▼                      ▼
                   Firebase (BaaS)
        Firestore · Auth · Storage · FCM
```

## Alternativas consideradas

- **Backend próprio em Java (Spring Boot) + Postgres:** mais controle e
  independência do Firebase, porém muito mais trabalho e infraestrutura
  (deploy, servidor, segurança) — atrasaria o MVP. Descartado por ora.
- **Híbrido (Firebase agora, backend Java depois):** possível evolução futura se
  surgir lógica de servidor pesada; não é necessário agora.
- **Flutter Web para o painel:** reaproveitaria o código Dart, mas é menos
  adequado para painéis administrativos densos. Preferido React/Next.

## Consequências

- **Segurança é crítica:** como os clientes acessam o banco diretamente, o
  isolamento multi-tenant (`companyId`) e as permissões por `role` **têm** de
  ser garantidos nas **Firebase Security Rules** (Fase 12), nunca só no
  frontend. Ver [[0001-arquitetura-e-stack]].
- O **painel web é um projeto/repositório à parte** (fora deste app Flutter) e
  entra depois; não faz parte das fases atuais do mobile.
- As Fases 8–12 conectam o app mobile ao Firebase. O painel web pode ser
  iniciado em paralelo assim que o modelo do Firestore estiver definido.
- A troca "mock → Firebase" no mobile continua localizada em
  `lib/app/di/repository_providers.dart`.
- **Reversibilidade:** se um dia quisermos um backend próprio, o painel React e
  o mobile passam a chamar uma API nossa; o impacto no mobile fica contido na
  camada de dados.

## Escopo imediato

Esta decisão **não bloqueia** a Fase 4 (fluxo do supervisor no mobile), que
segue valendo em qualquer cenário.
