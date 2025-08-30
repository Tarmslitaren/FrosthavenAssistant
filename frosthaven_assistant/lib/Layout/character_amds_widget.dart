import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../services/service_locator.dart';
import 'modifier_deck_widget.dart';

class CharacterAmdsWidget extends StatefulWidget {
  const CharacterAmdsWidget({super.key});

  @override
  CharacterAmdsWidgetState createState() => CharacterAmdsWidgetState();
}

class CharacterAmdsWidgetState extends State<CharacterAmdsWidget> {
  bool _isOpen = true;
  bool enableAnim = false;

  @override
  Widget build(BuildContext context) {
    final Character? currentCharacter = GameMethods.getCurrentCharacter();
    final showCharacterAmd = getIt<Settings>().showCharacterAMD.value;
    if (!showCharacterAmd) {
      return Container();
    }
    final chars = GameMethods.getCurrentCharacters();
    int characterAmount = 0;
    for (final character in chars) {
      if (character.characterClass.perks.isNotEmpty) {
        characterAmount++;
      }
    }
    if (characterAmount == 0) {
      return Container();
    }
    if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
      //while in the choosing state, show all character amd's, since we don't care so much about blocking monster stat cards
      final barScale = getIt<Settings>().userScalingBars.value;

      final offset = characterAmount * (39 + 4) * barScale;
      final duration = Duration(milliseconds: 500);

      return TranslationAnimatedWidget(
          enabled: true,
          values: (_isOpen)
              ? [Offset(0, offset), Offset(0, 0)]
              : [Offset(0, 0), Offset(0, offset)],
          duration: duration,
          curve: Easing.standard,
          child: Column(children: [
            ElevatedButton(
                focusNode: FocusNode(skipTraversal: true),
                //todo: nicer button: show that it hides the amds somehow
                onPressed: () => {
                      setState(() {
                        _isOpen = !_isOpen;
                        //enableAnim = true;
                      })
                    },
                child: Text("Character Decks")),
            TranslationAnimatedWidget(
                enabled: true,
                values: (_isOpen)
                    ? [Offset(0, offset), Offset(0, 0)]
                    : [Offset(0, 0), Offset(0, offset)],
                duration: duration,
                curve: Easing.standard,
                child: Column(
                  children: chars
                      .map((item) => (item.characterClass.perks.isNotEmpty)
                          ? Container(
                              margin: EdgeInsets.only(
                                top: 4 * barScale,
                              ),
                              child: ModifierDeckWidget(name: item.id))
                          : Container())
                      .toList(),
                ))
          ]));
    } else if (currentCharacter != null &&
        currentCharacter.characterClass.perks.isNotEmpty) {
      return ModifierDeckWidget(name: currentCharacter.id);
    }

    return Container();
  }
}
