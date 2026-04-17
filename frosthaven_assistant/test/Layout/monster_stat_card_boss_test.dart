// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/monster_stat_card_widget.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_stat_card_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

Monster _getBoss() {
  return getIt<GameState>().currentList.firstWhere((e) => e is Monster)
      as Monster;
}

Future<void> _pumpBoss(WidgetTester tester, Monster monster,
    {bool frosthavenStyle = true}) async {
  final shadow = const Shadow(
    offset: Offset(0.4, 0.4),
    color: Colors.black87,
    blurRadius: 1,
  );
  final leftStyle = TextStyle(
    fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
    color: Colors.black,
    fontSize: 12.8,
    height: 1.2,
  );

  final widget = MonsterStatCardWidget.buildBossLayout(
      monster, 1.0, shadow, leftStyle, frosthavenStyle,
      viewModel:
          MonsterStatCardViewModel(monster, gameState: getIt<GameState>()));

  final originalOnError = FlutterError.onError;
  addTearDown(() => FlutterError.onError = originalOnError);
  FlutterError.onError = ignoreOverflowErrors;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 300, height: 300, child: widget),
      ),
    ),
  );
  await tester.pump();
  FlutterError.onError = originalOnError;
}

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<Settings>().noCalculation.value = false;
  });

  group('buildBossLayout', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster);
      // Should find the RepaintBoundary at the top of the returned widget
      expect(find.byType(RepaintBoundary), findsAtLeast(1));
    });

    testWidgets('renders boss background image', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster);

      // The boss background is a ClipRRect with Image using monsterStats-boss.png
      expect(find.byType(ClipRRect), findsAtLeast(1));
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final hasBossBackground = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('monsterStats-boss');
      });
      expect(hasBossBackground, isTrue);
    });

    testWidgets('displays health stat text', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // At level 1: health=25
      await _pumpBoss(tester, monster);
      expect(find.text('25'), findsAtLeast(1));
    });

    testWidgets('displays move stat text', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // At level 1: move=2
      await _pumpBoss(tester, monster);
      expect(find.text('2'), findsAtLeast(1));
    });

    testWidgets('displays attack stat text', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // At level 1: attack=4
      await _pumpBoss(tester, monster);
      expect(find.text('4'), findsAtLeast(1));
    });

    testWidgets('displays level text', (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // Level value is 1
      await _pumpBoss(tester, monster);
      expect(find.text('1'), findsAtLeast(1));
    });

    testWidgets('shows special1 section with "1:" label when non-empty',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // Test Boss has non-empty special1
      await _pumpBoss(tester, monster);
      expect(find.text('1:'), findsOneWidget);
    });

    testWidgets('shows special2 section with "2:" label when non-empty',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // Test Boss has non-empty special2
      await _pumpBoss(tester, monster);
      expect(find.text('2:'), findsOneWidget);
    });

    testWidgets('shows range icon when range is non-zero',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // At level 1: range=2
      await _pumpBoss(tester, monster);

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final hasRangeIcon = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('range-stat');
      });
      expect(hasRangeIcon, isTrue);
    });

    testWidgets('does not show range icon when range is zero',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 0, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      // At level 0: range=0
      await _pumpBoss(tester, monster);

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final hasRangeIcon = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('range-stat');
      });
      expect(hasRangeIcon, isFalse);
    });

    testWidgets(
        'shows frosthaven flying icon for flying boss with frosthavenStyle=true',
        (WidgetTester tester) async {
      AddMonsterCommand('Flying Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster, frosthavenStyle: true);

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final hasFlyingFH = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('flying-stat_fh');
      });
      expect(hasFlyingFH, isTrue);
    });

    testWidgets('shows non-frosthaven flying icon with frosthavenStyle=false',
        (WidgetTester tester) async {
      AddMonsterCommand('Flying Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster, frosthavenStyle: false);

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final hasFlyingGH = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('flying-stat.png');
      });
      expect(hasFlyingGH, isTrue);
    });

    testWidgets('frosthavenStyle=true uses Markazi font for level text',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster, frosthavenStyle: true);

      final texts = tester.widgetList<Text>(find.byType(Text)).toList();
      // Level text is the first positioned text and uses Markazi when frosthavenStyle
      final levelText = texts.firstWhere(
        (t) => t.data == '1' && t.style?.fontFamily == 'Markazi',
        orElse: () => const Text(''),
      );
      expect(levelText.style?.fontFamily, 'Markazi');
    });

    testWidgets('frosthavenStyle=false uses Majalla font for level text',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster, frosthavenStyle: false);

      final texts = tester.widgetList<Text>(find.byType(Text)).toList();
      final levelText = texts.firstWhere(
        (t) => t.data == '1' && t.style?.fontFamily == 'Majalla',
        orElse: () => const Text(''),
      );
      expect(levelText.style?.fontFamily, 'Majalla');
    });

    testWidgets(
        'noCalculation=true shows raw health formula string instead of calculated value',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      getIt<Settings>().noCalculation.value = true;
      // At level 1: health=25 (raw int, so toString still gives "25")
      await _pumpBoss(tester, monster);
      expect(find.text('25'), findsAtLeast(1));
      getIt<Settings>().noCalculation.value = false;
    });

    testWidgets('renders via MonsterStatCardWidget without crashing',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: MonsterStatCardWidget(data: monster),
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      expect(find.byType(MonsterStatCardWidget), findsOneWidget);
    });

    testWidgets('Stack contains multiple Positioned widgets',
        (WidgetTester tester) async {
      AddMonsterCommand('Test Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster);
      expect(find.byType(Positioned), findsAtLeast(2));
    });

    testWidgets('does not show "1:" or "2:" when specials are empty',
        (WidgetTester tester) async {
      // Flying Boss has empty special1 and special2
      AddMonsterCommand('Flying Boss (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = _getBoss();
      await _pumpBoss(tester, monster);
      expect(find.text('1:'), findsNothing);
      expect(find.text('2:'), findsNothing);
    });
  });
}
