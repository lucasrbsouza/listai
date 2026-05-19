# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Listaí** — Flutter mobile app for supermarket shopping management. Planning → execution → analytics flow with offline-first support and AI nutritionist chat.

## Stack

- **Flutter 3.16+** / Dart — Android + iOS only, bundle ID `com.listai.app`
- **Riverpod** — state management
- **GoRouter** — declarative navigation
- **Drift** — typed SQLite (offline-first local DB)
- **Supabase** — PostgreSQL + Auth + Storage + Realtime (cloud)
- **flutter_secure_storage** — encrypted credentials (JWT, AI API keys)
- **fl_chart** — analytics charts
- AI providers: `Claude`, `OpenAI`, `Gemini` via abstract `AIProvider` interface

## Commands (once Flutter project is initialized)

```bash
# Analyze
dart analyze

# Format check
dart format --set-exit-if-changed .

# Run all tests
flutter test

# Run single test file
flutter test test/unit/domain/shopping_item_test.dart

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/

# Build
flutter build apk          # Android debug
flutter build appbundle    # Android release
flutter build ios          # iOS release

# Generate Drift DB code
dart run build_runner build --delete-conflicting-outputs

# Generate l10n
flutter gen-l10n
```

## Architecture

Clean Architecture in 3 layers under `lib/features/<feature>/`:

```
presentation/   → screens, widgets, Riverpod providers
domain/         → entities, use cases, repository interfaces (pure Dart, no Flutter deps)
data/           → repository implementations, Drift datasource, Supabase datasource, models/DTOs
```

Cross-cutting under `lib/core/`: constants, theme, localization, errors, network (Supabase client), storage wrapper, utils.

Shared widgets/providers under `lib/shared/`.

l10n: `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb` — all user-facing strings go here, never hardcoded.

## Key Domain Rules

- `ShoppingItem.totalPrice`: if `is_weight_based` → `price_per_kg × weight_kg`; else `unit_price × quantity`.
- Total across list updates in real time as items change.
- Each item can have one optional `substitute_item_id` (self-referential FK).
- `is_wholesale` default quantity = 3 (configurable).
- `photo_captured_at` timestamp is set automatically at camera capture time — never editable.

## Data Layer: Offline/Online Sync

Local Drift schema mirrors Supabase schema plus:
- `sync_status`: `'synced' | 'pending_upload' | 'pending_delete' | 'conflict'`
- `local_updated_at`: for conflict resolution

Sync strategy: `SyncManager` — upload `pending_upload` in batch, receive remote changes via Supabase Realtime, conflict resolution is last-write-wins on `updated_at` (warn user on critical conflicts).

Offline mode (no login): 100% local, zero network calls. AI and sync features disabled.

## AI Layer

```dart
abstract class AIProvider {
  Future<NutritionistResponse> generateShoppingList({
    required List<DietGoal> goals,
    required List<DietType> dietTypes,
    required Locale locale,
    String? additionalContext,
  });
}
```

AI always returns validated JSON (reject malformed). Sanitize all AI response fields before saving. API keys stored in `flutter_secure_storage` only — never in DB or `shared_preferences`.

## Development Methodology

**TDD mandatory**: write failing test first, then implement (Red → Green → Refactor).

Coverage targets:
- Domain layer (use cases, entities, calculations): 90%
- Widget tests on critical widgets: 70%
- Integration tests: main flows (create list, finalize, export)
- Golden tests: main screens in both themes (`golden_toolkit`)

Test tools: `test`, `mocktail`, `flutter_test`, `integration_test`, `golden_toolkit`.

**Do not mock the Drift database in integration tests** — use an in-memory Drift DB.

## Export

`ExportService` receives `ShoppingList` → produces temp `File` → `share_plus`. Supported: PDF (`pdf`+`printing`), TXT (dart:io), DOCX (`docx_template`), PPTX (Open XML template). Sanitize all string fields before injecting into export templates.

## Security Constraints

- JWT tokens: `flutter_secure_storage` only.
- AI API keys: `flutter_secure_storage` only; if server proxy used, key never reaches client.
- All Supabase tables with `user_id` have RLS policy `auth.uid() = user_id`.
- Storage bucket `product-photos` path: `{user_id}/{list_id}/{item_id}.jpg`.
- Certificate pinning on Supabase domain via `dio` + `dio_certificate_pinning`.
- Input limits: product name ≤ 200 chars, list ≤ 500 items, photo ≤ 5 MB.
- Validate + sanitize at both client and server boundaries.

## CI/CD (GitHub Actions)

On PR: `dart analyze` + `dart format --set-exit-if-changed` + full test suite.
On merge to `main`: build Android (apk + appbundle) + iOS release.
Distribution: Firebase App Distribution (beta) → stores (prod).

## Observability

- **Sentry** — production error capture.
- **PostHog** or **Mixpanel** — opt-in usage analytics.
- Structured logging via `logger` — dev/staging only, never production without opt-in.
