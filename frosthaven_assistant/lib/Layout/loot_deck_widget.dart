import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/view_models/loot_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'loot_card.dart';

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
  static const int cardAnimationDuration = 1600;
  static const double _kCardW = 40.0;
  static const double _kCardH = 58.6666;
  static const double _kWidgetWidth = 94.0;
  static const double _kFontSize = 12.0;
  static const double _kShadowOffset = 1.0;
  static const double _kIconSize = 35.0;
  static const double _kIconTopMargin = 12.0; // (_kCardH - _kIconSize) / 2 ≈ 12
  static const double _kSmallMargin = 2.0;
  static const double _kDiscardWidth = 39.0;
  static const double _kDiscardHeight = 57.6666;
  static const double _kDiscardBorderRadius = 5.0;
  static const double _kCardRotationTurns = 15 / 360;
  static const int _kTransparentBlack = 0x7A000000;
  static const int _kCenterDivisor = 2;
  static const int _kDiscardShowThirdMinSize = 2;
  static const int _kDiscardThirdFromEnd = 3;
  static const int _kDiscardSecondFromEnd = 2;

  late final LootDeckViewModel _vm;
  bool _animationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _vm = LootDeckViewModel(
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings,
    );
  }

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
    return _LootSlideAnimationWidget(
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
    final double height = LootDeckWidgetState._kCardH * userScalingBars;
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
    final double yOffset = -(localScreenHeight / _kCenterDivisor + height / _kCenterDivisor);
    final double xOffset = localScreenWidth / _kCenterDivisor - width / _kCenterDivisor;

    return _LootDrawAnimationWidget(
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
          return _buildContent(context);
        });
  }

  Widget _buildContent(BuildContext context) {
    bool isAnimating = false;
    //is not doing anything now. in case flip animation is added

    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final userScalingBars = _vm.userScalingBars.value;
          return SizedBox(
            width: LootDeckWidgetState._kWidgetWidth * userScalingBars,
            height: LootDeckWidgetState._kCardH * userScalingBars,
            child: ValueListenableBuilder<int>(
                valueListenable: _vm.commandIndex,
                builder: (context, value, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = _vm.initAnimationEnabled();
                  }
                  return ValueListenableBuilder<int>(
                      valueListenable: _vm.cardCount,
                      builder: (context, value, child) {
                        if (_vm.shouldHide) {
                          return Container();
                        }

                        final deck = _vm.lootDeck;
                        final currentCharacterColor =
                            _vm.currentCharacterColor;
                        final currentCharacterName = _vm.currentCharacterName;
                        final discardPileSize = deck.discardPileSize;
                        final discardPileList =
                            deck.discardPileContents.toList();

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
                                          width: LootDeckWidgetState._kCardW * userScalingBars,
                                          height: LootDeckWidgetState._kCardH * userScalingBars,
                                          color: Color(_kTransparentBlack)),
                                  Positioned(
                                      bottom: 0,
                                      right: LootDeckWidgetState._kSmallMargin * userScalingBars,
                                      child: Text(
                                        deck.cardCount.value.toString(),
                                        style: TextStyle(
                                            fontSize: LootDeckWidgetState._kFontSize * userScalingBars,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  offset: Offset(
                                                      LootDeckWidgetState._kShadowOffset * userScalingBars,
                                                      LootDeckWidgetState._kShadowOffset * userScalingBars),
                                                  color: Colors.black)
                                            ]),
                                      )),
                                  if (currentCharacterName != null)
                                    Positioned(
                                      height: LootDeckWidgetState._kIconSize * userScalingBars,
                                      width: LootDeckWidgetState._kIconSize * userScalingBars,
                                      top: LootDeckWidgetState._kIconTopMargin * userScalingBars,
                                      left: LootDeckWidgetState._kSmallMargin * userScalingBars,
                                      child: Image(
                                        color: currentCharacterColor,
                                        image: AssetImage(
                                            'assets/images/class-icons/$currentCharacterName.png'),
                                      ),
                                    )
                                ])),
                            SizedBox(
                              width: LootDeckWidgetState._kSmallMargin * userScalingBars,
                            ),
                            InkWell(
                                onTap: () {
                                  _vm.openLootMenu(context);
                                },
                                child: Stack(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: LootDeckWidgetState._kSmallMargin / LootDeckWidgetState._kCenterDivisor * userScalingBars),
                                    width: LootDeckWidgetState._kDiscardWidth * userScalingBars,
                                    height: LootDeckWidgetState._kDiscardHeight * userScalingBars,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(LootDeckWidgetState._kDiscardBorderRadius * userScalingBars)),
                                      border: Border.all(color: Colors.white70),
                                      color: Color(
                                          _kTransparentBlack),
                                    ),
                                  ),
                                  discardPileSize > LootDeckWidgetState._kDiscardShowThirdMinSize
                                      ? _buildStayAnimation(
                                          RotationTransition(
                                              turns:
                                                  AlwaysStoppedAnimation(
                                                      LootDeckWidgetState._kCardRotationTurns),
                                              child: LootCardWidget(
                                                card: discardPileList[
                                                    discardPileSize - LootDeckWidgetState._kDiscardThirdFromEnd],
                                                revealed: true,
                                              )),
                                          userScalingBars)
                                      : Container(),
                                  discardPileSize > 1
                                      ? _buildSlideAnimation(
                                          RotationTransition(
                                              turns:
                                                  AlwaysStoppedAnimation(
                                                      LootDeckWidgetState._kCardRotationTurns),
                                              child: LootCardWidget(
                                                card: discardPileList[
                                                    discardPileSize - LootDeckWidgetState._kDiscardSecondFromEnd],
                                                revealed: true,
                                              )),
                                          Key(deck.discardPileSize.toString()),
                                          userScalingBars)
                                      : Container(),
                                  deck.discardPileIsNotEmpty
                                      ? _buildDrawAnimation(
                                          LootCardWidget(
                                            key:
                                                Key(discardPileSize.toString()),
                                            card: deck.discardPileTop,
                                            revealed: true,
                                          ),
                                          Key((-deck.discardPileSize)
                                              .toString()),
                                          context,
                                          userScalingBars)
                                      : SizedBox(
                                          width: LootDeckWidgetState._kCardW * userScalingBars,
                                          height: LootDeckWidgetState._kCardH * userScalingBars,
                                        ),
                                ]))
                          ],
                        ));
                      });
                }),
          );
        });
  }
}

class _LootSlideAnimationWidget extends StatefulWidget {
  const _LootSlideAnimationWidget({
    required super.key,
    required this.child,
    required this.userScalingBars,
    required this.onComplete,
  });

  final Widget child;
  final double userScalingBars;
  final VoidCallback onComplete;

  @override
  State<_LootSlideAnimationWidget> createState() =>
      _LootSlideAnimationWidgetState();
}

class _LootSlideAnimationWidgetState extends State<_LootSlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const double _kSlideStartAngle = -15.0 * math.pi / 180.0;

  late final AnimationController _controller;
  late final Animation<Offset> _translation;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: LootDeckWidgetState.cardAnimationDuration),
      vsync: this,
    );

    final slideTarget =
        Offset(LootDeckWidgetState.cardWidth * widget.userScalingBars, 0);
    _translation = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 1),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: slideTarget)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);

    _rotation = TweenSequence<double>([
      TweenSequenceItem(
          tween: ConstantTween(_kSlideStartAngle), weight: 1),
      TweenSequenceItem(
        tween: Tween(begin: _kSlideStartAngle, end: 0.0),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: _translation.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class _LootDrawAnimationWidget extends StatefulWidget {
  const _LootDrawAnimationWidget({
    required super.key,
    required this.child,
    required this.startXOffset,
    required this.xOffset,
    required this.yOffset,
    required this.onComplete,
  });

  final Widget child;
  final double startXOffset;
  final double xOffset;
  final double yOffset;
  final VoidCallback onComplete;

  @override
  State<_LootDrawAnimationWidget> createState() =>
      _LootDrawAnimationWidgetState();
}

class _LootDrawAnimationWidgetState extends State<_LootDrawAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const double _maxScale = 4.0;
  static const int _kAnimWeightPause = 2;
  static const double _kTwoPI = math.pi * 2;

  late final AnimationController _controller;
  late final Animation<Offset> _translation;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: LootDeckWidgetState.cardAnimationDuration),
      vsync: this,
    );

    final start = Offset(widget.startXOffset, 0);
    final center = Offset(widget.xOffset, widget.yOffset);

    _translation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: start, end: center), weight: 1),
      TweenSequenceItem(tween: ConstantTween(center), weight: _kAnimWeightPause),
      TweenSequenceItem(
          tween: Tween(begin: center, end: Offset.zero), weight: 1),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: _maxScale), weight: 1),
      TweenSequenceItem(tween: ConstantTween(_maxScale), weight: _kAnimWeightPause),
      TweenSequenceItem(tween: Tween(begin: _maxScale, end: 1.0), weight: 1),
    ]).animate(_controller);

    _rotation = Tween<double>(begin: math.pi, end: _kTwoPI).animate(
      CurvedAnimation(
          parent: _controller, curve: const Interval(0.0, 0.25)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: _translation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: child,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
