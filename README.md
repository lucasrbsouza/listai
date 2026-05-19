# Listaí

Flutter supermarket shopping management app. Offline-first, with AI nutritionist chat and analytics.

## Requirements

- Flutter 3.32+ (managed via FVM)
- Dart 3.8+
- Android SDK / Xcode (for device builds)

## Setup

```bash
# Install FVM globally (requires Dart)
dart pub global activate fvm

# Pin Flutter version for this project
fvm use 3.32.1

# Install dependencies
fvm flutter pub get

# Generate Drift DB code (after schema changes)
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Generate l10n
fvm flutter gen-l10n
```

## Running

```bash
fvm flutter run
```

## Testing

```bash
# All tests
fvm flutter test

# Single file
fvm flutter test test/unit/domain/shopping_item_test.dart

# Widget tests
fvm flutter test test/widget/

# Integration tests
fvm flutter test test/integration/
```

## Analyzing

```bash
fvm flutter analyze
dart format --set-exit-if-changed .
```

## Build

```bash
fvm flutter build apk           # Android debug
fvm flutter build appbundle     # Android release
fvm flutter build ios           # iOS release
```

## Architecture

Clean Architecture — 3 layers per feature under `lib/features/<feature>/`:

- `presentation/` — screens, widgets, Riverpod providers
- `domain/` — entities, use cases, repository interfaces (pure Dart)
- `data/` — repository implementations, Drift datasource, Supabase datasource

Cross-cutting utilities under `lib/core/`. Shared widgets under `lib/shared/`.

## Bundle ID

`com.listai.app`
