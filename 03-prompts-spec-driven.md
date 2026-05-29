# 🧩 Listaí — Prompts em Spec-Driven Development (SDD + TDD)

> Este documento divide o desenvolvimento do **Listaí** em passos pequenos, sequenciais e isolados. Cada passo é um **prompt completo** para ser passado a um modelo de IA assistente de código.
>
> **Princípios aplicados em todos os prompts:**
> - **TDD obrigatório**: testes são escritos ANTES da implementação.
> - **Red → Green → Refactor**: teste falha → implementa para passar → refatora.
> - **Segurança como cidadão de primeira classe**: validação, sanitização e RLS sempre presentes.
> - **Critérios de aceite explícitos**: cada passo só termina quando todos os critérios são atendidos.
> - **Isolamento**: cada passo entrega algo funcional e testável sem depender de passos futuros.

---

## 📋 Índice de Fases

| Fase | Passos | Objetivo |
|---|---|---|
| **Fase 0 — Setup** | 0.1 a 0.3 | Projeto Flutter inicial, dependências, estrutura de pastas |
| **Fase 1 — Domínio** | 1.1 a 1.5 | Entidades, value objects, cálculos puros (sem UI/DB) |
| **Fase 2 — Persistência local** | 2.1 a 2.3 | Drift + repositórios locais (offline-first) |
| **Fase 3 — UI da lista** | 3.1 a 3.5 | Tela principal de compras e fluxos básicos |
| **Fase 4 — Features avançadas** | 4.1 a 4.4 | Foto, substituto, meta, KG |
| **Fase 5 — Backend** | 5.1 a 5.3 | Supabase + Auth + RLS + Sync |
| **Fase 6 — Analytics** | 6.1 a 6.2 | Gráficos e heatmap |
| **Fase 7 — Export** | 7.1 a 7.4 | PDF, TXT, DOCX, PPTX |
| **Fase 8 — IA** | 8.1 a 8.3 | Abstração + provedores + chat |
| **Fase 9 — Polish** | 9.1 a 9.3 | i18n, temas, acessibilidade |

---

## 🛠 FASE 0 — Setup do Projeto

### Passo 0.1 — Inicializar projeto Flutter

**Objetivo:** Criar a estrutura base do projeto Flutter com configurações iniciais.

**Prompt:**
```
Crie um novo projeto Flutter chamado "listai" com:
- Suporte a Android e iOS apenas.
- Organização (bundle ID): com.listai.app
- Versão mínima do Flutter: 3.16+
- Configurar analysis_options.yaml com regras estritas (incluir `flutter_lints` e habilitar `prefer_const_constructors`, `prefer_final_locals`, `avoid_print`).
- Criar arquivo README.md explicando como rodar o projeto.
- Criar .gitignore apropriado para Flutter, removendo qualquer arquivo gerado.

NÃO adicionar dependências ainda além do flutter_lints.
```

**Testes:**
- `flutter analyze` retorna 0 warnings/errors.
- `flutter test` roda o teste padrão e passa.

**Critérios de aceite:**
- [ ] Projeto compila em Android e iOS.
- [ ] `analysis_options.yaml` tem as regras especificadas.
- [ ] README contém instruções de setup (Flutter version, comandos).
- [ ] `flutter analyze` 100% limpo.

**Segurança:**
- [ ] `.gitignore` exclui `.env`, `*.keystore`, `key.properties`, `GoogleService-Info.plist` (se vier a existir).

---

### Passo 0.2 — Configurar estrutura de pastas (Clean Architecture)

**Objetivo:** Estabelecer a hierarquia de pastas conforme arquitetura definida.

**Prompt:**
```
No projeto listai, dentro de `lib/`, crie a seguinte estrutura de pastas vazias com um arquivo `.gitkeep` em cada uma para garantir versionamento:

lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── localization/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   └── utils/
├── features/
│   ├── auth/{domain,data,presentation}/
│   ├── shopping_list/{domain,data,presentation}/
│   ├── saved_lists/{domain,data,presentation}/
│   ├── budget_goal/{domain,data,presentation}/
│   ├── analytics/{domain,data,presentation}/
│   ├── share_export/{domain,data,presentation}/
│   ├── ai_chat/{domain,data,presentation}/
│   ├── settings/{domain,data,presentation}/
│   └── photo_capture/{domain,data,presentation}/
└── shared/
    ├── widgets/
    └── providers/

E também:
test/{unit,widget,integration}/

Atualize o `main.dart` para exibir apenas um Scaffold com texto "Listaí" centralizado.
```

**Testes:**
- Criar `test/widget/app_smoke_test.dart` que verifica que o widget raiz renderiza sem erros e exibe "Listaí".

**Critérios de aceite:**
- [ ] Toda a estrutura de pastas existe e é rastreada pelo Git.
- [ ] Smoke test passa.
- [ ] `flutter run` exibe a tela inicial sem erros.

---

### Passo 0.3 — Adicionar dependências core

**Objetivo:** Instalar e configurar as bibliotecas fundamentais.

**Prompt:**
```
Adicione ao `pubspec.yaml` as seguintes dependências e configure o básico:

Dependencies:
- flutter_riverpod: ^2.5.0
- go_router: ^14.0.0
- drift: ^2.18.0
- drift_flutter: ^0.2.0
- sqlite3_flutter_libs: ^0.5.0
- path_provider: ^2.1.0
- path: ^1.9.0
- flutter_secure_storage: ^9.0.0
- shared_preferences: ^2.2.0
- intl: ^0.19.0

Dev dependencies:
- mocktail: ^1.0.0
- drift_dev: ^2.18.0
- build_runner: ^2.4.0
- flutter_lints: ^4.0.0

Não escreva ainda nenhum código que use essas libs — apenas adicione, rode `flutter pub get` e confirme que tudo resolve.

Atualize o `main.dart` para envolver o app em um `ProviderScope` (Riverpod).
```

**Testes:**
- O smoke test do passo 0.2 continua passando.
- Adicionar teste que verifica que `ProviderScope` está no topo da árvore de widgets.

**Critérios de aceite:**
- [ ] `flutter pub get` executa sem conflitos.
- [ ] App ainda compila e roda.
- [ ] Todos os testes passam.

**Segurança:**
- [ ] Versões fixas com `^` para receber patches mas não breaking changes.
- [ ] Nenhuma dependência marcada como deprecated.

---

## 🧠 FASE 1 — Camada de Domínio (Lógica Pura)

> A camada de domínio é 100% Dart puro, sem nenhuma dependência de Flutter, Drift ou Supabase. Toda lógica de negócio mora aqui e é 100% testável unitariamente.

### Passo 1.1 — Value Objects: Money e Quantity

**Objetivo:** Criar tipos seguros para representar dinheiro e quantidades, evitando bugs de double.

**Prompt:**
```
Em `lib/core/utils/`, crie duas classes value-object imutáveis:

1. `Money`:
   - Armazena valor internamente como `int` representando centavos (ex: R$ 12,34 → 1234).
   - Construtores: `Money.fromCents(int)`, `Money.fromReais(double)`, `Money.zero()`.
   - Operadores: `+`, `-`, `*` (por int ou double), comparação (`<`, `>`, `==`).
   - Método `format({String locale, String symbol})` → "R$ 12,34" por padrão.
   - Lança `ArgumentError` se valor for negativo (não existe preço negativo).

2. `Quantity`:
   - Armazena `double` com até 3 casas decimais.
   - Construtor: `Quantity(double value)`, `Quantity.unit()` (= 1).
   - Operadores aritméticos.
   - Lança `ArgumentError` se ≤ 0.

ANTES de implementar:
1. Crie `test/unit/core/utils/money_test.dart` cobrindo:
   - Conversão centavos ↔ reais
   - Soma e subtração corretas (sem perda de precisão)
   - Multiplicação por inteiro e por double
   - Comparações
   - Formatação em pt-BR, en-US, es-ES
   - Erro em valor negativo
   - Igualdade estrutural

2. Crie `test/unit/core/utils/quantity_test.dart` cobrindo casos análogos.

3. Rode os testes — TODOS devem FALHAR (red).

4. Só então implemente as classes para passar.
```

**Testes (obrigatórios antes do código):**
- 12+ test cases para Money.
- 8+ test cases para Quantity.

**Critérios de aceite:**
- [ ] Todos os testes escritos antes da implementação.
- [ ] Cobertura ≥ 95% nas classes.
- [ ] Nenhum uso de `double` para representar dinheiro internamente.
- [ ] Classes são `@immutable` com `==` e `hashCode` corretos.

**Segurança:**
- [ ] Validações de entrada lançam exceções claras.
- [ ] Não há overflow em operações comuns (limite testado: até R$ 10.000.000,00).

---

### Passo 1.2 — Entidade ShoppingItem

**Objetivo:** Modelar o item de compra com todas as suas variantes.

**Prompt:**
```
Em `lib/features/shopping_list/domain/entities/`, crie a entidade `ShoppingItem`:

Campos:
- `id` (String — UUID v4)
- `productType` (String, não vazio, máx 100 chars)
- `productName` (String, não vazio, máx 200 chars)
- `brand` (String?, máx 100 chars)
- `quantity` (Quantity)
- `unitPrice` (Money)
- `isWholesale` (bool, default false)
- `isWeightBased` (bool, default false)
- `pricePerKg` (Money?) — obrigatório se isWeightBased=true
- `weightKg` (Quantity?) — obrigatório se isWeightBased=true
- `photoUrl` (String?)
- `photoCapturedAt` (DateTime?)
- `substituteItemId` (String?)
- `position` (int, ≥ 0)
- `createdAt` (DateTime)

Método `totalPrice` (computed):
- Se `isWeightBased`: `pricePerKg * weightKg.value`
- Se `isWholesale`: `unitPrice * quantity.value * 3` (atacado padrão multiplica por 3? CONFIRMAR REGRA — neste prompt: quantidade padrão de atacado é 3, então se o usuário não especificar quantity, é 3; o cálculo é `unitPrice * quantity.value`).
- Padrão (varejo): `unitPrice * quantity.value`

Método `copyWith(...)` para atualizações imutáveis.

Validações no construtor:
- Strings não vazias.
- Se `isWeightBased=true`, `pricePerKg` e `weightKg` são obrigatórios e `unitPrice` é ignorado/calculado.
- Não pode ter `isWeightBased` E `isWholesale` ao mesmo tempo.

ANTES de implementar:
- Crie `test/unit/features/shopping_list/domain/entities/shopping_item_test.dart` com:
  - Construção válida (varejo simples)
  - Construção válida (atacado)
  - Construção válida (por KG)
  - Cálculo correto de totalPrice em cada modalidade
  - Erros para entradas inválidas (campos vazios, conflitos, etc)
  - copyWith preserva valores não alterados

Rode os testes (devem falhar) → implemente → veja verde → refatore.
```

**Testes:**
- Mínimo 15 casos cobrindo cada modalidade e cada validação.

**Critérios de aceite:**
- [ ] Entidade é imutável (`@immutable`).
- [ ] `totalPrice` é coberto por testes em todas as modalidades.
- [ ] Validações lançam `ArgumentError` com mensagens claras.
- [ ] Não depende de Flutter (só `dart:core` + Money/Quantity).

**Segurança:**
- [ ] Limites de tamanho de string aplicados.
- [ ] Não permite estados inconsistentes (atacado + KG simultâneos).

---

### Passo 1.3 — Entidade ShoppingList e cálculo de total

**Objetivo:** Modelar a lista de compras agregando itens.

**Prompt:**
```
Em `lib/features/shopping_list/domain/entities/`, crie:

1. Entidade `ShoppingList`:
   - id (String UUID)
   - userId (String?) — null em modo offline
   - name (String, máx 100 chars)
   - marketName (String?, máx 100 chars)
   - budgetGoal (Money?)
   - items (List<ShoppingItem>, ordenada por position)
   - isCompleted (bool, default false)
   - isTemplate (bool, default false)
   - completedAt (DateTime?)
   - createdAt, updatedAt

2. Métodos computed:
   - `totalPrice` → soma de totalPrice de todos os itens (Money)
   - `itemCount` → items.length
   - `exceedsBudget` → bool (true se budgetGoal != null && totalPrice > budgetGoal)
   - `amountOverBudget` → Money (0 se não excede)

3. Métodos imutáveis:
   - `addItem(item)` → nova lista com item adicionado
   - `removeItem(itemId)` → nova lista
   - `updateItem(item)` → nova lista com item substituído
   - `reorder(itemId, newPosition)` → nova lista com positions ajustadas

ANTES de implementar:
- Crie testes cobrindo:
  - Lista vazia → totalPrice = 0
  - Lista com itens de várias modalidades → soma correta
  - exceedsBudget true/false/null
  - amountOverBudget correto
  - addItem/removeItem/updateItem retornam nova instância (imutabilidade)
  - reorder ajusta positions corretamente
  - Erros: removeItem com ID inexistente lança StateError
```

**Testes:**
- 20+ casos.
- Teste específico de imutabilidade (modificar a lista original não afeta a nova).

**Critérios de aceite:**
- [ ] ShoppingList é imutável.
- [ ] Cálculos são puros (sem efeitos colaterais).
- [ ] Todas as operações testadas.

**Segurança:**
- [ ] Limites de tamanho aplicados.
- [ ] Não permite items com IDs duplicados (validação no construtor).

---

### Passo 1.4 — Use Cases iniciais

**Objetivo:** Criar use cases puros que encapsulam ações do usuário.

**Prompt:**
```
Em `lib/features/shopping_list/domain/usecases/`, crie os use cases (cada um em arquivo separado):

1. `AddItemToList`:
   - Input: ShoppingList atual + ShoppingItem novo
   - Output: ShoppingList atualizada
   - Atribui automaticamente a `position` correta.

2. `RemoveItemFromList`:
   - Input: ShoppingList atual + itemId
   - Output: ShoppingList atualizada (com positions reajustadas)

3. `CalculateTotal`:
   - Input: ShoppingList
   - Output: Money

4. `CheckBudgetExceeded`:
   - Input: ShoppingList
   - Output: `BudgetCheckResult` (sealed class: `WithinBudget`, `ExceededBy(Money)`, `NoBudgetSet`)

Cada use case implementa um pattern simples:
```dart
class AddItemToList {
  ShoppingList call(ShoppingList list, ShoppingItem item) { ... }
}
```

ANTES: escreva os testes unitários completos para cada use case.
- Mínimo 4 testes por use case.
- Casos de borda: lista vazia, item duplicado por ID (deve lançar), reordenação de positions.
```

**Testes:**
- 4 use cases × ≥4 testes = 16+ testes.

**Critérios de aceite:**
- [ ] Use cases são classes puras (sem injeção de dependências ainda — só lógica).
- [ ] `BudgetCheckResult` é sealed/exhaustive.
- [ ] 100% de cobertura nos use cases.

---

### Passo 1.5 — Interface de Repositório

**Objetivo:** Definir o contrato abstrato sem implementação ainda.

**Prompt:**
```
Em `lib/features/shopping_list/domain/repositories/`, crie a interface abstrata `ShoppingListRepository`:

```dart
abstract class ShoppingListRepository {
  Future<ShoppingList?> getCurrentList();
  Future<void> saveCurrentList(ShoppingList list);
  Future<List<ShoppingList>> getSavedLists();
  Future<ShoppingList> getListById(String id);
  Future<void> saveAsTemplate(ShoppingList list);
  Future<void> deleteList(String id);
  Future<void> finalizePurchase(ShoppingList list);
  Stream<ShoppingList?> watchCurrentList();
}
```

Crie também em `lib/core/errors/` as classes:
- `Failure` (abstract)
- `LocalDatabaseFailure(String message)`
- `ValidationFailure(String message)`
- `NotFoundFailure(String message)`
- `NetworkFailure(String message)`
- `AuthFailure(String message)`

NÃO implemente o repositório ainda — apenas o contrato e os tipos de erro.

Testes: não há lógica para testar, mas:
- Verifique que as classes de erro têm `==` e `hashCode` corretos (use Equatable ou implemente manualmente) — escreva testes para isso.
```

**Critérios de aceite:**
- [ ] Interface clara e enxuta.
- [ ] Tipos de Failure documentados.
- [ ] Stream para reatividade incluído.

---

## 💾 FASE 2 — Persistência Local (Drift)

### Passo 2.1 — Schema Drift

**Objetivo:** Definir tabelas Drift correspondentes ao domínio.

**Prompt:**
```
Em `lib/features/shopping_list/data/datasources/local/`, crie:

1. `tables.dart` com:
   - `ShoppingListsTable`: id (TEXT PK), userId (TEXT NULL), name, marketName, budgetGoalCents (INT NULL), isCompleted, isTemplate, completedAt, createdAt, updatedAt, syncStatus (TEXT, default 'synced').
   - `ShoppingItemsTable`: id (TEXT PK), listId (TEXT FK), productType, productName, brand, quantityValue (REAL), unitPriceCents, isWholesale, isWeightBased, pricePerKgCents (INT NULL), weightKg (REAL NULL), photoUrl, photoCapturedAt, substituteItemId (TEXT NULL), position, createdAt, syncStatus.
   - `PurchasesTable`: id, userId, listId, marketName, totalAmountCents, budgetGoalCents, exceededBudget, completedAt.
   - `PurchaseItemsTable`: id, purchaseId, productType, productName, quantityValue, unitPriceCents, totalPriceCents.

2. `app_database.dart` com a classe `AppDatabase` extends `_$AppDatabase`, anotada `@DriftDatabase(tables: [...])`.

3. Configurar `build_runner` e gerar o código:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

ANTES de implementar:
- Crie `test/unit/features/shopping_list/data/datasources/app_database_test.dart`:
  - Usa `NativeDatabase.memory()` para in-memory DB.
  - Testa: criar lista, inserir itens, recuperar, deletar (cascade), atualizar.
  - Testa constraints: listId FK, position ≥ 0.

Os testes devem rodar antes da implementação completa — comece pelas migrações e schema.
```

**Testes:**
- 10+ testes de DB usando in-memory.

**Critérios de aceite:**
- [ ] Schema reflete o domínio.
- [ ] Migrations versionadas (`schemaVersion = 1`).
- [ ] FK cascade configurado para items quando lista é deletada.
- [ ] Build runner gera arquivos sem erros.

**Segurança:**
- [ ] Banco usa `path_provider` para localização correta no dispositivo.
- [ ] Considerar SQLCipher para criptografia em produção (TODO documentado).

---

### Passo 2.2 — Mapeadores Entity ↔ DB

**Objetivo:** Converter entre entidades de domínio e linhas do banco.

**Prompt:**
```
Em `lib/features/shopping_list/data/models/`, crie:

1. `shopping_item_mapper.dart`:
   - `ShoppingItem toEntity(ShoppingItemsTableData row)`
   - `ShoppingItemsCompanion toCompanion(ShoppingItem entity, {required String listId})`

2. `shopping_list_mapper.dart`:
   - Mesma ideia para ShoppingList.
   - O mapper de ShoppingList precisa carregar items em lote (recebe lista de items já carregados).

ANTES: escreva testes que:
- Convertem entity → companion → row → entity de volta e verificam que o dado é idêntico (round-trip).
- Testam valores nulos opcionais (brand, photoUrl, substituteItemId, etc).
- Testam Money convertido corretamente (centavos no DB, Money no domínio).

Importante: NUNCA expor a entidade Drift fora da camada de data. Mappers são a fronteira.
```

**Testes:**
- 10+ testes de round-trip.

**Critérios de aceite:**
- [ ] Conversão sem perda de dados.
- [ ] Domínio nunca importa Drift.
- [ ] Mappers são funções puras.

---

### Passo 2.3 — LocalShoppingListRepository

**Objetivo:** Implementar o repositório usando Drift.

**Prompt:**
```
Em `lib/features/shopping_list/data/repositories/`, crie `LocalShoppingListRepository` que implementa `ShoppingListRepository`:

- Recebe `AppDatabase` via construtor.
- Todos os métodos usam transações onde múltiplas tabelas são afetadas.
- `watchCurrentList()` usa `db.select(...).watch()` do Drift.
- `finalizePurchase(list)`:
  1. Cria snapshot em `purchases` e `purchase_items`.
  2. Marca a lista como `isCompleted = true`.
  3. Tudo dentro de uma transação.

ANTES: escreva testes de integração contra in-memory DB cobrindo:
- save/get/delete básicos
- watchCurrentList emite valores quando há mudanças
- finalizePurchase cria snapshot e não modifica items originais
- Concorrência: operações simultâneas não corrompem dados
- Failure cases: NotFoundFailure quando ID não existe
```

**Testes:**
- 15+ testes de integração com DB em memória.

**Critérios de aceite:**
- [ ] Todos os métodos da interface implementados.
- [ ] Transações garantidas onde necessário.
- [ ] Stream de currentList funciona reativamente.
- [ ] Erros mapeados para `Failure` apropriado.

**Segurança:**
- [ ] Queries sempre parametrizadas (Drift faz isso por padrão — confirmar).
- [ ] Nenhum dado de outro usuário acessível (em modo offline isso é trivial).

---

## 🎨 FASE 3 — UI da Lista de Compras

### Passo 3.1 — Providers Riverpod para lista atual

**Objetivo:** Estado reativo da lista atual via Riverpod.

**Prompt:**
```
Em `lib/features/shopping_list/presentation/providers/`, crie:

1. `database_provider.dart`:
   - `final databaseProvider = Provider<AppDatabase>((ref) => ...)`

2. `shopping_list_repository_provider.dart`:
   - Retorna `LocalShoppingListRepository`.

3. `current_list_provider.dart`:
   - `StateNotifierProvider<CurrentListNotifier, AsyncValue<ShoppingList?>>` que:
     - Carrega a lista atual ao inicializar.
     - Expõe métodos: `addItem`, `removeItem`, `updateItem`, `clearAll`, `finalizePurchase`.
     - Mantém histórico para undo (stack de últimas 5 ações).
     - Método `undo()` reverte a última ação.

ANTES: testes com `ProviderContainer` mockando o repositório:
- addItem atualiza o estado.
- removeItem + undo restaura.
- clearAll + undo restaura todos.
- Erros do repositório viram AsyncError.
```

**Testes:**
- 12+ testes com mock do repositório.

**Critérios de aceite:**
- [ ] Provider expõe `AsyncValue` (loading/data/error).
- [ ] Undo funciona até 5 ações para trás.
- [ ] Sem vazamento de memória (StateNotifier dispose corretamente).

---

### Passo 3.2 — Tela de Lista de Compras (visualização)

**Objetivo:** Tela principal que mostra a lista atual.

**Prompt:**
```
Em `lib/features/shopping_list/presentation/screens/`, crie `current_list_screen.dart`:

Layout:
- AppBar com:
  - Título "Lista Atual"
  - Ação: ícone de configurações
- Body:
  - Header: card com nome do mercado (editável) + meta de orçamento (editável).
  - Lista de items (ListView.builder com Cards).
  - Cada item exibe: tipo, nome, quantidade × preço unitário = total, ícone de foto se houver, ícone de substituto se houver.
  - Swipe-to-delete em cada item (com snackbar "Desfazer").
- Footer fixo:
  - Total geral em destaque (vermelho se exceder meta).
  - Botões: "Adicionar item" (FAB), "Finalizar Compra".

USE apenas widgets nativos do Flutter Material 3.
Consome `currentListProvider`.
Testes de widget:
- Renderiza lista vazia com mensagem amigável.
- Renderiza items quando há dados.
- Total em vermelho quando excede meta.
- Tap em FAB navega para tela de adicionar.
- Swipe-to-delete chama removeItem e mostra snackbar.

ANTES: escreva os widget tests usando `ProviderScope` com overrides.
```

**Testes:**
- 10+ widget tests.

**Critérios de aceite:**
- [ ] Tela renderiza em modo claro e escuro.
- [ ] Swipe funcional com undo.
- [ ] Atualização reativa (mudança no provider reflete na UI).
- [ ] Acessibilidade: semantic labels em todos os botões e cards.

---

### Passo 3.3 — Adicionar/Editar Item

**Objetivo:** Formulário de criação/edição de item.

**Prompt:**
```
Crie `item_form_screen.dart` em `presentation/screens/`:

Campos:
- Dropdown: Tipo do produto (lista padrão: Padaria, Carnes, Frutas/Verduras, Bebidas, Higiene, Limpeza, Mercearia, Outros) + "Customizar".
- TextField: Nome / marca (obrigatório, máx 200).
- Switch: Varejo / Atacado (atacado = quantidade padrão muda para 3).
- Switch: Por peso (KG).
  - Se ON: campos "Preço por KG" e "Peso (kg)" aparecem; "Quantidade" é desabilitado.
  - Se OFF: campos "Quantidade" e "Preço unitário".
- Botão: "Tirar foto da etiqueta" (placeholder por enquanto — passo 4.1 fará a captura real).
- Campo "Substituto" (será implementado no passo 4.2).
- Botão "Salvar".

Validação:
- Nome obrigatório.
- Preço > 0.
- Quantidade > 0.
- Se por KG: peso > 0 e preço/kg > 0.

Ao salvar, chama `currentListProvider.addItem(item)` e fecha tela.

ANTES: widget tests cobrindo:
- Validação de campos vazios (mostra erro).
- Validação de número negativo.
- Submit chama o provider.
- Toggle KG mostra/esconde campos corretos.
- Toggle Atacado define quantity = 3.
```

**Testes:**
- 12+ widget tests.

**Critérios de aceite:**
- [ ] Formulário validado client-side.
- [ ] Foco automático no primeiro campo ao abrir.
- [ ] Teclado numérico para campos numéricos.
- [ ] Botão Salvar desabilitado se inválido.

**Segurança:**
- [ ] Sanitização: trim em strings, remoção de caracteres de controle.
- [ ] Limite de comprimento aplicado.

---

### Passo 3.4 — Roteamento (GoRouter)

**Objetivo:** Configurar navegação entre as telas existentes.

**Prompt:**
```
Em `lib/core/`, crie `app_router.dart`:

Rotas iniciais:
- `/` → CurrentListScreen
- `/item/new` → ItemFormScreen (modo criação)
- `/item/:id/edit` → ItemFormScreen (modo edição, recebe item via state)
- `/settings` → SettingsScreen (placeholder por enquanto)

Use ShellRoute se planejar bottom navigation futuramente; por agora rotas simples bastam.

Substitua o MaterialApp em `app.dart` por `MaterialApp.router`.

Testes:
- Teste de navegação: tap no FAB navega para /item/new.
- Teste de back: voltar de /item/new retorna para /.
```

**Critérios de aceite:**
- [ ] Navegação tipada com extra/state.
- [ ] Deep links preparados (configuração para futuro).

---

### Passo 3.5 — Tela de Listas Salvas

**Objetivo:** Mostrar listas salvas (templates e compras finalizadas).

**Prompt:**
```
Crie `saved_lists_screen.dart`:

- 2 tabs: "Templates" e "Histórico".
- Templates: cards com nome, número de itens, total estimado.
- Histórico: cards com nome, data da compra, total real, mercado.
- Tap em card abre detalhe (nova tela `list_detail_screen.dart` somente leitura).
- No card de template: botão "Carregar como lista atual" — substitui a lista atual após confirmação.

Adicione a rota `/saved` e um botão de menu na AppBar da CurrentListScreen para acessar.

Provider novo: `savedListsProvider` que carrega templates + histórico do repositório.

Testes:
- Renderiza tabs corretas.
- Cards renderizam dados corretos.
- Confirmação antes de substituir lista atual.
```

**Critérios de aceite:**
- [ ] Pull-to-refresh nas listas.
- [ ] Empty state amigável quando não há listas.
- [ ] Confirmação destrutiva antes de substituir.

---

## 📸 FASE 4 — Features Avançadas

### Passo 4.1 — Captura de Foto da Etiqueta

**Objetivo:** Permitir anexar foto do preço a cada item.

**Prompt:**
```
Adicione dependências:
- image_picker: ^1.0.0
- path_provider: (já adicionada)

Em `lib/features/photo_capture/`, crie:

1. `data/photo_repository.dart`:
   - `Future<String> capturePhoto({required String itemId})` — abre câmera, salva em diretório do app, retorna path local.
   - `Future<void> deletePhoto(String path)`.

2. No formulário de item (passo 3.3), o botão "Tirar foto da etiqueta":
   - Tira foto e salva.
   - Salva timestamp em `photoCapturedAt`.
   - Mostra thumbnail abaixo do botão.
   - Permite remover/retirar nova foto.

3. Na visualização do item (passo 3.2), tap no ícone de foto abre `photo_viewer_screen.dart`:
   - Foto em tela cheia.
   - Overlay com data/hora da captura formatada.
   - Botão de fechar.

Permissões:
- Adicione `<uses-permission android:name="android.permission.CAMERA"/>` no AndroidManifest.
- Adicione `NSCameraUsageDescription` no Info.plist com mensagem clara.

Testes:
- Widget test: botão "Tirar foto" presente.
- Mock do `ImagePicker` para testar fluxo sem câmera real.
- Verificação que timestamp é salvo no momento da captura.

Segurança:
- Comprime foto para máximo 1024x1024 e qualidade 80% antes de salvar (`image_picker` aceita esses parâmetros).
- Validação: arquivo final ≤ 5 MB.
- Foto fica isolada no sandbox do app (não no diretório público).
```

**Testes:**
- 8+ testes (widget + unit).

**Critérios de aceite:**
- [ ] Permissão solicitada com mensagem clara.
- [ ] Foto comprimida.
- [ ] Timestamp preservado.
- [ ] Foto removível.

**Segurança:**
- [ ] Permissões com texto explicativo (não genérico).
- [ ] Foto não vai para galeria pública.

---

### Passo 4.2 — Substituto do Item

**Objetivo:** Permitir vincular um item substituto.

**Prompt:**
```
No formulário de item, adicione seção "Substituto":
- Toggle "Adicionar substituto".
- Se ON: campos do substituto (tipo, nome, quantidade, preço) em um sub-formulário.
- Cria 2 ShoppingItem internamente; o principal recebe `substituteItemId = sub.id`.

Na visualização da lista (CurrentListScreen):
- Item com substituto exibe um ícone de "swap" + toggle "Mostrar substituto" no card.
- Tap no toggle expande/colapsa o card mostrando o substituto.
- Botão "Trocar com principal" troca os papéis (o substituto vira principal, o principal vira substituto).

Testes:
- Item com substituto exibe o ícone.
- Toggle expande/colapsa.
- Trocar inverte os roles e atualiza o provider.
- Substituto sem principal nunca existe (regra: se principal é deletado, substituto também).

ANTES: escreva os testes primeiro.
```

**Critérios de aceite:**
- [ ] Vinculação correta no DB (FK opcional).
- [ ] UI clara e não confusa.
- [ ] Deletar principal deleta substituto (cascade na app, não no DB necessariamente).

---

### Passo 4.3 — Meta de Orçamento

**Objetivo:** Implementar alerta de orçamento excedido.

**Prompt:**
```
No header da CurrentListScreen, adicione um campo editável "Meta: R$ ___".

Crie `lib/features/budget_goal/presentation/providers/budget_provider.dart`:
- Stream que observa o total da lista atual + meta.
- Emite eventos: `WithinBudget`, `ExceededBy(Money)`, `NoBudgetSet`.

Quando o usuário adiciona um item que faz o total exceder a meta:
- O total no footer fica vermelho.
- Um BottomSheet/Dialog aparece:
  - Título: "Você ultrapassou o orçamento em R$ X,XX"
  - Texto: "Deseja finalizar as compras?"
  - Botões: "Continuar comprando", "Finalizar agora".

Use um listener no provider para acionar o dialog apenas uma vez por sessão (evite spam).

Testes:
- Total muda cor ao ultrapassar.
- Dialog aparece quando ultrapassa pela primeira vez.
- Dialog não reaparece a cada novo item após o primeiro.
- "Continuar" fecha o dialog mantendo o estado.
- "Finalizar" chama finalizePurchase.
```

**Critérios de aceite:**
- [ ] Cor reativa via Theme.
- [ ] Sem loops de dialog.
- [ ] Acessível: leitor de tela anuncia o alerta.

---

### Passo 4.4 — Excluir tudo com Undo

**Objetivo:** Permitir limpar a lista atual com possibilidade de desfazer.

**Prompt:**
```
Na CurrentListScreen, adicione botão de menu "Limpar tudo":
- Confirmação inicial: "Tem certeza? Você poderá desfazer esta ação."
- Ao confirmar:
  - Lista é limpa.
  - Snackbar persistente (duração 10s) com botão "Desfazer".
  - Estado dos items é mantido em memória até:
    - O usuário clicar "Desfazer" → restaura.
    - 10s passam OU usuário inicia outra ação destrutiva → confirma a exclusão definitivamente.
- Há um botão "Salvar como template antes de limpar" para preservar a lista.

Use o sistema de undo já implementado no `currentListProvider` no passo 3.1.

Testes:
- Limpar + undo restaura todos os items.
- Limpar + esperar 10s persiste a exclusão.
- Salvar como template + limpar funcionam em ordem.
```

**Critérios de aceite:**
- [ ] Undo só funciona dentro do tempo da snackbar.
- [ ] Sem perda de dados acidental.

---

## ☁️ FASE 5 — Backend (Supabase)

### Passo 5.1 — Setup Supabase + Auth

**Objetivo:** Conectar ao Supabase e implementar login.

**Prompt:**
```
Adicione dependência: supabase_flutter: ^2.5.0

Em `lib/core/network/supabase_client.dart`:
- Inicialize Supabase no `main.dart` com URL e ANON_KEY vindas de variáveis de ambiente (NUNCA hardcoded).
- Use `flutter_dotenv` ou `--dart-define` para passar as variáveis em build time.

Crie `lib/features/auth/` completo:
- `data/auth_repository.dart`:
  - `Future<User?> signInWithEmail(email, password)`
  - `Future<User?> signUpWithEmail(email, password)`
  - `Future<void> signOut()`
  - `Stream<User?> authStateChanges()`
- `presentation/screens/login_screen.dart` e `signup_screen.dart`.
- `presentation/screens/welcome_screen.dart` com botões "Entrar", "Criar conta", "Continuar sem login".

Roteamento:
- Tela inicial: welcome_screen se não autenticado.
- Após login OU "continuar sem login" → CurrentListScreen.
- Estado de "modo offline" é guardado em um provider.

Migrações SQL no Supabase (incluir em `supabase/migrations/`):
- Criar tabelas conforme arquitetura.
- Criar políticas RLS:
  ```sql
  ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users_own_lists" ON shopping_lists FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  ```
- Repetir para todas as tabelas com user_id.

Testes:
- Mock do SupabaseClient.
- AuthRepository: signIn sucesso, signIn falha, signUp sucesso, signOut.
- WelcomeScreen: 3 botões presentes, cada um navega corretamente.
- Validação de email e senha (mín. 8 chars) no client.

Segurança:
- Senhas nunca logadas.
- Erro de credenciais inválidas: mensagem genérica "Credenciais inválidas" (não revelar se email existe).
- ANON_KEY no app é OK (foi feita para isso), mas SERVICE_KEY JAMAIS no client.
```

**Critérios de aceite:**
- [ ] Login + signup funcionam contra Supabase real.
- [ ] RLS ativo em todas as tabelas (testar manualmente: tentar acessar dados de outro user → bloqueado).
- [ ] Modo offline persiste como provider state.
- [ ] Tokens em flutter_secure_storage.

**Segurança:**
- [ ] Nenhuma chave em código versionado.
- [ ] HTTPS forçado (Supabase já faz).
- [ ] Validação de senha forte (mín 8, com letra e número).

---

### Passo 5.2 — RemoteShoppingListRepository

**Objetivo:** Implementação remota do repositório.

**Prompt:**
```
Crie `lib/features/shopping_list/data/repositories/remote_shopping_list_repository.dart`:

Implementa `ShoppingListRepository` usando o cliente Supabase:
- CRUD em `shopping_lists` e `shopping_items`.
- `watchCurrentList()` usa Supabase Realtime (channel + subscription).
- `finalizePurchase` faz a operação em transação via RPC (criar função SQL `finalize_purchase(list_id uuid)`).

Crie a RPC no Supabase:
```sql
CREATE OR REPLACE FUNCTION finalize_purchase(p_list_id uuid)
RETURNS uuid AS $$
DECLARE
  v_purchase_id uuid;
BEGIN
  -- Verificar ownership
  IF NOT EXISTS (
    SELECT 1 FROM shopping_lists
    WHERE id = p_list_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Lista não encontrada ou sem permissão';
  END IF;

  -- Criar purchase + snapshot
  INSERT INTO purchases (...) VALUES (...) RETURNING id INTO v_purchase_id;
  INSERT INTO purchase_items (...) SELECT ... FROM shopping_items WHERE list_id = p_list_id;
  UPDATE shopping_lists SET is_completed = true, completed_at = now() WHERE id = p_list_id;

  RETURN v_purchase_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Testes:
- Mock do supabase client.
- Cada método: sucesso e erro de rede.
- Verificar que erros de rede viram `NetworkFailure`.
- Erros de auth viram `AuthFailure`.

Segurança:
- RPC com `SECURITY DEFINER` mas com verificação explícita de `auth.uid()`.
- Nenhuma query SQL crua no client; usar somente o builder do supabase-flutter.
```

**Critérios de aceite:**
- [ ] Todos os métodos da interface implementados.
- [ ] Realtime funcional.
- [ ] Erros mapeados para Failures.

---

### Passo 5.3 — SyncManager (offline ↔ online)

**Objetivo:** Sincronizar dados locais com a nuvem.

**Prompt:**
```
Crie `lib/core/network/sync_manager.dart`:

Responsabilidades:
1. Quando o usuário faz login pela primeira vez COM dados locais → perguntar se quer migrar.
2. Em background, periodicamente (ou em reação a mudanças):
   - Enviar registros com `syncStatus = 'pending_upload'`.
   - Marcar como `'synced'` após sucesso.
3. Receber via Realtime mudanças remotas e aplicar no Drift.
4. Resolução de conflitos: last-write-wins por `updated_at`; conflitos críticos marcam `syncStatus = 'conflict'` e notificam o usuário.

Arquitetura:
- `OfflineRepository` (Drift) é sempre a fonte de verdade local.
- `RemoteRepository` (Supabase) é a fonte de verdade remota.
- `SyncManager` é o coordenador.
- `CompositeRepository` implementa `ShoppingListRepository` e decide qual fonte usar conforme conectividade.

Use `connectivity_plus: ^6.0.0` para detectar online/offline.

Testes:
- Mock dos dois repositories.
- Pending uploads são enviados ao conectar.
- Conflitos detectados e marcados.
- Migração de dados locais para nuvem funciona end-to-end (teste integration).

Segurança:
- Nunca enviar dados se user_id não está autenticado.
- Rate limit no upload (máx 100 ops/min) para evitar abuso.
```

**Critérios de aceite:**
- [ ] App funciona online e offline sem perda de dados.
- [ ] Migração explicitamente confirmada pelo usuário.
- [ ] Sem loops infinitos de sync.

---

## 📊 FASE 6 — Analytics

### Passo 6.1 — Tela de gráficos (semana/mês/ano)

**Objetivo:** Dashboards com gastos.

**Prompt:**
```
Adicione dependência: fl_chart: ^0.68.0

Em `lib/features/analytics/`:

1. `domain/usecases/`:
   - `GetSpendingByPeriod(period: weekly|monthly|yearly)`
   - `GetTopMarkets(period)`
   - `GetMostBoughtProducts(period)`
   - `GetTopSpendingProducts(period)`
   - `GetBudgetExceededCount(period)`

Todos consomem a tabela `purchases` e `purchase_items`.

2. `presentation/screens/analytics_screen.dart`:
   - DropdownButton para selecionar período.
   - Gráfico de linha: total gasto por dia/semana/mês.
   - Gráfico de barras: top 5 mercados.
   - Lista: top 5 produtos mais comprados.
   - Lista: top 5 produtos com maior gasto.
   - Indicador: "Ultrapassou meta X vezes em Y compras".

Testes:
- Use cases com dados mockados.
- Edge cases: período sem compras → mensagens "Nenhum dado".
- Cálculos verificados com fixtures.

ANTES: escreva testes para cada use case com dados de teste.
```

**Testes:**
- 15+ testes nos use cases.

**Critérios de aceite:**
- [ ] Gráficos legíveis em ambos os temas.
- [ ] Empty state.
- [ ] Performance: tela carrega em <1s com 1000 compras.

---

### Passo 6.2 — Heatmap de Metas (estilo GitHub Commits)

**Objetivo:** Visualização de consistência das metas.

**Prompt:**
```
Crie um widget customizado `BudgetHeatmap` em `lib/features/analytics/presentation/widgets/`:

- Grid de 52 colunas × 7 linhas (1 ano).
- Cada célula representa um dia.
- Cores:
  - Verde (variações de intensidade): meta atingida (abaixo ou igual).
  - Vermelho (variações de intensidade): meta ultrapassada (intensidade ~ tamanho do excesso).
  - Cinza: sem compra registrada.
- Tooltip ao tap: "DD/MM — Gasto: R$ X de R$ Y (meta)".

Use `CustomPaint` para performance.

Use case: `GetDailyBudgetStatus(startDate, endDate)` → retorna `List<DayStatus>`.

Testes:
- Use case com fixture de 365 dias.
- Widget renderiza 365 células.
- Cores corretas para cada estado.
- Tap chama callback com data correta.
```

**Critérios de aceite:**
- [ ] Renderização em <100ms.
- [ ] Acessibilidade: semantic label por célula.
- [ ] Funciona em telas pequenas (scroll horizontal se necessário).

---

## 📤 FASE 7 — Exportação

### Passo 7.1 — ExportService base

**Objetivo:** Interface comum para todos os formatos.

**Prompt:**
```
Adicione dependências:
- pdf: ^3.10.0
- printing: ^5.12.0
- share_plus: ^9.0.0

Em `lib/features/share_export/domain/`:
```dart
abstract class ExportFormatter {
  ExportFormat get format;
  Future<File> export(ShoppingList list);
}

enum ExportFormat { pdf, txt, docx, pptx }
```

Crie `ExportService` que recebe uma list + format e:
1. Delega ao formatter correto.
2. Chama `share_plus` para abrir o seletor de compartilhamento.

Testes:
- ExportService delega corretamente.
- Erros de formatação são tratados.
```

**Critérios de aceite:**
- [ ] Interface estável.
- [ ] Compartilhamento funcional.

---

### Passo 7.2 — Export PDF e TXT

**Prompt:**
```
Implemente `PdfFormatter` e `TxtFormatter`.

PDF:
- Capa: nome da lista, mercado, data.
- Tabela: tipo | nome | qtd | preço unit | total.
- Rodapé: total geral, meta (se houver), excesso.

TXT:
- Mesmas informações em texto plano, formatado em colunas com espaços.

Testes:
- PDF gera arquivo válido (tamanho > 0, header %PDF).
- TXT contém todos os itens e total.
- Caracteres especiais (ç, ã, é) renderizam corretamente.

Segurança:
- Escapar caracteres especiais (HTML/XML não aplicável a PDF/TXT, mas validar input).
```

**Critérios de aceite:**
- [ ] PDF abre em leitores comuns.
- [ ] TXT renderiza em editores diversos.

---

### Passo 7.3 — Export DOCX

**Prompt:**
```
Adicione dependência: docx_template ou implementar geração manual.

Implemente `DocxFormatter`:
- Use template `assets/templates/list_template.docx` com placeholders ({{list_name}}, {{items_table}}, {{total}}).
- Substitua placeholders no momento da geração.

Inclua o template no `pubspec.yaml` em `assets`.

Testes:
- Arquivo gerado tem extensão .docx.
- Conteúdo dinâmico aparece no documento (extrair texto e validar).
```

**Critérios de aceite:**
- [ ] DOCX abre em Word, LibreOffice e Google Docs.
- [ ] Tabela formatada legivelmente.

---

### Passo 7.4 — Export PPTX

**Prompt:**
```
Implemente `PptxFormatter`:
- Use template similar `assets/templates/list_template.pptx`.
- 1 slide de capa + 1 slide para cada 10 itens (paginação).

Testes:
- Arquivo gerado abre em PowerPoint/Keynote.
- Número de slides correto para diferentes tamanhos de lista.
```

**Critérios de aceite:**
- [ ] Slides legíveis.
- [ ] Paginação correta.

---

## 🤖 FASE 8 — Chat com IA

### Passo 8.1 — Interface AIProvider

**Objetivo:** Abstração que permite trocar de provedor.

**Prompt:**
```
Em `lib/features/ai_chat/domain/`:

```dart
abstract class AIProvider {
  String get name; // 'claude', 'openai', 'gemini'
  Future<NutritionistResponse> generateShoppingList({
    required List<DietGoal> goals,
    required List<DietType> dietTypes,
    required Locale locale,
  });
}

class NutritionistResponse {
  final List<AIShoppingItem> items;
  final String? notes;
}

class AIShoppingItem {
  final String productType;
  final String productName;
  final double quantity;
  final String unit;
  final List<String> substitutes;
}

enum DietGoal { loseWeight, gainMuscle, gainWeight, maintain }
enum DietType { mediterranean, keto, lowCarb, vegan, vegetarian, flexitarian, paleo, dash, mind, lowFodmap, intermittentFasting }
```

Validação:
- Resposta da IA é validada contra JSON Schema.
- Se inválida: lança `AIResponseFailure` com mensagem clara.

Testes:
- JSON válido → parseado corretamente.
- JSON inválido → exceção.
- Schema cobre todos os campos obrigatórios.
```

**Critérios de aceite:**
- [ ] Interface limpa e plugável.
- [ ] Validação robusta.

---

### Passo 8.2 — Implementações dos provedores

**Prompt:**
```
Implemente:
- `ClaudeAIProvider` (Anthropic API)
- `OpenAIProvider` (OpenAI API)
- `GeminiProvider` (Google AI API)

Cada implementação:
- Recebe chave de API via construtor (vinda de `flutter_secure_storage`).
- Faz chamada HTTP com `http` ou `dio`.
- Usa o prompt-base da arquitetura.
- Valida resposta com schema.

Provider Riverpod `aiProviderProvider` retorna a implementação baseada na config do usuário.

Testes:
- Mock HTTP server (`http_mock_adapter` para dio).
- Cada provider: sucesso, erro 401, erro 500, timeout, JSON malformado.

Segurança:
- Timeout de 30s.
- Retry exponencial até 3 vezes para erros 5xx.
- Chave nunca logada nem incluída em mensagens de erro.
- Validação de tamanho de resposta (máx 100KB) para evitar abuso.
- Rate limit local: máx 5 requests por minuto.
```

**Critérios de aceite:**
- [ ] Os 3 provedores funcionam.
- [ ] Erros tratados graciosamente.
- [ ] Configuração na tela de Settings.

**Segurança:**
- [ ] Chave de API criptografada em repouso.
- [ ] Sem logs de payload da IA em produção.

---

### Passo 8.3 — Tela de Chat com Nutricionista

**Prompt:**
```
Crie `ai_chat_screen.dart`:

UI:
- Painel superior: seletores multi-choice para Foco e Tipo de Dieta.
- Botão "Gerar lista".
- Resultado em card: lista de itens da IA + nome sugerido + notas.
- Botão "Salvar como nova lista de compras".

Flow:
1. Usuário escolhe foco e dieta.
2. Botão chama `aiProvider.generateShoppingList(...)`.
3. Loading state durante geração.
4. Resultado exibido.
5. Salvar converte AIShoppingItem → ShoppingItem e cria nova lista.

Testes:
- Sem seleção → botão desabilitado.
- Erro da IA → mensagem clara, opção de tentar novamente.
- Sucesso → resultado renderizado.
- Salvar → chama provider de lista atual.

Segurança:
- Sanitizar campos retornados pela IA antes de salvar (limites de tamanho, remoção de caracteres de controle).
- Confirmação antes de substituir lista atual.
```

**Critérios de aceite:**
- [ ] UX clara para o usuário não técnico.
- [ ] Loading com indicador apropriado.
- [ ] Sem perda de seleção em erros.

---

## 🎨 FASE 9 — Polish (Temas, i18n, Acessibilidade)

### Passo 9.1 — Temas Claro/Escuro/Sistema

**Prompt:**
```
Em `lib/core/theme/`:
- `light_theme.dart` e `dark_theme.dart` com Material 3.
- Paleta definida: primary, secondary, error, surface.
- `themeProvider` (Riverpod) que lê preferência do `shared_preferences` e do `Brightness.platformBrightnessOf`.

Settings: dropdown para escolher tema (claro/escuro/sistema).

Testes:
- Mudar preferência → tema muda imediatamente.
- 'system' segue platformBrightness.

Golden tests:
- CurrentListScreen em ambos os temas.
- AnalyticsScreen em ambos os temas.
```

**Critérios de aceite:**
- [ ] Sem hardcoded colors em widgets.
- [ ] Contraste WCAG AA validado.

---

### Passo 9.2 — Internacionalização (i18n)

**Prompt:**
```
Configure `flutter_localizations` e `intl`.

Crie `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb`.

Migre TODOS os textos hardcoded para AppLocalizations.

Settings: dropdown de idioma (PT-BR / EN / ES / Sistema).

Testes:
- Mudança de locale atualiza UI.
- Todos os 3 idiomas têm as mesmas chaves (script de validação).

Segurança:
- Strings traduzidas não devem conter HTML/scripts (validação no build).
```

**Critérios de aceite:**
- [ ] Zero strings hardcoded em widgets.
- [ ] 3 idiomas funcionais.
- [ ] Plurais e formatação numérica/de data corretos por locale.

---

### Passo 9.3 — Acessibilidade e Auditoria Final

**Prompt:**
```
Audite e ajuste:
- Semantic labels em todos os botões, ícones, e elementos interativos.
- Foco visível.
- Tamanhos mínimos de toque (48x48 dp).
- Suporte a fontes escaláveis (não usar tamanhos fixos com `fontSize` direto; usar `Theme.of(context).textTheme`).
- Contraste mínimo 4.5:1 para texto.

Rode auditoria com:
- `flutter test --machine` para verificar warnings.
- `flutter pub run flutter_lints` (já configurado).

Testes:
- Widget tests verificam Semantics em screens principais.
- Testar com TalkBack/VoiceOver manualmente.

Segurança final:
- Revisar todas as permissões no AndroidManifest e Info.plist.
- Confirmar que ProGuard/R8 está ativo para release Android.
- Validar que builds release não incluem logs sensíveis.
```

**Critérios de aceite:**
- [ ] Score Lighthouse-equivalent passa em telas críticas.
- [ ] Sem warnings de acessibilidade.
- [ ] Apk release ofuscado.

---

## ✅ Checklist Geral de Encerramento

Antes de considerar o MVP pronto:

### Funcional
- [ ] Todas as 9 fases concluídas com testes passando.
- [ ] Cobertura global de testes ≥ 80%.
- [ ] App funciona online e offline.
- [ ] Login + modo sem login.
- [ ] 3 idiomas + 3 temas.
- [ ] Export nos 4 formatos.
- [ ] Chat IA com 3 provedores configuráveis.

### Segurança
- [ ] RLS ativo em todas as tabelas Supabase.
- [ ] Chaves sensíveis em `flutter_secure_storage`.
- [ ] Sem chaves hardcoded no código.
- [ ] HTTPS obrigatório.
- [ ] Permissões com mensagens claras.
- [ ] Validação client + server.

### Qualidade
- [ ] `flutter analyze` 100% limpo.
- [ ] Sem warnings de deprecated.
- [ ] CI/CD configurado.
- [ ] App testado em pelo menos 3 dispositivos físicos (Android baixo/médio/alto + iOS).

### Documentação
- [ ] README atualizado.
- [ ] CHANGELOG.md mantido.
- [ ] Política de privacidade documentada.

---

## 📝 Notas para a IA Executora dos Prompts

Ao receber qualquer um dos prompts acima, a IA deve:

1. **Sempre começar pelos testes** (TDD), confirmar que falham, e só então implementar.
2. **Não saltar passos** — cada passo depende dos anteriores.
3. **Validar segurança** mesmo se não explícito (sanitização, limites, validação).
4. **Documentar decisões** em comentários quando há trade-offs.
5. **Pedir confirmação** ao usuário antes de qualquer mudança destrutiva ou que afete múltiplos arquivos críticos.
6. **Rodar testes ao final** de cada passo e mostrar a saída.
7. **Marcar critérios de aceite** explicitamente como atendidos antes de declarar o passo concluído.
