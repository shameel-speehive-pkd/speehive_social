# AGENTS.md

## Quick Commands

```bash
flutter run                    # Run app on connected device
flutter analyze                # Lint check (no separate lint command)
flutter test                   # Run tests
flutter pub get                # Install dependencies after pubspec changes
```

No separate typecheck command — `flutter analyze` covers both.

## Architecture

Clean Architecture with Riverpod DI:

```
lib/
├── core/           # Constants, DI providers, errors, services, themes, utils
├── data/           # Datasources (outlook/, google/, linkedin/, auth/, local/), models, repositories
├── domain/         # Entities, repository abstractions, tools (AI tool definitions), usecases
├── presentation/   # UI: chat/, home/, settings/, social/
└── main.dart       # Entry point — loads .env, initializes providers
```

Key wiring: `lib/core/di/providers.dart` defines all Riverpod providers. `main.dart` calls `initProviders()` and wraps app in `UncontrolledProviderScope`.

## Environment

- `.env` file is required (loaded via `flutter_dotenv` in main.dart)
- See `.env.example` for all required keys
- `.env` is bundled as a Flutter asset — must be listed under `flutter.assets` in pubspec.yaml

## AI Integration

Uses `ai_sdk_dart` (Vercel AI SDK Dart port) for tool-calling chat:
- Tools defined in `lib/domain/tools/social_tools.dart`
- Repository implementation in `lib/data/repositories/chat_repository_impl.dart`
- `streamResponseWithToolCalls()` captures tool calls via `onStepFinish` callback
- Tool calls displayed in UI via `chat_message_bubble.dart` `_buildToolCalls()` method

## Calendar Integration

Two calendar providers with fallback logic:
- **Google Calendar** (primary) — `lib/data/datasources/google/`
- **Microsoft Outlook** (fallback) — `lib/data/datasources/outlook/`
- Tools try Google first, fall back to Outlook if Google fails

Google Sign-In requires **two** OAuth client IDs:
- `GOOGLE_CLIENT_ID` — Android/iOS client (from Google Cloud Console)
- `GOOGLE_WEB_CLIENT_ID` — Web client (required by google_sign_in v7.x on Android)

## Package Name

`com.example.speehive_social` (in `android/app/build.gradle.kts`)

## Conventions

- No comments unless asked
- Use `flutter_lints` rules (default analysis_options.yaml)
- State management: Riverpod (`flutter_riverpod`)
- Secure storage: `flutter_secure_storage` with encrypted shared preferences on Android
- Models use `fromJson()` factory constructors; entities are pure Dart classes with `Equatable`
