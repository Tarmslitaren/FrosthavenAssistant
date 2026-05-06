import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/widgets/scrollable_menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/use_fh_perks_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../services/service_locator.dart';
import 'perk_list_tile.dart';

const divider = Divider(
  color: Colors.grey,
  thickness: 1,
  height: 16,
  indent: 8,
  endIndent: 8,
);

class PerksMenu extends StatelessWidget {
  const PerksMenu({super.key, required this.character, this.gameState});
  final Character character;
  // injected for testing
  final GameState? gameState;

  @override
  Widget build(BuildContext context) {
    final gameState = this.gameState ?? getIt<GameState>();
    return ListenableBuilder(
        listenable: Listenable.merge([
          character.characterState.useFHPerks,
          character.characterState.perkListVersion,
        ]),
        builder: (context, child) {
          final ScrollController scrollController = ScrollController();

          final perksFH = character.characterClass.perksFH;
          final bool hasFHPerkSet = perksFH.isNotEmpty;
          final bool useFHPerks =
              hasFHPerkSet && character.characterState.useFHPerks.value;
          final perks = useFHPerks ? perksFH : character.characterClass.perks;

          List<Widget> tiles = [];
          tiles.add(Text(
            "Add Perks",
            style: kTitleStyle,
          ));

          if (hasFHPerkSet) {
            tiles.add(CheckboxListTile(
                title: Text(
                  "Use Frosthaven Perks",
                  style: kBodyStyle,
                ),
                value: useFHPerks,
                onChanged: (on) {
                  //setState(() {
                  gameState.action(UseFHPerksCommand(character.id));
                  // }
                }));
          }

          for (int i = 0; i < perks.length; i++) {
            tiles.add(divider);
            tiles.add(
                PerkListTile(character: character, index: i, perk: perks[i]));
          }
          tiles.add(divider);

          return ScrollableMenuCard(
              maxWidth: 300, child: Column(children: tiles));
        });
  }
}
