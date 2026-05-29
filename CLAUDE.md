# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Listaí** — Flutter mobile app for supermarket shopping management. Planning → execution → analytics flow with offline-first support and AI nutritionist chat.

## Status

Progress tracked in `TODO.md` (phases 0–9). Done: **Fase 0–6** — domain, Drift persistence, list UI, advanced features (photo/substitute/budget/clear-undo), Supabase backend + auth + sync, analytics (charts + budget heatmap). **Pending: Fase 7** (export), **8** (AI chat), **9** (themes/i18n/a11y).

Currently in **beta testing**: signed Android APKs shipped to testers via tagged GitHub Releases (see Build & Release). iOS not yet built (needs macOS/Xcode).

## Stack

- **Flutter 3.16+** / Dart — Android + iOS only, bundle ID `com.listai.app`
- **Riverpod** — state management
- **GoRouter** — declarative navigation
- **Drift** — typed SQLite (offline-first local DB)
- **Supabase** — PostgreSQL + Auth + Storage + Realtime (cloud)
- **flutter_secure_storage** — encrypted credentials (JWT, AI API keys)
- **fl_chart** — analytics charts
- AI providers: `Claude`, `OpenAI`, `Gemini` via abstract `AIProvider` interface

## Commands

```bash
# Analyze (CI ignores infos/warnings for now; errors are fatal)
flutter analyze
flutter analyze --no-fatal-infos --no-fatal-warnings   # what CI runs

# Format check (CI gate — keep code formatted)
dart format --set-exit-if-changed .

# Run all tests
flutter test

# Run single test file
flutter test test/unit/features/shopping_list/domain/entities/shopping_item_test.dart

# Run a folder (unit / widget / integration tests all live under test/)
flutter test test/widget/
flutter test test/integration/

# Build (release APK is signed via key.properties — see Build & Release)
flutter build apk --release

# Generate Drift DB code (after editing tables.dart)
dart run build_runner build --delete-conflicting-outputs

# Regenerate launcher icons / native splash (after changing assets/logo/)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Tests live under `test/{unit,widget,integration}/` (not `integration_test/`).

## Architecture

Clean Architecture in 3 layers under `lib/features/<feature>/`:

```
presentation/   → screens, widgets, Riverpod providers
domain/         → entities, use cases, repository interfaces (pure Dart, no Flutter deps)
data/           → repository implementations, Drift datasource, Supabase datasource, models/DTOs
```

Cross-cutting under `lib/core/`: constants, theme, localization, errors, network (Supabase client), storage wrapper, utils.

Shared widgets/providers under `lib/shared/`.

l10n (Fase 9, not done yet): target is `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb`. Until then UI strings are hardcoded in pt-BR; new strings should still be written so they're easy to extract later.

Feature dirs in use: `auth`, `shopping_list` (core), `budget_goal`, `analytics`, `photo_capture`, `settings`. Not yet built: `share_export`, `ai_chat`, `saved_lists` (history currently lives inside `shopping_list`).

## Key Domain Rules

- `ShoppingItem.totalPrice`: if `is_weight_based` → `price_per_kg × weight_kg`; else `unit_price × quantity`.
- Total across list updates in real time as items change.
- Each item can have one optional `substitute_item_id` (self-referential FK).
- `is_wholesale` default quantity = 3 (configurable).
- `photo_captured_at` timestamp is set automatically at camera capture time — never editable.

## Gotchas (learned the hard way)

- **Drift table names**: a `class FooTable extends Table` generates SQL table name `foo_table` (snake_case of the class, sufix kept). Raw `customSelect` queries must use `purchases_table` / `purchase_items_table`, NOT `purchases`. Mocked unit tests won't catch this — always add an in-memory integration test that runs the real SQL.
- **Drift stores `DateTime` as unix SECONDS** (no `storeDateTimeValuesAsText`). In raw SQL compare against `millisecondsSinceEpoch ~/ 1000` and use `date(col, 'unixepoch')` (no `/1000`).
- **Aggregates over an empty table return NULL** — wrap bare `SUM(...)` (no `GROUP BY`) in `COALESCE(..., 0)` before `row.read<int>`.
- **Navigation is GoRouter only** — use `context.go` / `context.push`. Never `Navigator.pushNamed` (no `onGenerateRoute` registered; throws at runtime).
- **`FutureProvider` caches** — list/history providers that must reflect fresh DB state use `FutureProvider.autoDispose` and/or `ref.invalidate(...)` after a mutation.

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

Two workflows in `.github/workflows/`:

- **`ci.yml`** — on push/PR to `main`: `dart format --set-exit-if-changed` + `flutter analyze --no-fatal-infos --no-fatal-warnings` + `flutter test`.
- **`release.yml`** — on push of a tag `v*`: tests → build signed APK → publish a GitHub Release with `listai-<tag>.apk` attached.

To cut a release: bump `version:` in `pubspec.yaml`, commit, then `git tag vX.Y.Z -m "..." && git push origin vX.Y.Z`. The pipeline builds and publishes automatically.

## Build & Release (Android signing)

Release builds are signed with a project keystore (NOT the debug key) so testers can update in place.

- `android/app/build.gradle.kts` reads signing from `android/key.properties` (local) or env vars `ANDROID_KEYSTORE_PATH/PASSWORD`, `ANDROID_KEY_ALIAS/PASSWORD` (CI). Falls back to debug signing when neither is present.
- **Never commit**: `*.keystore`, `*.jks`, `key.properties` (all git-ignored).
- CI signing comes from GitHub repo secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. The workflow base64-decodes the keystore to `android/app/release.keystore` at build time.
- **The keystore is irreplaceable** — losing it means testers must uninstall to update. Keep a secure backup.
- iOS: not built yet (requires macOS + Xcode). Future: TestFlight (beta) → App Store (prod). Android future prod path: Play Store via appbundle.

Branding assets in `assets/logo/`: `app_icon.png` (symbol-only, white bg → launcher icon), `listai-logo-removebg.png` (transparent → splash + welcome screen).

## Observability

- **Sentry** — production error capture.
- **PostHog** or **Mixpanel** — opt-in usage analytics.
- Structured logging via `logger` — dev/staging only, never production without opt-in.
