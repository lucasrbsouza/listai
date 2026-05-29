# 🏗️ Listaí — Arquitetura Técnica

## 1. Stack Tecnológica

### Frontend (Mobile)
- **Flutter** (3.x ou superior) — framework cross-platform.
- **Dart** como linguagem.
- **Riverpod** para gerenciamento de estado (alternativa: Bloc).
- **GoRouter** para navegação declarativa.
- **fl_chart** para gráficos.
- **flutter_localizations** + arquivos `.arb` para i18n.

### Backend (Cloud)
- **Supabase** (PostgreSQL + Auth + Storage + Realtime).
- **Row Level Security (RLS)** para isolamento de dados por usuário.
- **Edge Functions** (Deno) para lógica que não pode rodar no cliente (ex: proxy para chamadas de IA com chave do servidor, se aplicável).

### Persistência Local (Offline-first)
- **Drift** (SQLite tipado para Flutter) — banco local que espelha o schema do Supabase.
- **flutter_secure_storage** — para credenciais e chaves de API criptografadas (Keychain iOS / Keystore Android).
- **shared_preferences** — para preferências simples (tema, idioma).

### Integrações
- **IA**: abstração via interface `AIProvider` com implementações para Claude, OpenAI, Gemini.
- **Imagens**: `image_picker` (câmera/galeria) + `image` (manipulação) + Supabase Storage.
- **Exportação**: `pdf`, `docx_template`/`syncfusion_flutter_pdf`, `excel` ou geração via templates.
- **Compartilhamento**: `share_plus`.

## 2. Arquitetura em Camadas (Clean Architecture)

```
┌─────────────────────────────────────────────────────┐
│  PRESENTATION (UI)                                  │
│  - Screens (widgets)                                │
│  - Riverpod Providers (state)                       │
│  - Navigation (GoRouter)                            │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  DOMAIN (regras de negócio puras)                   │
│  - Entities (ShoppingItem, ShoppingList, Goal...)   │
│  - Use Cases (CalculateTotal, FinalizeShopping...)  │
│  - Repository Interfaces                            │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  DATA (acesso a dados)                              │
│  - Repository Implementations                       │
│  - Data Sources: LocalDS (Drift), RemoteDS (Supa)   │
│  - Models / DTOs                                    │
│  - Sync Manager (online ↔ offline)                  │
└─────────────────────────────────────────────────────┘
```

## 3. Estrutura de Pastas

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + tema + i18n
├── core/
│   ├── constants/
│   ├── theme/                        # ThemeData claro/escuro
│   ├── localization/                 # .arb files + delegate
│   ├── errors/                       # Failures e Exceptions
│   ├── network/                      # Cliente Supabase, interceptors
│   ├── storage/                      # SecureStorage wrapper
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── shopping_list/                # Núcleo: lista atual
│   │   ├── domain/
│   │   │   ├── entities/             # ShoppingItem, ShoppingList
│   │   │   ├── usecases/             # AddItem, CalculateTotal, etc
│   │   │   └── repositories/         # Interface
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/         # Implementação
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   ├── saved_lists/
│   ├── budget_goal/
│   ├── analytics/                    # Gráficos
│   ├── share_export/                 # PDF, TXT, DOCX, PPTX
│   ├── ai_chat/                      # Chat nutricionista
│   ├── settings/                     # Tema, idioma, IA
│   └── photo_capture/
│
├── shared/
│   ├── widgets/                      # Botões, inputs reutilizáveis
│   └── providers/
│
└── l10n/
    ├── app_pt.arb
    ├── app_en.arb
    └── app_es.arb

test/
├── unit/
├── widget/
└── integration/
```

## 4. Modelo de Dados (PostgreSQL / Supabase)

### Tabela `profiles`
```sql
id uuid PK (referencia auth.users)
display_name text
locale text default 'pt-BR'
theme_preference text default 'system'  -- 'light' | 'dark' | 'system'
ai_provider text                         -- 'claude' | 'openai' | 'gemini'
ai_api_key_encrypted text                -- opcional, se proxy não for usado
created_at timestamptz default now()
```

### Tabela `markets` (mercados frequentes)
```sql
id uuid PK
user_id uuid FK -> profiles.id
name text
created_at timestamptz default now()
```

### Tabela `shopping_lists`
```sql
id uuid PK
user_id uuid FK
name text                                -- ex: "Compra do mês"
market_id uuid FK -> markets.id (nullable)
budget_goal numeric(10,2) nullable
is_completed boolean default false       -- compra finalizada vs lista salva reutilizável
is_template boolean default false        -- lista salva para reuso
completed_at timestamptz nullable
created_at timestamptz default now()
updated_at timestamptz default now()
```

### Tabela `shopping_items`
```sql
id uuid PK
list_id uuid FK -> shopping_lists.id ON DELETE CASCADE
product_type text                        -- 'pão', 'ovo', 'carne', 'detergente'...
product_name text
brand text nullable
quantity numeric(10,3)                   -- decimal para suportar KG
unit_price numeric(10,2)
is_wholesale boolean default false       -- atacado/varejo
is_weight_based boolean default false    -- produto por KG
price_per_kg numeric(10,2) nullable
weight_kg numeric(10,3) nullable
photo_url text nullable                  -- referência Supabase Storage
photo_captured_at timestamptz nullable
substitute_item_id uuid FK -> shopping_items.id nullable
position integer                         -- ordem na lista
created_at timestamptz default now()
```

### Tabela `purchases` (compras finalizadas — alimenta analytics)
```sql
id uuid PK
user_id uuid FK
list_id uuid FK -> shopping_lists.id
market_id uuid FK -> markets.id nullable
total_amount numeric(10,2)
budget_goal numeric(10,2) nullable
exceeded_budget boolean default false
completed_at timestamptz default now()
```

### Tabela `purchase_items` (snapshot dos itens no momento da compra)
```sql
id uuid PK
purchase_id uuid FK -> purchases.id ON DELETE CASCADE
product_type text
product_name text
quantity numeric(10,3)
unit_price numeric(10,2)
total_price numeric(10,2)               -- já calculado
```

> Snapshot é necessário porque uma `shopping_list` template pode ser reutilizada e modificada, mas a compra histórica deve permanecer imutável para os analytics.

### Storage: bucket `product-photos`
- Path: `{user_id}/{list_id}/{item_id}.jpg`
- Política RLS: leitura/escrita apenas pelo dono do `user_id`.

### Row Level Security (exemplo)
```sql
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_own_lists"
  ON shopping_lists
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

## 5. Modelo Local (Drift / SQLite)

O schema local **espelha** o remoto, com colunas extras:
- `sync_status`: `'synced' | 'pending_upload' | 'pending_delete' | 'conflict'`.
- `local_updated_at`: timestamp local para resolução de conflitos.

### Estratégia de Sincronização
1. **Modo offline (sem login)** — opera apenas no Drift; nada é enviado.
2. **Modo online (com login)** — Drift é fonte de verdade local; um `SyncManager` reconcilia com Supabase:
   - **Upload**: itens com `sync_status = 'pending_upload'` são enviados em lote.
   - **Download**: usa Supabase Realtime para receber mudanças remotas.
   - **Conflito**: estratégia "last-write-wins" baseada em `updated_at`, com aviso ao usuário para conflitos críticos.
3. **Migração local → nuvem** ao criar conta: prompt "Migrar dados locais para a sua conta?".

## 6. Camada de IA (Interface Abstrata)

```dart
abstract class AIProvider {
  Future<NutritionistResponse> generateShoppingList({
    required List<DietGoal> goals,
    required List<DietType> dietTypes,
    required Locale locale,
    String? additionalContext,
  });
}

class ClaudeProvider implements AIProvider { ... }
class OpenAIProvider implements AIProvider { ... }
class GeminiProvider implements AIProvider { ... }
```

A IA **sempre retorna JSON estruturado** (validado contra um JSON Schema) para que possa ser convertido em itens de lista. Schema mínimo:
```json
{
  "items": [
    {
      "product_type": "string",
      "product_name": "string",
      "quantity": "number",
      "unit": "string",
      "substitutes": ["string"]
    }
  ],
  "notes": "string"
}
```

### Prompt-base (system prompt)
```
Você é uma Nutricionista Profissional brasileira certificada (CRN).
Considere os objetivos: {goals}
Considere as dietas: {diet_types}
Gere uma lista de compras semanal balanceada para uma pessoa adulta.
Responda APENAS com JSON válido seguindo o schema fornecido.
Não inclua texto fora do JSON. Não inclua markdown nem cercas de código.
```

## 7. Geração de Documentos (Export)

| Formato | Biblioteca Flutter | Estratégia |
|---|---|---|
| **PDF** | `pdf` + `printing` | Layout com tabela de itens e totais |
| **TXT** | nativo (`dart:io`) | Texto plano formatado em colunas |
| **DOCX** | `docx_template` ou template binário customizado | Substituição de placeholders em template |
| **PPTX** | template-based (pacote PPTX customizado ou geração via Open XML) | 1 slide de capa + 1 slide por bloco de itens |

Todos os exports passam pelo mesmo `ExportService` que recebe uma `ShoppingList` e produz um `File` temporário, em seguida acionando `share_plus`.

## 8. Segurança

### Autenticação
- Supabase Auth com email/senha (mínimo 8 caracteres, validação client+server).
- Tokens JWT armazenados em `flutter_secure_storage`, nunca em `shared_preferences`.
- Refresh token automático.

### Dados Sensíveis
- **Chave de API de IA**: nunca em texto claro no banco; criptografada localmente com `flutter_secure_storage`. Se houver proxy de servidor, jamais expor a chave ao cliente.
- **RLS no Supabase**: cada tabela com user_id tem política que restringe ao `auth.uid()`.
- **Storage**: políticas restringem leitura/escrita ao dono.

### Comunicação
- Apenas HTTPS.
- Certificate pinning para o domínio Supabase (`http` + `dio` com `dio_certificate_pinning`).

### Entrada do Usuário
- Validação dupla: client (UX) + server (constraints PostgreSQL e RLS).
- Sanitização de strings antes de exportar para HTML/PDF (prevenção contra injeção em templates).
- Limites de tamanho: nome de produto ≤ 200 chars, listas ≤ 500 itens, foto ≤ 5 MB.

### IA
- Sanitizar resposta JSON da IA com validação de schema (rejeitar JSON malformado).
- Limite de tokens por request para controle de custo e prevenção de prompt injection abusivo.
- Filtrar conteúdo da resposta antes de salvar (não permitir HTML/scripts em campos de texto).

### Privacidade
- Modo "sem login" não coleta nenhum dado externamente.
- Política de privacidade clara antes do primeiro envio.
- Botão "Exportar todos os meus dados" + "Excluir minha conta" (LGPD/GDPR compliance).

## 9. Testes

| Tipo | Cobertura mínima | Ferramentas |
|---|---|---|
| **Unit** | 90% em domain layer (use cases, entities, cálculos) | `test`, `mocktail` |
| **Widget** | 70% em widgets críticos | `flutter_test` |
| **Integration** | Fluxos principais (criar lista, finalizar, exportar) | `integration_test` |
| **Golden tests** | Telas principais em ambos temas | `golden_toolkit` |

## 10. CI/CD

- **GitHub Actions**:
  - Lint + formatação (`dart analyze`, `dart format --set-exit-if-changed`).
  - Rodar todos os testes em PR.
  - Build Android (apk + appbundle) e iOS em release no merge para `main`.
- **Distribuição**: Firebase App Distribution (beta) → Google Play / App Store (produção).

## 11. Observabilidade

- **Sentry** para captura de erros em produção.
- **PostHog** ou **Mixpanel** para analytics de uso (opt-in, conforme privacidade).
- Logs estruturados via `logger` (apenas dev/staging, nunca em produção sem opt-in).

## 12. Diagrama de Fluxo (Compra Típica)

```
[Usuário abre app]
        │
        ▼
[Login OU continuar sem login]
        │
        ▼
[Cria nova lista OU carrega lista salva]
        │
        ▼
[Adiciona itens (manual / câmera / IA chat)]
        │
        ▼
[Define meta de orçamento (opcional)]
        │
        ▼
[Vai ao mercado → preenche preços reais]
        │
        ▼
[Total atualiza em tempo real]
        │
        ▼
[Se total > meta → alerta vermelho]
        │
        ▼
[Finaliza compra → snapshot em purchases]
        │
        ▼
[Opção: salvar como lista reutilizável]
        │
        ▼
[Dados alimentam dashboards]
```
