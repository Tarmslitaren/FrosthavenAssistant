import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_faction_card_command.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/color_matrices.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class GH2eFactionAMDCardMenu extends StatefulWidget {
  const GH2eFactionAMDCardMenu(
      {super.key, required this.faction, required this.name, this.gameState});

  final String faction;
  final String name;
  final GameState? gameState;

  @override
  GH2eFactionAMDCardMenuState createState() => GH2eFactionAMDCardMenuState();
}

class GH2eFactionAMDCardMenuState extends State<GH2eFactionAMDCardMenu> {
  static const double _kDefaultScale = 3.0;
  static const double _kCardWidthFactor = 3.5;
  static const double _kCardWidthBase = 58.6666;
  static const int _kTwoColumns = 2;
  static const double _kWrapSpacing = 2.0;
  static const double _kModalWidth = 300.0;
  static const double _kModalHeight = 180.0;
  static const double _kSpacerNoCard = 20.0;
  static const double _kSpacerWithCard = 30.0;

  late final GameState _gameState; // ignore: avoid-late-keyword
  final List<ModifierCard> _factionCards = [];

  String? addedCard;

  @override
  initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    super.initState();
    _factionCards.clear();
    _factionCards.addAll(GameMethods.getFactionCards(widget.faction));

    //find if card added previously
    final deck = GameMethods.getModifierDeck(widget.name, _gameState);
    for (final item in _factionCards) {
      if (deck.hasCard(item.gfx)) {
        addedCard = item.gfx;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = _kDefaultScale;
    final cardWidth = _kCardWidthFactor * _kCardWidthBase;
    if (screenSize.width < cardWidth * _kTwoColumns) {
      scale = _kDefaultScale * (screenSize.width / (cardWidth * _kTwoColumns));
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //add 4 cards in grid
          Wrap(
            runSpacing: _kWrapSpacing,
            spacing: _kWrapSpacing,
            children: [
              for (var item in _factionCards)
                InkWell(
                    onTap: () {
                      if (addedCard == null &&
                          !GameMethods.isCardInAnyCharacterDeck(item.gfx)) {
                        _gameState.action(
                            AddFactionCardCommand(widget.name, item.gfx, true, gameState: _gameState));
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
                            ModifierCardFront(card: item, name: "", scale: scale))),
            ],
          ),
          const SizedBox(
            height: _kSpacerNoCard,
          ),
          ModalBackground(
              width: _kModalWidth,
              height: _kModalHeight,
              child: Column(children: [
                SizedBox(
                  height: addedCard == null ? _kSpacerNoCard : _kSpacerWithCard,
                ),
                if (addedCard == null)
                  Text("Tap Card to add to your deck",
                      style: getTitleTextStyle(1)),
                if (addedCard != null)
                  TextButton(
                      onPressed: () {
                        final cardToRemove = addedCard;
                        if (cardToRemove != null) {
                          _gameState.action(AddFactionCardCommand(
                              widget.name, cardToRemove, false, gameState: _gameState));
                        }
                        setState(() {
                          addedCard = null;
                        });
                      },
                      child: const Text("Remove card from your deck?",
                          textAlign: TextAlign.center,
                          style: kButtonLabelStyle)),
                const SizedBox(
                  height: _kSpacerNoCard,
                ),
                const SizedBox(
                  height: _kSpacerNoCard,
                ),
              ]))
        ]);
  }
}
