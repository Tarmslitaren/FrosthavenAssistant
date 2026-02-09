# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Frosthaven Assistant is a Flutter-based companion app for Frosthaven and Gloomhaven board games. It manages game state, monster abilities, character tracking, modifier decks, loot decks, and supports multiplayer via network synchronization.

## Common Commands

### Development
```bash
flutter run                    # Run the app
flutter doctor                 # Check Flutter installation and dependencies
```

### Testing
```bash
dart run build_runner build    # Generate .mocks.dart files (REQUIRED before testing)
flutter test                   # Run all unit tests
flutter test test/path/to/test_file.dart  # Run a specific test file
```

If `build_runner` encounters errors, try:
```bash
dart pub upgrade               # Update dependencies
dart run build_runner build    # Retry generating mocks
```

### Analysis
```bash
flutter analyze                # Run static analysis with dart_code_metrics rules
```

### Building
```bash
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app
flutter build windows          # Build Windows desktop app
flutter build web              # Build web app
```

## Architecture

### Core Architectural Pattern: Command Pattern + ValueNotifier

This app uses a sophisticated hybrid state management approach:

1. **Command Pattern** for all state mutations
   - All changes go through `Command` objects in `lib/Resource/commands/`
   - Each command implements `execute()`, `undo()`, and `describe()`
   - 70+ command classes for different operations (AddMonsterCommand, ChangeHealthCommand, etc.)
   - Commands use `_StateModifier` token pattern to enforce single mutation path

2. **ValueNotifier** for reactive UI updates
   - State exposed via `ValueListenable<T>` getters
   - UI rebuilds with `ValueListenableBuilder` widgets
   - 92+ ValueNotifier instances across core state classes

3. **ActionHandler** for undo/redo
   - Manages command history (250 levels deep)
   - Stores `GameSaveState` snapshots for each action
   - Network-aware: syncs state across server/client

### Directory Structure

```
lib/
├── main.dart                    # Entry point, initializes GetIt, loads game data
├── main_state.dart             # Root state management
├── Layout/                     # Presentation layer (75+ widget files)
│   ├── CharacterWidget/        # Character-specific UI (9 files)
│   ├── menus/                  # Menu dialogs and overlays (39 files)
│   ├── main_scaffold.dart      # App scaffold structure
│   ├── top_bar.dart            # Top navigation bar
│   └── theme.dart              # Theme definitions
├── Model/                      # Immutable data models (7 files)
│   ├── campaign.dart           # Campaign data structure
│   ├── character_class.dart    # Character class definitions
│   ├── monster.dart            # Monster data model
│   └── ...
├── Resource/                   # Business logic layer
│   ├── state/                  # State classes (12 files)
│   │   ├── game_state.dart     # Central game state (uses part files)
│   │   ├── character_state.dart
│   │   ├── modifier_deck.dart
│   │   └── ...
│   ├── commands/               # Command pattern (70+ files)
│   │   ├── change_stat_commands/
│   │   ├── add_*.dart
│   │   ├── remove_*.dart
│   │   └── ...
│   ├── action_handler.dart     # Undo/redo system
│   ├── game_data.dart          # Game data loader (repository pattern)
│   ├── game_methods.dart       # Read-only game logic helpers
│   ├── mutable_game_methods.dart  # Mutation methods (via commands only)
│   └── settings.dart           # App settings (28 ValueNotifiers)
└── services/                   # External services
    ├── service_locator.dart    # GetIt dependency injection setup
    └── network/                # Network services for multiplayer (7 files)
```

### Key Design Patterns

1. **Service Locator (GetIt)**
   - Global singleton instances: `GameData`, `Settings`, `GameState`, `Network`, etc.
   - Access via `getIt<ClassName>()`
   - Initialized in `main.dart` via `setupGetIt()`

2. **Part Files**
   - `GameState` splits into 10+ part files for organization
   - Example: `game_state.dart` includes `character.dart`, `modifier_deck.dart`, etc.
   - All parts use `part of` directive

3. **Immutability with built_collection**
   - Models are immutable and JSON-serializable
   - State uses private mutable fields (`_currentList`) exposed as `BuiltList` via getters
   - Prevents accidental mutations

4. **Repository Pattern**
   - `GameData` class loads and caches campaign data from JSON assets
   - `assets/data/` contains campaign definitions, monsters, abilities, scenarios

5. **State Token Pattern**
   - `_StateModifier` private class acts as capability token
   - Only Command objects can access mutation methods
   - Enforces controlled state changes

### State Management Details

**GameState** is the central state holder:
- Current campaign, scenario, round, level
- List of monsters and characters (`_currentList`)
- Element states (fire, ice, earth, etc.)
- Modifier deck, loot deck, sanctuary deck
- Exposed via ValueListenable getters

**Settings** manages user preferences:
- 28 ValueNotifiers for various settings
- Persisted via `shared_preferences` package
- Controls UI behavior, sound, network options

**Multiplayer Architecture**:
- Server/client model in `lib/services/network/`
- State synchronized via command broadcasting
- `Communication` class handles message passing
- `Connection` manages active connections

### Testing Architecture

- Uses **mockito** for mocking dependencies
- Requires running `dart run build_runner build` to generate `.mocks.dart` files
- Test structure mirrors `lib/` structure
- Tests organized in: `test/command/`, `test/Layout/`, `test/resource/`, etc.

## Important Conventions

### Making State Changes

**ALWAYS use Commands** - never mutate state directly:

```dart
// CORRECT
getIt<GameState>().action(AddMonsterCommand(...));

// WRONG - never call mutation methods directly
gameState.addMonster(...);  // This won't work - mutation methods require _StateModifier token
```

### Accessing State

Use ValueListenableBuilder for reactive UI:

```dart
ValueListenableBuilder<int>(
  valueListenable: getIt<GameState>().roundState,
  builder: (context, round, child) {
    return Text('Round: $round');
  },
)
```

### Adding New Commands

1. Create command class in `lib/Resource/commands/`
2. Extend `Command` abstract class
3. Implement: `execute()`, `undo()`, `describe()`
4. Use `_StateModifier` parameter for mutation methods
5. Execute via `GameState.action(yourCommand)`

### Code Style

- Uses **dart_code_metrics** with strict rules (see `analysis_options.yaml`)
- Run `flutter analyze` to check for violations
- Key rules enforced:
  - Avoid dynamic types
  - Avoid late keyword
  - Avoid non-null assertions (!)
  - Member ordering (fields, constructors, methods)
  - No magic numbers (disabled temporarily)
  - Prefer const constructors where possible

### Performance Optimization

- Extensive use of `RepaintBoundary` widgets
- Conditional widget rebuilds with ValueListenableBuilder
- Immutable data structures prevent unnecessary comparisons

## Data Files

Game data loaded from `assets/data/`:
- `editions/` - Campaign-specific data (Frosthaven, Gloomhaven, etc.)
- `rooms/` - Room layout definitions
- JSON files parsed into Model classes via `GameData.loadData()`

Test data available in `assets/testData/` with same structure.

## Platform-Specific Features

- **Desktop (Windows/Linux/macOS)**: Window size management, fullscreen support
- **Mobile (iOS/Android)**: Wakelock, network info, connectivity monitoring
- **Web**: Full support with responsive framework
- **Cross-platform**: Keyboard visibility tracking, URL launching

## Network/Multiplayer

- Server can host game state
- Clients connect and sync state via commands
- All state changes broadcast to connected clients
- Uses custom protocol in `frosthaven_assistant_server` package (local path dependency)

## Version Management

Version defined in `pubspec.yaml`:
```yaml
version: 1.13.7+57  # Format: major.minor.patch+build
```

Icons and splash screens configured via:
- `flutter_launcher_icons` package
- `flutter_native_splash` package
