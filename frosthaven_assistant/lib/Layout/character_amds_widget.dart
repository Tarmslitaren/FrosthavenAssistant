import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import 'modifier_deck_widget.dart';
import 'view_models/character_amds_view_model.dart';

class CharacterAmdsWidget extends StatefulWidget {
  const CharacterAmdsWidget({super.key, this.gameState, this.settings});

  final GameState? gameState;
  final Settings? settings;

  @override
  CharacterAmdsWidgetState createState() => CharacterAmdsWidgetState();
}

class CharacterAmdsWidgetState extends State<CharacterAmdsWidget> {
  static const double _kDeckBaseHeight = 39.0;
  static const double _kDeckMargin = 4.0;

  late final CharacterAmdsViewModel _vm;
  _OpenState _openStateUserIntentPlayTurns = _OpenState.oneOpen;
  _OpenState _openStateUserIntentChooseInit = _OpenState.allOpen;
  _OpenState _lastState = _OpenState.noOpen;

  @override
  void initState() {
    super.initState();
    _vm = CharacterAmdsViewModel(
        gameState: widget.gameState, settings: widget.settings);
  }

  List<Offset> _getOffsets(int characterAmount) {
    final roundState = _vm.roundState;
    final currentCharacter = _vm.currentCharacter;
    final barScale = _vm.barScale;
    final deckHeight = (_kDeckBaseHeight + _kDeckMargin) * barScale;
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
  }

  @override
  Widget build(BuildContext context) {
    if (!_vm.showCharacterAmd) {
      return Container();
    }
    final characterAmount = _vm.characterAmount;
    if (characterAmount == 0) {
      return Container();
    }

    final currentCharacter = _vm.currentCharacter;
    final roundState = _vm.roundState;
    final canShowOneDeck = _vm.canShowOneDeck;
    final duration = const Duration(milliseconds: 500);
    final barScale = _vm.barScale;
    final offsets = _getOffsets(characterAmount);
    const text = "Character Decks";

    return RepaintBoundary(
        child: TweenAnimationBuilder<Offset>(
            tween: Tween(begin: offsets.first, end: offsets.last),
            duration: duration,
            curve: Easing.standard,
            builder: (context, offset, child) =>
                Transform.translate(offset: offset, child: child),
            child: Column(children: [
              ElevatedButton(
                  onPressed: () => {
                        setState(() {
                          if (roundState == RoundState.chooseInitiative) {
                            if (_openStateUserIntentChooseInit ==
                                _OpenState.noOpen) {
                              _openStateUserIntentChooseInit =
                                  _OpenState.allOpen;
                            } else if (_openStateUserIntentChooseInit ==
                                _OpenState.allOpen) {
                              _openStateUserIntentChooseInit =
                                  _OpenState.noOpen;
                            }
                          } else {
                            if (canShowOneDeck) {
                              if (_openStateUserIntentPlayTurns ==
                                  _OpenState.oneOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.allOpen;
                              } else if (_openStateUserIntentPlayTurns ==
                                  _OpenState.allOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.oneOpen;
                              } else if (_openStateUserIntentPlayTurns ==
                                  _OpenState.noOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.oneOpen;
                              }
                            } else {
                              if (_openStateUserIntentPlayTurns ==
                                  _OpenState.noOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.allOpen;
                              } else if (_openStateUserIntentPlayTurns ==
                                  _OpenState.allOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.oneOpen;
                              } else if (_openStateUserIntentPlayTurns ==
                                  _OpenState.oneOpen) {
                                _openStateUserIntentPlayTurns =
                                    _OpenState.allOpen;
                              }
                            }
                          }
                        })
                      },
                  child: const Text(text)),
              RepaintBoundary(
                  child: AnimatedOpacity(
                      opacity: _lastState == _OpenState.noOpen ? 0.0 : 1.0,
                      duration: duration,
                      curve: Easing.standard,
                      child: (_openStateUserIntentPlayTurns ==
                                  _OpenState.oneOpen &&
                              canShowOneDeck)
                          ? Container(
                              margin: EdgeInsets.only(top: _kDeckMargin * barScale),
                              child: ModifierDeckWidget(
                                  name: currentCharacter!.id))
                          : Column(
                              children: _vm.charsWithPerks
                                  .map((item) => Container(
                                      margin:
                                          EdgeInsets.only(top: _kDeckMargin * barScale),
                                      child: ModifierDeckWidget(name: item.id)))
                                  .toList(),
                            )))
            ])));
  }
}

enum _OpenState { noOpen, oneOpen, allOpen }
