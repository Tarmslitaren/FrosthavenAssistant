import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/game_methods.dart';
import '../../services/service_locator.dart';

class CharacterLootMenu extends StatefulWidget {
  const CharacterLootMenu({super.key});

  @override
  CharacterLootMenuState createState() => CharacterLootMenuState();
}

class CharacterLootMenuState extends State<CharacterLootMenu> {
  static const int _kCoinValue3 = 3;
  static const int _kCoinValue2 = 2;
  static const double _kIconSize = 30.0;
  static const double _kContentPaddingLeft = 14.0;
  static const double _kHorizontalTitleGap = 6.0;
  static const double _kTrailingPaddingRight = 16.0;
  static const double _kMaxWidth = 300.0;
  static const double _kCharIconSpacing = 10.0;
  static const double _kTopSpacing = 20.0;
  static const List<String> _kLootNames = [
    "coin", "hide", "lumber", "metal", "arrowvine", "axenut",
    "corpsecap", "flamefruit", "rockroot", "snowthistle",
  ];

  late final GameState _gameState;

  @override
  initState() {
    _gameState = getIt<GameState>();
    super.initState();
  }

  int getLootAmount(String characterId, String lootName) {
    int value = 0;
    for (var item in _gameState.lootDeck.discardPileContents) {
      if (item.owner == characterId && item.gfx.contains(lootName)) {
        if (lootName == "coin") {
          if (item.gfx.endsWith("3")) {
            value += _kCoinValue3;
          } else if (item.gfx.endsWith("2")) {
            value += _kCoinValue2;
          } else {
            value += 1;
          }
          value += item.enhanced;
        } else {
          var itemValue = item.getValue();
          if (itemValue != null) {
            value += itemValue;
          }
        }
      }
    }
    return value;
  }

  Widget createListTile(String lootName, String characterId) {
    int amount = getLootAmount(characterId, lootName);
    if (amount == 0) {
      return Container();
    }
    ListTile listTile = ListTile(
        contentPadding: const EdgeInsets.only(left: _kContentPaddingLeft),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        horizontalTitleGap: _kHorizontalTitleGap,
        leading: Image(
          filterQuality: FilterQuality.medium,
          height: _kIconSize,
          width: _kIconSize,
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

    return listTile;
  }

  Widget buildCharacterLootWidget(String characterId, String characterName) {
    return Container(
      constraints: const BoxConstraints(maxWidth: _kMaxWidth),
      child: Column(children: [
        const Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image(
                filterQuality: FilterQuality.medium,
                height: _kIconSize,
                width: _kIconSize,
                fit: BoxFit.contain,
                image: AssetImage("assets/images/class-icons/$characterId.png"),
              ),
              const SizedBox(
                width: _kCharIconSpacing,
              ),
              Text(
                "$characterName's loot:",
                style: kTitleStyle,
              )
            ]),
        ..._kLootNames.map((name) => createListTile(name, characterId)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    List<Character> characters = GameMethods.getCurrentCharacters();

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: _kTopSpacing,
                      ),
                      for (Character character in characters)
                        buildCharacterLootWidget(character.characterClass.id,
                            character.characterState.display.value),
                      const SizedBox(
                        height: kMenuCloseButtonSpacing,
                      ),
                    ],
                  ),
                  Positioned(
                      width: kCloseButtonWidth,
                      height: kButtonSize,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: kButtonLabelStyle,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ]))));
  }
}
