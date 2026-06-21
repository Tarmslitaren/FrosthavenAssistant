import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/widgets/scrollable_menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/game_methods.dart';
import '../../services/service_locator.dart';
import '../../services/translation_service.dart';

class CharacterLootMenu extends StatefulWidget {
  const CharacterLootMenu({super.key, this.gameState});

  final GameState? gameState;

  @override
  CharacterLootMenuState createState() => CharacterLootMenuState();
}

class CharacterLootMenuState extends State<CharacterLootMenu> {
  static const int _kCoinValue3 = 3;
  static const int _kCoinValue2 = 2;
  static const List<String> _kLootNames = [
    "coin",
    "hide",
    "lumber",
    "metal",
    "arrowvine",
    "axenut",
    "corpsecap",
    "flamefruit",
    "rockroot",
    "snowthistle",
  ];

  late final GameState _gameState;

  @override
  void initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Character> characters = GameMethods.getCurrentCharacters();

    return ScrollableMenuCard(
      child: Column(
        children: [
          for (Character character in characters)
            _CharacterLootWidget(
                characterId: character.characterClass.id,
                characterName: getIt<TranslationService>().t(character.characterState.display.value),
                gameState: _gameState),
        ],
      ),
    );
  }
}

class _CharacterLootWidget extends StatelessWidget {
  const _CharacterLootWidget({
    required this.characterId,
    required this.characterName,
    required this.gameState,
  });

  final String characterId;
  final String characterName;
  final GameState gameState;

  static const double _kCharIconSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: kMenuNarrowWidth),
      child: Column(children: [
        const Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image(
                filterQuality: FilterQuality.medium,
                height: kIconSize,
                width: kIconSize,
                fit: BoxFit.contain,
                image: AssetImage("assets/images/class-icons/$characterId.png"),
              ),
              const SizedBox(width: _kCharIconSpacing),
              Text(
                "$characterName's loot:",
                style: kTitleStyle,
              )
            ]),
        ...CharacterLootMenuState._kLootNames.map((name) => _LootListTile(
            lootName: name, characterId: characterId, gameState: gameState)),
      ]),
    );
  }
}

class _LootListTile extends StatelessWidget {
  const _LootListTile({
    required this.lootName,
    required this.characterId,
    required this.gameState,
  });

  final String lootName;
  final String characterId;
  final GameState gameState;

  static const double _kContentPaddingLeft = 14.0;
  static const double _kHorizontalTitleGap = 6.0;
  static const double _kTrailingPaddingRight = 16.0;

  int _getLootAmount() {
    int value = 0;
    for (final item in gameState.lootDeck.discardPileContents) {
      if (item.owner == characterId && item.gfx.contains(lootName)) {
        if (lootName == "coin") {
          if (item.gfx.endsWith("3")) {
            value += CharacterLootMenuState._kCoinValue3;
          } else if (item.gfx.endsWith("2")) {
            value += CharacterLootMenuState._kCoinValue2;
          } else {
            value += 1;
          }
          value += item.enhanced;
        } else {
          final itemValue = item.getValue();
          if (itemValue != null) {
            value += itemValue;
          }
        }
      }
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    int amount = _getLootAmount();
    if (amount == 0) {
      return Container();
    }
    return ListTile(
        contentPadding: const EdgeInsets.only(left: _kContentPaddingLeft),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        horizontalTitleGap: _kHorizontalTitleGap,
        leading: Image(
          filterQuality: FilterQuality.medium,
          height: kIconSize,
          width: kIconSize,
          fit: BoxFit.contain,
          image: AssetImage("assets/images/loot/${lootName}_icon.png"),
        ),
        title: Text(
          lootName,
          overflow: TextOverflow.visible,
          maxLines: 1,
        ),
        trailing: Container(
            padding: const EdgeInsets.only(right: _kTrailingPaddingRight),
            child: Text(
              "$amount",
              style: kHeadingStyle,
            )));
  }
}
