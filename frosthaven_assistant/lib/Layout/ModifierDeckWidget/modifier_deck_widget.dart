import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Layout/view_models/modifier_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'modifier_draw_animation_widget.dart';
import 'modifier_slide_animation_widget.dart';

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({
    super.key,
    required this.name,
    this.gameState,
    this.gameData,
    this.settings,
  });

  final String name;

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  static const double _kCardOffset = 33.3333;
  static const double _kCardHeight = 39.0;
  static const double _kWidgetWidth = 153.0;
  static const double _kCharIconSize = 27.0;
  static const double _kCharIconLeft = 16.0;
  static const double _kDiscardBorderRadius = 5.0;
  static const double _kEmptyDiscardWidth = 66.6666;
  static const double _kDiscardPileWidth = 57.6666;
  static const double _kCardRotationTurns = 15 / 360;
  static const double _kCharIconTop = 6.0;
  static const int _kCenterDivisor = 2;
  static const int _kTransparentBlack = 0x7A000000;
  static const int _kDiscardShowThirdMinSize = 2;
  static const int _kDiscardThirdFromEnd = 3;
  static const int _kDiscardSecondFromEnd = 2;

  ModifierDeckViewModel? _vmInstance;
  ModifierDeckViewModel get _vm => _vmInstance ??= ModifierDeckViewModel(
        widget.name,
        gameState: widget.gameState,
        gameData: widget.gameData,
        settings: widget.settings,
      );
  bool _animationsEnabled = false;

  Widget _buildStayAnimation(Widget child, double userScalingBars) {
    return Container(
        margin: EdgeInsets.only(
            left: ModifierDeckWidgetState._kCardOffset * userScalingBars),
        child: child);
  }

  Widget _buildSlideAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(
              left: ModifierDeckWidgetState._kCardOffset * userScalingBars),
          child: child);
    }
    return ModifierSlideAnimationWidget(
      key: key,
      userScalingBars: userScalingBars,
      onComplete: () => _animationsEnabled = false,
      child: child,
    );
  }

  Widget _buildDrawAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled || context.globalPaintBounds == null) {
      return Container(child: child);
    }
    final double width = kModifierCardBaseWidth * userScalingBars;
    final double height =
        ModifierDeckWidgetState._kCardHeight * userScalingBars;
    final screenSize = MediaQuery.of(context).size;
    final double startXOffset = -(width + kSmallMargin * userScalingBars);

    final globalPaintBounds = context.globalPaintBounds;
    final screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset.zero;
    final screenSpaceY = screenSpaceOffset.dy;
    final screenSpaceX = screenSpaceOffset.dx - startXOffset;

    final localScreenWidth = screenSize.width -
        screenSpaceX * ModifierDeckWidgetState._kCenterDivisor;
    final heightShaveOff = (screenSize.height - screenSpaceY) *
        ModifierDeckWidgetState._kCenterDivisor;
    final localScreenHeight = screenSize.height - heightShaveOff;
    final double yOffset =
        -(localScreenHeight / ModifierDeckWidgetState._kCenterDivisor +
            height / ModifierDeckWidgetState._kCenterDivisor);
    final double xOffset =
        localScreenWidth / ModifierDeckWidgetState._kCenterDivisor -
            width / ModifierDeckWidgetState._kCenterDivisor;

    return ModifierDrawAnimationWidget(
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
    final bool isAnimating = false;
    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final userScalingBars = _vm.userScalingBars.value;
          return SizedBox(
            width: ModifierDeckWidgetState._kWidgetWidth * userScalingBars,
            height: ModifierDeckWidgetState._kCardHeight * userScalingBars,
            child: ListenableBuilder(
                listenable: Listenable.merge([_vm.lastEvent, _vm.cardCount]),
                builder: (context, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = _vm.initAnimationEnabled();
                  }

                  final textStyle = TextStyle(
                      fontSize: kDeckFontSize * userScalingBars,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(kShadowOffset * userScalingBars,
                                kShadowOffset * userScalingBars),
                            color: Colors.black)
                      ]);

                  final currentCharacterColor = _vm.currentCharacterColor;
                  final currentCharacterName = _vm.currentCharacterName;
                  final deck = _vm.deck;
                  final discardPileSize = deck.discardPileSize;
                  final discardPileList = deck.discardPileContents.toList();
                  final widgetKey = discardPileSize.toString();

                  final characterIconWidget = Positioned(
                    height: ModifierDeckWidgetState._kCharIconSize *
                        userScalingBars,
                    width: ModifierDeckWidgetState._kCharIconSize *
                        userScalingBars,
                    top:
                        ModifierDeckWidgetState._kCharIconTop * userScalingBars,
                    left: ModifierDeckWidgetState._kCharIconLeft *
                        userScalingBars,
                    child: Image.asset(
                        color: currentCharacterColor,
                        'assets/images/class-icons/$currentCharacterName.png'),
                  );

                  return Row(
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              _animationsEnabled = true;
                              _vm.drawCard();
                            });
                          },
                          child: Stack(children: [
                            deck.drawPileIsNotEmpty
                                ? Stack(children: [
                                    ModifierCardWidget(
                                        card: deck.drawPileTop,
                                        name: deck.name,
                                        revealed: isAnimating ||
                                            deck.revealedCount.value > 0),
                                    Positioned.fill(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                                focusColor:
                                                    const Color(0x44000000),
                                                onTap: () {
                                                  setState(() {
                                                    _animationsEnabled = true;
                                                    _vm.drawCard();
                                                  });
                                                })))
                                  ])
                                : Stack(children: [
                                    Container(
                                        width: kModifierCardBaseWidth *
                                            userScalingBars,
                                        height: ModifierDeckWidgetState
                                                ._kCardHeight *
                                            userScalingBars,
                                        color: Color(ModifierDeckWidgetState
                                            ._kTransparentBlack)),
                                    if (currentCharacterName != null)
                                      characterIconWidget,
                                    Positioned.fill(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              focusColor:
                                                  const Color(0x44000000),
                                              onTap: () {
                                                setState(() {
                                                  _animationsEnabled = true;
                                                  _vm.drawCard();
                                                });
                                              },
                                              child: Center(
                                                  child: Text(
                                                "Shuffle\n& Draw",
                                                style: textStyle,
                                                textAlign: TextAlign.center,
                                              )),
                                            )))
                                  ]),
                            Positioned(
                                bottom: 0,
                                right: kSmallMargin * userScalingBars,
                                child: Text(
                                  deck.drawPileSize.toString(),
                                  style: textStyle,
                                )),
                          ])),
                      SizedBox(
                        width: kSmallMargin * userScalingBars,
                      ),
                      Stack(children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: kSmallMargin /
                                  ModifierDeckWidgetState._kCenterDivisor *
                                  userScalingBars),
                          width: ModifierDeckWidgetState._kDiscardPileWidth *
                              userScalingBars,
                          height: ModifierDeckWidgetState._kCardHeight *
                              userScalingBars,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(
                                ModifierDeckWidgetState._kDiscardBorderRadius *
                                    userScalingBars)),
                            border: Border.fromBorderSide(
                                const BorderSide(color: Colors.white70)),
                            color: Color(
                                ModifierDeckWidgetState._kTransparentBlack),
                          ),
                        ),
                        discardPileSize >
                                ModifierDeckWidgetState
                                    ._kDiscardShowThirdMinSize
                            ? _buildStayAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(
                                        ModifierDeckWidgetState
                                            ._kCardRotationTurns),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length -
                                              ModifierDeckWidgetState
                                                  ._kDiscardThirdFromEnd],
                                      revealed: true,
                                    )),
                                userScalingBars)
                            : Container(),
                        discardPileSize > 1
                            ? _buildSlideAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(
                                        ModifierDeckWidgetState
                                            ._kCardRotationTurns),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length -
                                              ModifierDeckWidgetState
                                                  ._kDiscardSecondFromEnd],
                                      revealed: true,
                                    )),
                                Key(widgetKey),
                                userScalingBars)
                            : Container(),
                        deck.discardPileIsNotEmpty
                            ? _buildDrawAnimation(
                                ModifierCardWidget(
                                  name: deck.name,
                                  key: Key(widgetKey),
                                  card: deck.discardPileTop,
                                  revealed: true,
                                ),
                                Key((-deck.discardPileSize).toString()),
                                userScalingBars)
                            : SizedBox(
                                width: ModifierDeckWidgetState
                                        ._kEmptyDiscardWidth *
                                    userScalingBars,
                                height: ModifierDeckWidgetState._kCardHeight *
                                    userScalingBars,
                              ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    focusColor: const Color(0x44000000),
                                    onLongPress: () {
                                      _vm.openZoom(context);
                                    },
                                    onTap: () {
                                      setState(() {
                                        _vm.openModifierMenu(context);
                                      });
                                    })))
                      ])
                    ],
                  );
                }),
          );
        });
  }
}
