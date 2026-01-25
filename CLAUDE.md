# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenLocalUI is a Flutter desktop application for running LLMs locally via Ollama. It targets Windows, macOS, and Linux platforms. The main Flutter app resides in the `app/` directory.

## Development Commands

All commands should be run from the `app/` directory:

```bash
# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Static analysis
flutter analyze

# Format code
dart format .

# Generate code (Freezed, JSON serializable, envied)
dart run build_runner build

# Generate localization files
# Windows: powershell ../scripts/generate_intl_files.ps1
# Linux/macOS: bash ../scripts/generate_intl_files.sh

# Build release
# Windows: powershell ../scripts/build_app.ps1 -config release
# Linux/macOS: bash ../scripts/build_app.sh release
```

## Prerequisites

- Flutter SDK (>=3.9.0)
- Ollama client with at least one model
- Vulkan SDK (required by gpu_info package)

## Architecture

### Directory Structure (app/lib/)

```
bootstrap/           # App initialization, DI setup, environment config
core/
  ├── constants/     # App-wide constants (assets, languages, styles)
  ├── models/        # Data models (chat_session, chat_message, model)
  ├── providers/     # State management (ChangeNotifier-based)
  ├── repositories/  # Data persistence (Hive, SQLite)
  ├── services/      # Business logic services (TTS)
  ├── utils/         # Utility functions
  ├── helpers/       # Helper functions
  └── extensions/    # Dart extensions
design/
  ├── tokens/        # Design tokens (colors, typography, spacing, radii)
  └── theme/         # Material 3 theme configuration
features/            # Feature modules (Clean Architecture pattern)
  ├── chat/          # Main chat feature
  ├── onboarding/    # Splash & onboarding screens
  ├── settings/      # App settings
  ├── sessions/      # Chat session management
  ├── dashboard/     # Dashboard/home
  ├── sidebar/       # Sidebar navigation
  ├── market/        # Model marketplace
  └── inventory/     # Local model management
shared/              # Shared widgets and dialogs
localization/        # Generated i18n files (13+ languages)
src/rust/            # Rust FFI bindings (flutter_rust_bridge)
```

### Key Patterns

**State Management**: Provider + ChangeNotifier pattern

- `ChatProvider` - Chat sessions, messages, LLM interactions via LangChain
- `OllamaAPIProvider` - Ollama model operations
- `LocaleProvider` - Language/locale management
- `ModelSettingsProvider` - Per-model configuration

**Dependency Injection**: GetIt service locator, initialized in `AppBootstrap._setupDependencyInjection()`

**Data Persistence**:

- Hive - Chat sessions stored in `{appSupportDir}/sessions/`
- SharedPreferences - User settings
- SQLite - Ollama models database

**LLM Integration**: LangChain Dart (`langchain`, `langchain_ollama`) for building chat chains with memory, streaming responses, and multimodal support

**Feature Structure**: Each feature follows:

```
feature/
└── presentation/
    ├── screens/    # Full-screen widgets
    ├── widgets/    # Feature widgets
    └── dialogs/    # Feature dialogs
```

### Bootstrap Flow

`main.dart` → `AppBootstrap.create()` → DI setup → Service initialization (Ollama, Hive, Supabase) → Asset preloading → `OpenLocalUIApp` → SplashScreen → OnboardingScreen → ChatScreen

### Code Generation

The project uses several code generators:

- **Freezed** - Immutable data classes
- **json_serializable** - JSON serialization
- **envied** - Environment variable access (env.dart → env.g.dart)

Run `dart run build_runner build` after modifying models or adding environment variables.

### Localization

ARB files are in `app/assets/i18n/`. After editing translations, run the intl generation script. The template file is `intl_en.arb`.

## Branching

Uses GitHub Flow: feature branches off `main`, merge via pull request. Branch naming: `feat/description` or `fix/description`.
