# 📱 Listaí — App de Gestão Inteligente de Compras de Supermercado

## 1. Visão Geral

O **Listaí** é um aplicativo mobile (Flutter) que resolve um problema cotidiano: a dificuldade de planejar, controlar e analisar compras de supermercado de forma prática. O app substitui o ciclo "lista no papel + calculadora + estresse no caixa" por uma experiência integrada que acompanha o usuário desde o planejamento até a análise pós-compra, com suporte de IA para sugestões nutricionais.

## 2. Problema

O usuário enfrenta três dores principais ao fazer compras de supermercado:

1. **Esquecimento no planejamento** — não anota o que precisa comprar antes de sair de casa.
2. **Falta de controle no mercado** — anotar preços manualmente é trabalhoso e a calculadora não acompanha o fluxo (produto, quantidade, total).
3. **Surpresas no caixa** — preços divergem do que estava na prateleira e não há prova fácil.
4. **Falta de visão financeira** — não consegue analisar padrões de gasto, mercado mais caro, produtos mais frequentes.

## 3. Proposta de Valor

Um app que centraliza **planejamento → execução → análise** das compras, com:
- Lista de compras dinâmica com cálculo automático em tempo real.
- Captura visual de preços (prova fotográfica com timestamp).
- Cálculo automático para itens pesados (KG).
- Metas de orçamento com alertas.
- Dashboards de gastos (semanal, mensal, anual).
- Chat com IA configurável para gerar listas a partir de dietas.
- Suporte a modo offline (sem login) e online (sincronização via Supabase).

## 4. Funcionalidades Detalhadas

### 4.1 — Autenticação
- Login (e-mail/senha + provedores sociais via Supabase Auth).
- Modo "Continuar sem login" — dados ficam apenas no dispositivo (SQLite local). Se o app for desinstalado, os dados são perdidos.
- Migração de dados locais para a nuvem ao criar conta.

### 4.2 — Lista de Compras (núcleo do app)
Cada item da lista possui:
- **Tipo do produto** (pão, ovo, carne, detergente, sabonete, etc — categorias predefinidas + customizáveis).
- **Nome / marca** (texto livre).
- **Quantidade** (inteiro ou decimal para KG).
- **Preço unitário** (R$).
- **Modalidade**: varejo (padrão) ou atacado (quantidade padrão = 3, configurável).
- **Foto da etiqueta de preço** (com timestamp automático — data e hora da captura).
- **Item por peso (KG)**: ao marcar essa opção, o usuário informa o preço/KG e o peso da balança → o app calcula o preço final automaticamente.
- **Substituto opcional**: cada item pode ter um item substituto vinculado (com toggle "mostrar/ocultar"). O usuário pode trocar o item principal pelo substituto com um toque.
- **Mercado** vinculado à lista inteira (nome do supermercado).

Ações:
- **Total dinâmico**: a soma total dos itens é atualizada em tempo real.
- **Excluir item individual** com opção de "desfazer" (snackbar/toast por X segundos).
- **Excluir todos os itens** com opção de "desfazer" antes de salvar definitivamente.
- **Finalizar compra**: salva os dados como uma compra concluída, alimentando os gráficos e oferecendo salvar como lista reutilizável.

### 4.3 — Metas de Orçamento
- Usuário define um limite (ex: R$ 100,00) para a compra atual.
- Quando o total ultrapassa a meta:
  - O valor total fica em **vermelho**.
  - Aparece um aviso: "Você ultrapassou o orçamento em R$ X. Deseja finalizar as compras?"
- Histórico de metas é registrado para os gráficos.

### 4.4 — Listas Salvas
- Salvar a lista atual com um **nome personalizado** (ex: "Compra do mês", "Churrasco fim de semana").
- Salvar em **nova lista** ou **anexar a uma lista existente** (merge inteligente — itens duplicados perguntam se substitui ou soma).
- Aba "Listas Salvas": cards com nome, número de itens, total estimado e data.

### 4.5 — Dashboards e Gráficos
Visualizações por **semana / mês / ano**:
- Total gasto no período.
- Mercado onde mais gastou (ranking).
- Produtos mais comprados (ranking por frequência).
- Produtos com maior gasto acumulado (ranking por valor).
- Quantas vezes ultrapassou a meta.
- **Heatmap estilo GitHub Commits** para metas: cada dia é um quadradinho — vermelho se ultrapassou, verde se ficou abaixo ou igual, cinza se não houve compra.

### 4.6 — Compartilhamento
Exportar uma lista (atual ou salva) nos formatos:
- **PDF**
- **TXT**
- **DOCX**
- **PPTX**

O documento inclui: tipo, nome, quantidade, preço unitário, preço total por produto e total geral. Cabeçalho com nome da lista, mercado e data.

### 4.7 — Chat com IA (Nutricionista Configurável)
- Provedor de IA **abstrato/configurável** (Claude, GPT, Gemini — escolhível em configurações ou via chave de API do usuário).
- Prompt base: "Aja como uma Nutricionista Profissional brasileira certificada."
- **Foco/Objetivo** (multi-seleção):
  - Emagrecer
  - Ganhar massa muscular
  - Engordar
  - Manutenção / saúde geral
- **Tipo de dieta** (multi-seleção):
  - Mediterrânea
  - Cetogênica (Keto)
  - Low Carb
  - Vegana
  - Vegetariana
  - Flexitariana
  - Paleo
  - DASH
  - MIND
  - Low FODMAP
  - Jejum Intermitente
- A IA retorna uma lista estruturada (JSON) com produto, quantidade e substitutos possíveis.
- Botão **"Salvar como lista de compras"** já formata e cria a lista pronta.

### 4.8 — Configurações e Personalização
- Tema: **claro / escuro / sistema**.
- Idioma: **Português-BR / Inglês / Espanhol** (arquitetura preparada para adicionar mais).
- Moeda configurável (BRL padrão).
- Provedor de IA e chave de API (criptografada localmente).

## 5. Features Futuras (Roadmap)

| Feature | Descrição | Tecnologia |
|---|---|---|
| **Comparador de Preços** | Comparar produtos entre mercados/listas históricas, recomendar onde comprar mais barato. | ML / lógica de agregação no Supabase |
| **Entrada por Voz (Whisper)** | Ditar tipo, nome, quantidade e preço sem digitar. | Whisper API ou speech_to_text Flutter |
| **OCR de Etiqueta** | Tirar foto da etiqueta e extrair automaticamente os dados do produto. | Google ML Kit / Tesseract / GPT-4 Vision |

## 6. Métricas de Sucesso (MVP)

- Usuário consegue criar uma lista e finalizar uma compra em **menos de 3 minutos**.
- Cálculo total **sempre correto** (cobertura 100% de testes nas funções de cálculo).
- App funciona **offline** (sem login) para 100% das funcionalidades exceto IA e sincronização.
- Sincronização com Supabase em **menos de 5 segundos** para listas de até 100 itens.
- Geração de exportação (PDF/TXT/DOCX/PPTX) em **menos de 3 segundos** para listas de até 50 itens.

## 7. Persona Principal

> **Carlos, 32 anos, profissional autônomo.** Faz compras de supermercado a cada 15 dias, tenta controlar gastos mas perde dinheiro com compras impulsivas e preços errados no caixa. Já usa apps de finanças, mas quer algo focado em supermercado, prático no celular e que gere dados úteis sobre seus hábitos de consumo.

## 8. Restrições e Princípios

- **Privacidade primeiro**: dados sensíveis (chave de API, listas pessoais) ficam criptografados.
- **Offline-first**: usuário sem login tem 100% da experiência local funcionando.
- **Acessibilidade**: contraste mínimo WCAG AA, suporte a TalkBack/VoiceOver, fontes escaláveis.
- **Performance**: app deve abrir em menos de 2 segundos em dispositivos médios.
- **Internacionalização desde o dia 1**: todo texto via arquivos `.arb`, nunca hardcoded.
