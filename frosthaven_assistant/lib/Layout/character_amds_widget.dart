import 'package:animated_widgets/widgets/opacity_animated.dart';
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
  _OpenState _openStateUserIntentPlayTurns = _OpenState.oneOpen;
  _OpenState _openStateUserIntentChooseInit = _OpenState.allOpen;
  _OpenState _lastState = _OpenState.noOpen;

  bool _enableAnim = true;

  List<Offset> _getOffsets(int characterAmount) {
    final roundState = getIt<GameState>().roundState.value;
    final Character? currentCharacter = GameMethods.getCurrentCharacter();
    final barScale = getIt<Settings>().userScalingBars.value;
    final deckHeight = (39 + 4) * barScale;
    final goingUpAll = [Offset(0, deckHeight * characterAmount), Offset(0, 0)];
    final goingUpSome = [
      Offset(0, deckHeight * (characterAmount - 1)),
      Offset(0, 0)
    ];
    final goingUpOne = [Offset(0, deckHeight), Offset(0, 0)];
    final goingDownOne = [
      Offset(0, deckHeight * (characterAmount - 1)),
      Offset(0, deckHeight * characterAmount)
    ];
    final goingDownAll = [
      Offset(0, 0),
      Offset(0, deckHeight * characterAmount)
    ];
    final goingDownSome = [
      Offset(0, -deckHeight * (characterAmount - 1)),
      Offset(0, 0)
    ];
    final goingNowhereNone = [
      Offset(0, deckHeight * (characterAmount)),
      Offset(0, deckHeight * (characterAmount))
    ];
    final goingNowhereAll = [Offset(0, 0), Offset(0, 0)];
    final goingNowhereOne = [Offset(0, 0), Offset(0, 0)];
    var retVal = [Offset(0, 0), Offset(0, 0)];

    //find where are we, and where are we going
    _OpenState whereWeAre = _lastState;
    _OpenState whereWeAreGoing = _OpenState.noOpen;

    if (roundState == RoundState.chooseInitiative) {
      whereWeAreGoing = _openStateUserIntentChooseInit;
    } else if (roundState == RoundState.playTurns) {
      whereWeAreGoing = _openStateUserIntentPlayTurns;
      if (currentCharacter == null && whereWeAreGoing == _OpenState.oneOpen) {
        whereWeAreGoing = _OpenState.noOpen;
      }
    }

    //find the diff
    if (whereWeAre == whereWeAreGoing) {
      if (whereWeAre == _OpenState.noOpen) {
        retVal = goingNowhereNone;
      }
      if (whereWeAre == _OpenState.oneOpen) {
        retVal = goingNowhereOne;
      }
      if (whereWeAre == _OpenState.allOpen) {
        retVal = goingNowhereAll;
      }
    }
    if (whereWeAreGoing == _OpenState.allOpen) {
      if (whereWeAre == _OpenState.noOpen) {
        retVal = goingUpAll;
      }
      if (whereWeAre == _OpenState.oneOpen) {
        if (characterAmount == 1) {
          return goingNowhereOne;
        }
        retVal = goingUpSome;
      }
    }
    if (whereWeAreGoing == _OpenState.oneOpen) {
      if (whereWeAre == _OpenState.noOpen) {
        retVal = goingUpOne;
      }
      if (whereWeAre == _OpenState.allOpen) {
        if (characterAmount == 1) {
          return goingNowhereOne;
        }
        retVal = goingDownSome;
      }
    }
    if (whereWeAreGoing == _OpenState.noOpen) {
      if (whereWeAre == _OpenState.oneOpen) {
        retVal = goingDownOne;
      }
      if (whereWeAre == _OpenState.allOpen) {
        retVal = goingDownAll;
      }
    }

    _lastState = whereWeAreGoing;
    return retVal;
    //show either all, one or none:
    //10 if all open, tap -> if current character -> show 1 else show none == goingDownSome or goingDownAll
    //20 if none open tap -> if current character -> show 1 else show all == going upOne or goingUpAll
    //30 if current character open tap -> show all goto 10 == goingUpAll
    //issue: can't go down if one open. it's ok
    //corner case: what if only one character ! (i.e. solo scenarios)
  }

  @override
  Widget build(BuildContext context) {
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

    final Character? currentCharacter = GameMethods.getCurrentCharacter();
    final roundState = getIt<GameState>().roundState.value;
    final canShowOneDeck = roundState == RoundState.playTurns &&
        currentCharacter != null &&
        currentCharacter.characterClass.perks.isNotEmpty;
    final duration = Duration(milliseconds: 500);
    final barScale = getIt<Settings>().userScalingBars.value;
    final offsets = _getOffsets(characterAmount);
    final text = "Character Decks";

    return TranslationAnimatedWidget(
        enabled: _enableAnim, //block this when not interacting
        values: offsets,
        duration: duration,
        curve: Easing.standard,
        child: Column(children: [
          ElevatedButton(
              //todo: nicer button: show that it hides the amds somehow
              onPressed: () => {
                    setState(() {
                      if (roundState == RoundState.chooseInitiative) {
                        if (_openStateUserIntentChooseInit ==
                            _OpenState.noOpen) {
                          _openStateUserIntentChooseInit = _OpenState.allOpen;
                        } else if (_openStateUserIntentChooseInit ==
                            _OpenState.allOpen) {
                          _openStateUserIntentChooseInit = _OpenState.noOpen;
                        }
                      } else {
                        if (canShowOneDeck) {
                          if (_openStateUserIntentPlayTurns ==
                              _OpenState.oneOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.allOpen;
                          } else if (_openStateUserIntentPlayTurns ==
                              _OpenState.allOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.oneOpen;
                          } else if (_openStateUserIntentPlayTurns ==
                              _OpenState.noOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.oneOpen;
                          }
                        } else {
                          if (_openStateUserIntentPlayTurns ==
                              _OpenState.noOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.allOpen;
                          } else if (_openStateUserIntentPlayTurns ==
                              _OpenState.allOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.oneOpen;
                          } else if (_openStateUserIntentPlayTurns ==
                              _OpenState.oneOpen) {
                            _openStateUserIntentPlayTurns = _OpenState.allOpen;
                          }
                        }
                      }
                      _enableAnim = true;
                    })
                  },
              child: Text(text)),
          OpacityAnimatedWidget.tween(
              enabled: _lastState == _OpenState.noOpen,
              opacityEnabled: 0, //define start value
              opacityDisabled: 1, //and end value
              duration: duration,
              curve: Easing.standard,
              child: (_openStateUserIntentPlayTurns == _OpenState.oneOpen &&
                      canShowOneDeck)
                  ? Container(
                      margin: EdgeInsets.only(
                        top: 4 * barScale,
                      ),
                      child: ModifierDeckWidget(name: currentCharacter.id))
                  : Column(
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
  }
}

enum _OpenState { noOpen, oneOpen, allOpen }
