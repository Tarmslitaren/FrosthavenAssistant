import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_widget.dart';
import 'package:frosthaven_assistant/Layout/background.dart';
import 'package:frosthaven_assistant/Layout/main_list.dart';
import 'package:frosthaven_assistant/Layout/monster_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MainList(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('MainList', () {
    testWidgets('renders BackGround widget', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(BackGround), findsOneWidget);
    });

    testWidgets('renders Scrollbar', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('renders SingleChildScrollView', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(SingleChildScrollView), findsAtLeast(1));
    });

    testWidgets('renders empty list without crashing when no items',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(MainList), findsOneWidget);
      expect(find.byType(CharacterWidget), findsNothing);
      expect(find.byType(MonsterWidget), findsNothing);
    });

    testWidgets('renders CharacterWidget when a character is added',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      await pumpWidget(tester);
      expect(find.byType(CharacterWidget), findsOneWidget);
    });

    testWidgets('renders MonsterWidget when a monster is added',
        (WidgetTester tester) async {
      AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>()).execute();
      await pumpWidget(tester);
      expect(find.byType(MonsterWidget), findsOneWidget);
    });

    testWidgets('renders both CharacterWidget and MonsterWidget together',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>()).execute();
      await pumpWidget(tester);
      expect(find.byType(CharacterWidget), findsOneWidget);
      expect(find.byType(MonsterWidget), findsOneWidget);
    });

    testWidgets('renders Item wrapper for each list element',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      await pumpWidget(tester);
      expect(find.byType(Item), findsAtLeast(1));
    });

    testWidgets('scrollToTop does not crash when called with no clients',
        (WidgetTester tester) async {
      // Before any widget is pumped, scrollController has no clients
      MainList.scrollToTop();
      await pumpWidget(tester);
      MainList.scrollToTop(); // After pumping, has a client
    });
  });

  group('Item widget', () {
    testWidgets('wraps CharacterWidget in AnimatedContainer',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
      final character = getIt<GameState>().currentList
          .firstWhere((e) => e is Character) as Character;
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Item(data: character)),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(CharacterWidget), findsOneWidget);
    });

    testWidgets('wraps MonsterWidget in AnimatedContainer',
        (WidgetTester tester) async {
      AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>()).execute();
      final monster = getIt<GameState>().currentList
          .firstWhere((e) => e is Monster) as Monster;
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Item(data: monster)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      FlutterError.onError = originalOnError;
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(MonsterWidget), findsOneWidget);
    });
  });
}
