import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/stat_card_zoom.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false, gameState: getIt<GameState>()).execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
  });

  Future<void> pumpStatCardZoom(WidgetTester tester, Monster m) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Material(child: StatCardZoom(monster: m)),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  group('StatCardZoom', () {
    testWidgets('renders the monster stat card', (WidgetTester tester) async {
      await pumpStatCardZoom(tester, monster);

      expect(find.byType(StatCardZoom), findsOneWidget);
    });

    testWidgets('tapping dismisses the dialog', (WidgetTester tester) async {
      await pumpStatCardZoom(tester, monster);
      expect(find.byType(StatCardZoom), findsOneWidget);

      // InkWell needs a Material ancestor; tap the InkWell directly
      await tester.tap(find.byType(InkWell).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(StatCardZoom), findsNothing);
    });
  });
}
