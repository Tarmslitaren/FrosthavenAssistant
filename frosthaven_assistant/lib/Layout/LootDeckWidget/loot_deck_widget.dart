import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/view_models/loot_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../loot_card_widget.dart';
import 'loot_draw_animation_widget.dart';
import 'loot_slide_animation_widget.dart';

class LootDeckWidget extends StatefulWidget {
  const LootDeckWidget({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
  });

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  LootDeckWidgetState createState() => LootDeckWidgetState();
}

class LootDeckWidgetState extends State<LootDeckWidget> {
  static const double cardWidth = 13.3333;
  static const double _kCardW = 40.0;
  static const double _kWidgetWidth = 94.0;
  static const double _kIconSize = 35.0;
  static const double _kIconTopMargin = 12.0;
  static const double _kDiscardWidth = 39.0;
  static const double _kDiscardHeight = 57.6666;
  static const double _kDiscardBorderRadius = 5.0;
  static const double _kCardRotationTurns = 15 / 360;
  static const int _kTransparentBlack = 0x7A000000;
  static const int _kCenterDivisor = 2;
  static const int _kDiscardShowThirdMinSize = 2;
  static const int _kDiscardThirdFromEnd = 3;
  static const int _kDiscardSecondFromEnd = 2;

  LootDeckViewModel? _vmInstance;
  LootDeckViewModel get _vm => _vmInstance ??= LootDeckViewModel(
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings);
  bool _animationsEnabled = false;

  Widget _buildStayAnimation(Widget child, double userScalingBars) {
    return Container(
        margin: EdgeInsets.only(left: cardWidth * userScalingBars),
        child: child);
  }

  Widget _buildSlideAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(left: cardWidth * userScalingBars),
          child: child);
    }
    return LootSlideAnimationWidget(
      key: key,
      userScalingBars: userScalingBars,
      onComplete: () => _animationsEnabled = false,
      child: child,
    );
  }

  Widget _buildDrawAnimation(
      Widget child, Key key, BuildContext context, double userScalingBars) {
    if (!_animationsEnabled || context.globalPaintBounds == null) {
      return child;
    }
    final double width = LootDeckWidgetState._kCardW * userScalingBars;
    final double height = kModifierCardBaseWidth * userScalingBars;
    final double startXOffset = -width;

    final globalPaintBounds = context.globalPaintBounds;
    final screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset.zero;
    final screenSpaceY = screenSpaceOffset.dy;
    final screenSpaceX = screenSpaceOffset.dx - startXOffset;

    final screenSize = MediaQuery.of(context).size;
    final localScreenWidth = screenSize.width - screenSpaceX * _kCenterDivisor;
    final heightShaveOff = (screenSize.height - screenSpaceY) * _kCenterDivisor;
    final localScreenHeight = screenSize.height - heightShaveOff;
    final double yOffset =
        -(localScreenHeight / _kCenterDivisor + height / _kCenterDivisor);
    final double xOffset =
        localScreenWidth / _kCenterDivisor - width / _kCenterDivisor;

    return LootDrawAnimationWidget(
      key: key,
      startXOffset: startXOffset,
      xOffset: xOffset,
      yOffset: yOffset,
      onComplete: () => _animationsEnabled = false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Object>(
        valueListenable: _vm.modelData,
        builder: (context, value, child) {
          return _buildContent();
        });
  }

  Widget _buildContent() {
    bool isAnimating = false;

    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final userScalingBars = _vm.userScalingBars.value;
          return SizedBox(
            width: LootDeckWidgetState._kWidgetWidth * userScalingBars,
            height: kModifierCardBaseWidth * userScalingBars,
            child: ListenableBuilder(
                listenable: Listenable.merge([_vm.lastEvent, _vm.cardCount]),
                builder: (context, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = _vm.initAnimationEnabled();
                  }
                  if (_vm.shouldHide) {
                    return Container();
                  }

                  final deck = _vm.lootDeck;
                  final currentCharacterColor = _vm.currentCharacterColor;
                  final currentCharacterName = _vm.currentCharacterName;
                  final discardPileSize = deck.discardPileSize;
                  final discardPileList = deck.discardPileContents.toList();

                  return RepaintBoundary(
                      child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            if (deck.drawPileIsNotEmpty) {
                              setState(() {
                                _animationsEnabled = true;
                                _vm.drawCard();
                              });
                            }
                          },
                          child: Stack(children: [
                            deck.drawPileIsNotEmpty
                                ? LootCardWidget(
                                    card: deck.drawPileTop,
                                    revealed: isAnimating)
                                : Container(
                                    width: LootDeckWidgetState._kCardW *
                                        userScalingBars,
                                    height: kModifierCardBaseWidth *
                                        userScalingBars,
                                    color: Color(_kTransparentBlack)),
                            Positioned(
                                bottom: 0,
                                right: kSmallMargin * userScalingBars,
                                child: Text(
                                  deck.drawPileSize.toString(),
                                  style: TextStyle(
                                      fontSize: kDeckFontSize * userScalingBars,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            offset: Offset(
                                                kShadowOffset * userScalingBars,
                                                kShadowOffset *
                                                    userScalingBars),
                                            color: Colors.black)
                                      ]),
                                )),
                            if (currentCharacterName != null)
                              Positioned(
                                height: LootDeckWidgetState._kIconSize *
                                    userScalingBars,
                                width: LootDeckWidgetState._kIconSize *
                                    userScalingBars,
                                top: LootDeckWidgetState._kIconTopMargin *
                                    userScalingBars,
                                left: kSmallMargin * userScalingBars,
                                child: Image(
                                  color: currentCharacterColor,
                                  image: AssetImage(
                                      'assets/images/class-icons/$currentCharacterName.png'),
                                ),
                              )
                          ])),
                      SizedBox(
                        width: kSmallMargin * userScalingBars,
                      ),
                      InkWell(
                          onTap: () {
                            _vm.openLootMenu(context);
                          },
                          child: Stack(children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: kSmallMargin /
                                      LootDeckWidgetState._kCenterDivisor *
                                      userScalingBars),
                              width: LootDeckWidgetState._kDiscardWidth *
                                  userScalingBars,
                              height: LootDeckWidgetState._kDiscardHeight *
                                  userScalingBars,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    LootDeckWidgetState._kDiscardBorderRadius *
                                        userScalingBars)),
                                border: Border.fromBorderSide(
                                    const BorderSide(color: Colors.white70)),
                                color: Color(_kTransparentBlack),
                              ),
                            ),
                            discardPileSize >
                                    LootDeckWidgetState
                                        ._kDiscardShowThirdMinSize
                                ? _buildStayAnimation(
                                    RotationTransition(
                                        turns: AlwaysStoppedAnimation(
                                            LootDeckWidgetState
                                                ._kCardRotationTurns),
                                        child: LootCardWidget(
                                          card: discardPileList[
                                              discardPileSize -
                                                  LootDeckWidgetState
                                                      ._kDiscardThirdFromEnd],
                                          revealed: true,
                                        )),
                                    userScalingBars)
                                : Container(),
                            discardPileSize > 1
                                ? _buildSlideAnimation(
                                    RotationTransition(
                                        turns: AlwaysStoppedAnimation(
                                            LootDeckWidgetState
                                                ._kCardRotationTurns),
                                        child: LootCardWidget(
                                          card: discardPileList[
                                              discardPileSize -
                                                  LootDeckWidgetState
                                                      ._kDiscardSecondFromEnd],
                                          revealed: true,
                                        )),
                                    Key(deck.discardPileSize.toString()),
                                    userScalingBars)
                                : Container(),
                            deck.discardPileIsNotEmpty
                                ? _buildDrawAnimation(
                                    LootCardWidget(
                                      key: Key(discardPileSize.toString()),
                                      card: deck.discardPileTop,
                                      revealed: true,
                                    ),
                                    Key((-deck.discardPileSize).toString()),
                                    context,
                                    userScalingBars)
                                : SizedBox(
                                    width: LootDeckWidgetState._kCardW *
                                        userScalingBars,
                                    height: kModifierCardBaseWidth *
                                        userScalingBars,
                                  ),
                          ]))
                    ],
                  ));
                }),
          );
        });
  }
}
