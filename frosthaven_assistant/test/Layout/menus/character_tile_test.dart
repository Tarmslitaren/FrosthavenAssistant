import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:frosthaven_assistant/Layout/menus/character_tile.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:built_collection/built_collection.dart';

class MockGameState extends Mock implements GameState {
  @override
  BuiltSet<String> get unlockedClasses => super.noSuchMethod(
        Invocation.getter(#unlockedClasses),
        returnValue: BuiltSet<String>(),
        returnValueForMissingStub: BuiltSet<String>(),
      );
}

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Material(
      child: child,
    ),
  );
}

CharacterClass getTestCharacter({String name = 'CORE', bool hidden = false}) {
  return CharacterClass(
    'CORE', //id
    'CORE', // name
    const [10, 20, 30], // healthByLevel
    'First', // edition
    Colors.blue, // color
    Colors.blueAccent, // colorSecondary
    hidden, // hidden
    const [], // summons
  );
}

void main() {
  final getIt = GetIt.instance;
  late MockGameState mockGameState;

  setUp(() {
    mockGameState = MockGameState();
    getIt.registerSingleton<GameState>(mockGameState);
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('CharacterTile displays character name and image correctly',
      (WidgetTester tester) async {
    CharacterClass character = getTestCharacter();

    await tester.pumpWidget(buildTestWidget(
      CharacterTile(
        character: character,
        onSelect: (CharacterClass character) {},
      ),
    ));

    expect(find.text(character.name), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('CharacterTile handles onTap correctly when not disabled',
      (WidgetTester tester) async {
    CharacterClass character = getTestCharacter();

    bool isSelected = false;

    await tester.pumpWidget(
      buildTestWidget(
        CharacterTile(
          character: character,
          onSelect: (CharacterClass character) {
            isSelected = true;
          },
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(isSelected, true);
  });

  testWidgets('CharacterTile does not run onTap when disabled',
      (WidgetTester tester) async {
    CharacterClass character = getTestCharacter();

    bool isSelected = false;

    await tester.pumpWidget(
      buildTestWidget(
        CharacterTile(
          character: character,
          onSelect: (CharacterClass character) {
            isSelected = true;
          },
          disabled: true,
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(isSelected, false);
  });

  testWidgets('CharacterTile shows ??? for hidden characters when not unlocked',
      (WidgetTester tester) async {
    CharacterClass character = getTestCharacter(hidden: true);

    final characterNames = BuiltSet<String>([]);

    when(mockGameState.unlockedClasses).thenReturn(characterNames);

    await tester.pumpWidget(
      buildTestWidget(
        CharacterTile(
          character: character,
          onSelect: (CharacterClass character) {},
        ),
      ),
    );

    expect(find.text('???'), findsOneWidget);
  });

  testWidgets('CharacterTile shows character name when unlocked',
      (WidgetTester tester) async {
    CharacterClass character = getTestCharacter();

    final characterNames = BuiltSet<String>([character.name]);

    when(mockGameState.unlockedClasses).thenReturn(characterNames);

    await tester.pumpWidget(
      buildTestWidget(
        CharacterTile(
          character: character,
          onSelect: (CharacterClass character) {},
        ),
      ),
    );

    expect(find.text(character.name), findsOneWidget);
  });

  testWidgets(
      'CharacterTile does not change color for objective and escort characters',
      (WidgetTester tester) async {
    CharacterClass objectiveCharacter = getTestCharacter(name: 'Objective');
    CharacterClass excortCharacter = getTestCharacter(name: 'Escort');

    await tester.pumpWidget(
      buildTestWidget(
        Column(
          children: [
            CharacterTile(
              character: objectiveCharacter,
              onSelect: (CharacterClass character) {},
            ),
            CharacterTile(
              character: excortCharacter,
              onSelect: (CharacterClass character) {},
            ),
          ],
        ),
      ),
    );

    final objectiveImage = tester.widget<Image>(find.byType(Image).at(0));
    final escortImage = tester.widget<Image>(find.byType(Image).at(1));

    expect(objectiveImage.color, objectiveCharacter.color);
    expect(escortImage.color, excortCharacter.color);
  });
}
