import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/set_loot_owner_command.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/widgets/modal_background.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class SetLootOwnerMenu extends StatelessWidget {
  static const double _kMenuHeight = 280.0;
  static const double _kRowSpacing = 10.0;

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

  GameState get _gameState => gameState ?? getIt<GameState>();
  Settings get _settings => settings ?? getIt<Settings>();

  @override
  Widget build(BuildContext context) {
    List<Character> characters = GameMethods.getCurrentCharacters();
    return ModalBackground(
        width: kMenuNarrowWidth,
        height: SetLootOwnerMenu._kMenuHeight,
        child: Column(children: [
          const SizedBox(
            height: kMenuTopPadding,
          ),
          Text(
            "Set Loot Owner:",
            style: getTitleTextStyle(1),
          ),
          ...List.generate(
            characters.length,
            (i) => _CharacterButton(
                character: characters[i],
                card: card,
                gameState: _gameState,
                settings: _settings),
          ),
        ]));
  }
}

class _CharacterButton extends StatelessWidget {
  const _CharacterButton({
    required this.character,
    required this.card,
    required this.gameState,
    required this.settings,
  });

  final Character character;
  final LootCard card;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: SetLootOwnerMenu._kRowSpacing),
      TextButton(
          onPressed: () {
            gameState
                .action(SetLootOwnerCommand(character.characterClass.id, card));
            Navigator.pop(context);
          },
          child: Row(children: [
            Image(
              filterQuality: FilterQuality.medium,
              height: kIconSize,
              width: kIconSize,
              fit: BoxFit.contain,
              color: settings.darkMode.value ? Colors.white : Colors.black,
              image: AssetImage(
                  "assets/images/class-icons/${character.characterClass.name}.png"),
            ),
            const SizedBox(width: SetLootOwnerMenu._kRowSpacing),
            Text(character.characterState.display.value,
                textAlign: TextAlign.center, style: getTitleTextStyle(1))
          ]))
    ]);
  }
}
