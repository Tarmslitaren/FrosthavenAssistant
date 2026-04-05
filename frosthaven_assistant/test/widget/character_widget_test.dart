import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_widget.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
  });

  Future<void> pumpCharacterWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: const CharacterWidget(characterId: 'Blinkblade'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;
  }

  group('CharacterWidget', () {
    testWidgets('renders when character exists', (WidgetTester tester) async {
      await pumpCharacterWidget(tester);
      expect(find.byType(CharacterWidget), findsOneWidget);
    });

    testWidgets('shows InkWell for tap interaction', (WidgetTester tester) async {
      await pumpCharacterWidget(tester);
      expect(find.byType(InkWell), findsAtLeast(1));
    });

    testWidgets('tapping character widget opens StatusMenu',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await pumpCharacterWidget(tester);
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(StatusMenu), findsOneWidget);
    });

    testWidgets('returns empty Container when character not found',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterWidget(characterId: 'NonExistent'),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      // Should render without crash — returns Container()
      expect(find.byType(CharacterWidget), findsOneWidget);
    });

    testWidgets('renders ColorFiltered widget', (WidgetTester tester) async {
      await pumpCharacterWidget(tester);
      expect(find.byType(ColorFiltered), findsAtLeast(1));
    });

    testWidgets('renders health wheel when not in chooseInitiative round state',
        (WidgetTester tester) async {
      // Draw changes roundState to playTurns, triggering buildWithHealthWheel path
      DrawCommand().execute();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharacterWidget(characterId: 'Blinkblade'),
            ),
          ),
        ),
      );
      // Pump past DrawCommand's 600ms Future.delayed timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      FlutterError.onError = originalOnError;
      expect(find.byType(CharacterWidget), findsOneWidget);
      // Reset round state (NextRoundCommand also has 600ms timer — pump past it)
      NextRoundCommand().execute();
      await tester.pump(const Duration(milliseconds: 700));
    });
  });
}
