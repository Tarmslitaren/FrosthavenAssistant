import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/set_loot_owner_command.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class SetLootOwnerMenu extends StatefulWidget {
  static const double _kMenuWidth = 300.0;
  static const double _kMenuHeight = 280.0;
  static const double _kTopSpacing = 20.0;
  static const double _kRowSpacing = 10.0;
  static const double _kIconSize = 30.0;

  final LootCard card;

  const SetLootOwnerMenu({
    super.key,
    required this.card,
    this.gameState,
    this.settings,
  });

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  SetLootOwnerMenuState createState() => SetLootOwnerMenuState();
}

class SetLootOwnerMenuState extends State<SetLootOwnerMenu> {
  late final GameState _gameState;
  late final Settings _settings;

  @override
  initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }

  Widget buildCharacterButton(Character character) {
    return Column(children: [
      const SizedBox(
        height: SetLootOwnerMenu._kRowSpacing,
      ),
      TextButton(
          onPressed: () {
            _gameState.action(
                SetLootOwnerCommand(character.characterClass.id, widget.card));
            Navigator.pop(context);
          },
          child: Row(children: [
            Image(
              filterQuality: FilterQuality.medium,
              height: SetLootOwnerMenu._kIconSize,
              width: SetLootOwnerMenu._kIconSize,
              fit: BoxFit.contain,
              color: _settings.darkMode.value
                  ? Colors.white
                  : Colors.black,
              image: AssetImage(
                  "assets/images/class-icons/${character.characterClass.name}.png"),
            ),
            const SizedBox(
              width: SetLootOwnerMenu._kRowSpacing,
            ),
            Text(character.characterState.display.value,
                textAlign: TextAlign.center, style: getTitleTextStyle(1))
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Character> characters = GameMethods.getCurrentCharacters();
    return ModalBackground(
        width: SetLootOwnerMenu._kMenuWidth,
        height: SetLootOwnerMenu._kMenuHeight,
        child: Column(children: [
          const SizedBox(
            height: SetLootOwnerMenu._kTopSpacing,
          ),
          Text(
            "Set Loot Owner:",
            style: getTitleTextStyle(1),
          ),
          if (characters.isNotEmpty) buildCharacterButton(characters.first),
          if (characters.length > 1) buildCharacterButton(characters[1]),
          if (characters.length > 2) buildCharacterButton(characters[2]),
          if (characters.length > 3) buildCharacterButton(characters[3]),
        ]));
  }
}
