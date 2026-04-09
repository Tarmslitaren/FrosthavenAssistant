import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_ability_list_command.dart';
import 'package:frosthaven_assistant/Resource/commands/shuffle_drawn_ability_card_command.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveCardMenu extends StatefulWidget {
  final MonsterAbilityCardModel card;

  const RemoveCardMenu({
    super.key,
    required this.card,
  });

  @override
  RemoveCardMenuState createState() => RemoveCardMenuState();
}

class RemoveCardMenuState extends State<RemoveCardMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isInDrawPile = false;
    for (var item in _gameState.currentAbilityDecks) {
      if (item.name == widget.card.deck) {
        var list = item.drawPile.getList();
        for (int i = 0; i < list.length; i++) {
          if (list[i].nr == widget.card.nr) {
            isInDrawPile = true;
            break;
          }
        }
        break;
      }
    }

    return ModalBackground(
        width: 300,
        height: 210,
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {
                _gameState.action(RemoveCardCommand(widget.card));
                Navigator.pop(context);
              },
              child: Text(
                  "Remove ${widget.card.title}\n(card nr: ${widget.card.nr})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: kFontSizeButtonLabel))),
          const SizedBox(
            height: 10,
          ),
          if (isInDrawPile)
            TextButton(
                onPressed: () {
                  int oldIndex = 0;
                  int newIndex = 0;
                  //todo: no logic in ui
                  for (var item in _gameState.currentAbilityDecks) {
                    if (item.name == widget.card.deck) {
                      var list = item.drawPile.getList();
                      for (int i = 0; i < list.length; i++) {
                        if (list[i].nr == widget.card.nr) {
                          oldIndex = i;
                          break;
                        }
                      }
                      break;
                    }
                  }
                  _gameState.action(ReorderAbilityListCommand(
                      widget.card.deck, newIndex, oldIndex));

                  Navigator.pop(context);
                },
                child: const Text("Send to Bottom",
                    style: TextStyle(fontSize: kFontSizeButtonLabel))),
          if (isInDrawPile)
            const SizedBox(
              height: 10,
            ),
          if (isInDrawPile)
            TextButton(
                onPressed: () {
                  _gameState
                      .action(ShuffleDrawnAbilityCardCommand(widget.card.deck));
                  Navigator.pop(context);
                },
                child: const Text("Shuffle un-drawn Cards",
                    style: TextStyle(fontSize: kFontSizeButtonLabel))),
        ]));
  }
}
