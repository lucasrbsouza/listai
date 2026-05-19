# Listaí — Agent Instructions

## Project State

**This repo is pre-code.** Only design documents exist. Do not write Flutter code without explicit user request — implement from the spec-driven prompts in `03-prompts-spec-driven.md`.

## Stack

- Flutter 3.x, Dart, Riverpod, GoRouter, Drift (SQLite), Supabase
- Clean Architecture: `domain/` (pure Dart), `data/`, `presentation/`
- Feature-based folders under `lib/features/`
- Money stored as cents (int), never double

## SDD + TDD Workflow

Follow `03-prompts-spec-driven.md` strictly:
1. Write failing tests FIRST (Red) — minimum cases per spec step
2. Implement to pass (Green)
3. Refactor if needed
4. Run all tests before declaring step done

## Command Order

```bash
flutter pub get
flutter analyze
flutter test
flutter test --machine  # for CI
```

## Important Conventions

- **TDD mandatory**: never write implementation before its tests
- **Red → Green → Refactor**: confirm tests fail before coding
- **Security as first-class citizen**: sanitize all inputs, validate client+server, RLS on all Supabase tables, keys in `flutter_secure_storage`
- **Immutability**: domain entities use `copyWith`, no mutable state in domain
- **No hardcoded strings**: use `AppLocalizations` (.arb files)
- Money = `Money.fromCents(int)`, never `double` for currency
- Quantity = `double` with up to 3 decimal places for KG support
- AI providers: abstract `AIProvider` interface, never couple to specific API in domain layer

## Phases

| Phase | Focus |
|---|---|
| 0 | Setup (project init, structure, dependencies) |
| 1 | Domain (pure Dart — entities, use cases, repository interfaces) |
| 2 | Persistence (Drift + local repository) |
| 3 | UI (providers, screens, routing) |
| 4 | Features (photo, substitute, budget, undo) |
| 5 | Backend (Supabase + Auth + Sync) |
| 6 | Analytics (charts, heatmap) |
| 7 | Export (PDF, TXT, DOCX, PPTX) |
| 8 | AI Chat (configurable providers) |
| 9 | Polish (i18n, themes, accessibility) |

Do not skip phases — later phases depend on earlier ones.

## Sync Strategy

Offline-first: Drift is local source of truth. `SyncManager` reconciles with Supabase on connectivity. Local → cloud migration requires explicit user confirmation.

## Test Coverage Targets

- Domain layer: ≥90% (use cases, entities, calculations)
- Widget tests: ≥70% on critical widgets
- Golden tests: main screens in both light/dark themes

## Secrets

Never hardcode API keys, ANON_KEY, or credentials. Use `--dart-define` or `flutter_dotenv`. Exclude `.env`, `*.keystore`, `GoogleService-Info.plist` from version control via `.gitignore`.

## Reference

- `01-ideia-do-projeto.md` — feature spec
- `02-arquitetura.md` — full technical architecture
- `03-prompts-spec-driven.md` — step-by-step implementation prompts (30+ steps)