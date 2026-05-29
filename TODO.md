# Listaí — Progresso do Projeto

## OBRIGATORIO

- É OBRIGATORIO QUE antes de começar a codar cada fase aqui do TODO.md, leia os arquivos 02-arquitetura.md e 03-prompts-spec-driven.md,
  para voce ver o que tem que ser feito.
- Se for dito para voce fazer um "Passo", leia o que tem que ser feito em 03-prompts-spec-driven.md no passo correspondente.
- Leia TODO.md inteiro antes de começar.
- Ao terminar um passo, coloque um "x" no quadrado correspondente.
- Ao termina uma fase coloque a palavra CONCLUIDO antes da descrição da fase.
- Nunca comece um passo sem ter lido primeiro os arquivos 02-arquitetura.md e 03-prompts-spec-driven.md
- Se não tiver certeza de alguma coisa, pergunte para mim. (não invente)
- Se um passo estiver com x no quadrado, não faça ele, vá para o próximo passo que não estiver com x.
- Para o Frontend (Flutter), siga as diretrizes de design em DESIGN.md e não invente cores, fontes ou formatos.
- Se ver qualquer coisa que seja de "design" ou cores, fonte, etc, que esteja diferente em TODO.md ou no arquivo de DESIGN.md ou em qualquer outro arquivo, mude para seguir o arquivo de DESIGN.md
- Se ver qualquer coisa que seja de "arquitetura" ou organização de pastas, etc, que esteja diferente em TODO.md ou no arquivo de 02-arquitetura.md ou em qualquer outro arquivo, mude para seguir o arquivo de 02-arquitetura.md
- Se foi dado apenas o comando para revisar para voce, voce deve ler o arquivo 02-arquitetura.md e 03-prompts-spec-driven.md e ver o que tem que ser feito e fazer, e não faça os proximos passos, apenas revise e corrija o que for preciso.

## CONCLUIDO Fase 0 — Setup do Projeto

- [x] **Passo 0.1** — Inicializar projeto Flutter
- [x] **Passo 0.2** — Configurar estrutura de pastas (Clean Architecture)
- [x] **Passo 0.3** — Adicionar dependências core

## CONCLUIDO Fase 1 — Camada de Domínio (Lógica Pura)

- [x] **Passo 1.1** — Value Objects: Money e Quantity
- [x] **Passo 1.2** — Entidade ShoppingItem
- [x] **Passo 1.3** — Entidade ShoppingList e cálculo de total
- [x] **Passo 1.4** — Use Cases iniciais
- [x] **Passo 1.5** — Interface de Repositório

## CONCLUIDO Fase 2 — Persistência Local (Drift)

- [x] **Passo 2.1** — Schema Drift
- [x] **Passo 2.2** — Mapeadores Entity ↔ DB
- [x] **Passo 2.3** — LocalShoppingListRepository

## CONCLUIDO Fase 3 — UI da Lista de Compras

- [x] **Passo 3.1** — Providers Riverpod para lista atual
- [x] **Passo 3.2** — Tela de Lista de Compras (visualização)
- [x] **Passo 3.3** — Adicionar/Editar Item
- [x] **Passo 3.4** — Roteamento (GoRouter)
- [x] **Passo 3.5** — Tela de Listas Salvas

## CONCLUIDO Fase 4 — Features Avançadas

- [x] **Passo 4.1** — Captura de Foto da Etiqueta
- [x] **Passo 4.2** — Substituto do Item
- [x] **Passo 4.3** — Meta de Orçamento
- [x] **Passo 4.4** — Excluir tudo com Undo

## Fase 5 — Backend (Supabase)

- [ ] **Passo 5.1** — Setup Supabase + Auth
- [ ] **Passo 5.2** — RemoteShoppingListRepository
- [ ] **Passo 5.3** — SyncManager (offline ↔ online)

## Fase 6 — Analytics

- [ ] **Passo 6.1** — Tela de gráficos (semana/mês/ano)
- [ ] **Passo 6.2** — Heatmap de Metas (estilo GitHub Commits)

## Fase 7 — Exportação

- [ ] **Passo 7.1** — ExportService base
- [ ] **Passo 7.2** — Export PDF e TXT
- [ ] **Passo 7.3** — Export DOCX
- [ ] **Passo 7.4** — Export PPTX

## Fase 8 — Chat com IA

- [ ] **Passo 8.1** — Interface AIProvider
- [ ] **Passo 8.2** — Implementações dos provedores (Claude, OpenAI, Gemini)
- [ ] **Passo 8.3** — Tela de Chat com Nutricionista

## Fase 9 — Polish (Temas, i18n, Acessibilidade)

- [ ] **Passo 9.1** — Temas Claro/Escuro/Sistema
- [ ] **Passo 9.2** — Internacionalização (i18n)
- [ ] **Passo 9.3** — Acessibilidade e Auditoria Final

---

## Checklist Geral de Encerramento

### Funcional

- [ ] Todas as 9 fases concluídas com testes passando
- [ ] Cobertura global de testes ≥ 80%
- [ ] App funciona online e offline
- [ ] Login + modo sem login
- [ ] 3 idiomas + 3 temas
- [ ] Export nos 4 formatos
- [ ] Chat IA com 3 provedores configuráveis

### Segurança

- [ ] RLS ativo em todas as tabelas Supabase
- [ ] Chaves sensíveis em `flutter_secure_storage`
- [ ] Sem chaves hardcoded no código
- [ ] HTTPS obrigatório
- [ ] Permissões com mensagens claras
- [ ] Validação client + server

### Qualidade

- [ ] `flutter analyze` 100% limpo
- [ ] Sem warnings de deprecated
- [ ] CI/CD configurado
- [ ] App testado em pelo menos 3 dispositivos físicos

### Documentação

- [ ] README atualizado
- [ ] CHANGELOG.md mantido
- [ ] Política de privacidade documentada
