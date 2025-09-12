import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_faction_card_command.dart';

import '../../Resource/color_matrices.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class GH2eFactionAMDCardMenu extends StatefulWidget {
  const GH2eFactionAMDCardMenu(
      {super.key, required this.faction, required this.name});

  final String faction;
  final String name;

  @override
  GH2eFactionAMDCardMenuState createState() => GH2eFactionAMDCardMenuState();
}

class GH2eFactionAMDCardMenuState extends State<GH2eFactionAMDCardMenu> {
  final List<ModifierCard> _factionCards = [];

  String? addedCard;

  @override
  initState() {
    super.initState();
    _factionCards.clear();
    _factionCards.addAll(GameMethods.getFactionCards(widget.faction));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = 3;
    final cardWidth = 3.5 * 58.6666;
    if (screenSize.width < cardWidth * 2) {
      scale = 3 * (screenSize.width / (cardWidth * 2));
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //add 4 cards in grid
          Wrap(
            runSpacing: 2,
            spacing: 2,
            children: [
              for (var item in _factionCards)
                InkWell(
                    onTap: () {
                      if (addedCard == null &&
                          !GameMethods.isCardInAnyCharacterDeck(item.gfx)) {
                        getIt<GameState>().action(
                            AddFactionCardCommand(widget.name, item.gfx, true));
                        setState(() {
                          addedCard = item.gfx;
                        });
                      }
                    },
                    child: ColorFiltered(
                        colorFilter:
                            !GameMethods.isCardInAnyCharacterDeck(item.gfx)
                                ? ColorFilter.matrix(identity)
                                : ColorFilter.matrix(grayScale),
                        child:
                            ModifierCardWidget.buildFront(item, "", scale, 1))),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: AssetImage(getIt<Settings>().darkMode.value
                      ? 'assets/images/bg/dark_bg.png'
                      : 'assets/images/bg/white_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(children: [
                SizedBox(
                  height: addedCard == null ? 20 : 30,
                ),
                if (addedCard == null)
                  Text("Tap Card to add to your deck",
                      style: getTitleTextStyle(1)),
                if (addedCard != null)
                  TextButton(
                      onPressed: () {
                        final cardToRemove = addedCard;
                        if (cardToRemove != null) {
                          getIt<GameState>().action(AddFactionCardCommand(
                              widget.name, cardToRemove, false));
                        }
                        setState(() {
                          addedCard = null;
                        });
                      },
                      child: const Text("Remove card from your deck?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20))),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
              ]))
        ]);
  }
}
