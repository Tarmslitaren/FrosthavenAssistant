import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Layout/view_models/modifier_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

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
  static const int cardAnimationDuration = 1200;
  static const double _kCardOffset = 33.3333;
  static const double _kCardWidth = 58.6666;
  static const double _kCardHeight = 39.0;
  static const double _kWidgetWidth = 153.0;
  static const double _kFontSize = 12.0;
  static const double _kShadowOffset = 1.0;
  static const double _kCharIconSize = 27.0;
  static const double _kCharIconLeft = 16.0;
  static const double _kSmallMargin = 2.0;
  static const double _kDiscardBorderRadius = 5.0;
  static const double _kEmptyDiscardWidth = 66.6666;
  static const double _kDiscardPileWidth = 57.6666;
  static const double _kCardRotationTurns = 15 / 360;
  static const double _kCharIconTop = 6.0; // (_kCardHeight - _kCharIconSize) / 2
  static const double _kRotationDegrees = 15.0;
  static const double _kRotationInterval = 0.25;
  static const double _kDegreesPerRadian = 180.0;
  static const int _kCenterDivisor = 2;
  static const int _kTransparentBlack = 0x7A000000;
  static const int _kDiscardShowThirdMinSize = 2;
  static const int _kDiscardThirdFromEnd = 3;
  static const int _kDiscardSecondFromEnd = 2;

  late final ModifierDeckViewModel _vm;
  bool _animationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _vm = ModifierDeckViewModel(
      widget.name,
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings,
    );
  }

  Widget _buildStayAnimation(Widget child, double userScalingBars) {
    return Container(
        margin: EdgeInsets.only(left: ModifierDeckWidgetState._kCardOffset * userScalingBars),
        child: child);
  }

  Widget _buildSlideAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(left: ModifierDeckWidgetState._kCardOffset * userScalingBars),
          child: child);
    }
    return _ModifierSlideAnimationWidget(
      key: key,
      userScalingBars: userScalingBars,
      onComplete: () => _animationsEnabled = false,
      child: child,
    );
  }

  Widget _buildDrawAnimation(
      Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled || context.globalPaintBounds == null) {
      return Container(child: child);
    }
    final double width = ModifierDeckWidgetState._kCardWidth * userScalingBars;
    final double height = ModifierDeckWidgetState._kCardHeight * userScalingBars;
    final screenSize = MediaQuery.of(context).size;
    final double startXOffset = -(width + ModifierDeckWidgetState._kSmallMargin * userScalingBars);

    final globalPaintBounds = context.globalPaintBounds;
    final screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset.zero;
    final screenSpaceY = screenSpaceOffset.dy;
    final screenSpaceX = screenSpaceOffset.dx - startXOffset;

    final localScreenWidth = screenSize.width - screenSpaceX * ModifierDeckWidgetState._kCenterDivisor;
    final heightShaveOff = (screenSize.height - screenSpaceY) * ModifierDeckWidgetState._kCenterDivisor;
    final localScreenHeight = screenSize.height - heightShaveOff;
    final double yOffset = -(localScreenHeight / ModifierDeckWidgetState._kCenterDivisor + height / ModifierDeckWidgetState._kCenterDivisor);
    final double xOffset = localScreenWidth / ModifierDeckWidgetState._kCenterDivisor - width / ModifierDeckWidgetState._kCenterDivisor;

    return _ModifierDrawAnimationWidget(
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
    final bool isAnimating = false;
    //is not doing anything now. in case flip animation is added
    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final userScalingBars = _vm.userScalingBars.value;
          return SizedBox(
            width: ModifierDeckWidgetState._kWidgetWidth * userScalingBars,
            height: ModifierDeckWidgetState._kCardHeight * userScalingBars,
            child: ValueListenableBuilder<int>(
                valueListenable: _vm.commandIndex,
                builder: (context, value, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = _vm.initAnimationEnabled();
                  }

                  final textStyle = TextStyle(
                      fontSize: ModifierDeckWidgetState._kFontSize * userScalingBars,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(
                                ModifierDeckWidgetState._kShadowOffset * userScalingBars, ModifierDeckWidgetState._kShadowOffset * userScalingBars),
                            color: Colors.black)
                      ]);

                  final currentCharacterColor = _vm.currentCharacterColor;
                  final currentCharacterName = _vm.currentCharacterName;
                  final deck = _vm.deck;
                  final discardPileSize = deck.discardPileSize;
                  final discardPileList = deck.discardPileContents.toList();
                  final widgetKey = discardPileSize.toString();

                  final characterIconWidget = Positioned(
                    height: ModifierDeckWidgetState._kCharIconSize * userScalingBars,
                    width: ModifierDeckWidgetState._kCharIconSize * userScalingBars,
                    top: ModifierDeckWidgetState._kCharIconTop * userScalingBars,
                    left: ModifierDeckWidgetState._kCharIconLeft * userScalingBars,
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
                                        width: ModifierDeckWidgetState._kCardWidth * userScalingBars,
                                        height: ModifierDeckWidgetState._kCardHeight * userScalingBars,
                                        color: Color(
                                            ModifierDeckWidgetState._kTransparentBlack)),
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
                                right: ModifierDeckWidgetState._kSmallMargin * userScalingBars,
                                child: Text(
                                  deck.cardCount.value.toString(),
                                  style: textStyle,
                                )),
                          ])),
                      SizedBox(
                        width: ModifierDeckWidgetState._kSmallMargin * userScalingBars,
                      ),
                      Stack(children: [
                        Container(
                          margin: EdgeInsets.only(top: ModifierDeckWidgetState._kSmallMargin / ModifierDeckWidgetState._kCenterDivisor * userScalingBars),
                          width: ModifierDeckWidgetState._kDiscardPileWidth * userScalingBars,
                          height: ModifierDeckWidgetState._kCardHeight * userScalingBars,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(ModifierDeckWidgetState._kDiscardBorderRadius * userScalingBars)),
                            border: Border.all(color: Colors.white70),
                            color: Color(ModifierDeckWidgetState._kTransparentBlack),
                          ),
                        ),
                        discardPileSize > ModifierDeckWidgetState._kDiscardShowThirdMinSize
                            ? _buildStayAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(ModifierDeckWidgetState._kCardRotationTurns),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - ModifierDeckWidgetState._kDiscardThirdFromEnd],
                                      revealed: true,
                                    )),
                                userScalingBars)
                            : Container(),
                        discardPileSize > 1
                            ? _buildSlideAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(ModifierDeckWidgetState._kCardRotationTurns),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - ModifierDeckWidgetState._kDiscardSecondFromEnd],
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
                                width: ModifierDeckWidgetState._kEmptyDiscardWidth * userScalingBars,
                                height: ModifierDeckWidgetState._kCardHeight * userScalingBars,
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

class _ModifierSlideAnimationWidget extends StatefulWidget {
  const _ModifierSlideAnimationWidget({
    required super.key,
    required this.child,
    required this.userScalingBars,
    required this.onComplete,
  });

  final Widget child;
  final double userScalingBars;
  final VoidCallback onComplete;

  @override
  State<_ModifierSlideAnimationWidget> createState() =>
      _ModifierSlideAnimationWidgetState();
}

class _ModifierSlideAnimationWidgetState
    extends State<_ModifierSlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _translation;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: ModifierDeckWidgetState.cardAnimationDuration),
      vsync: this,
    );

    final slideTarget = Offset(ModifierDeckWidgetState._kCardOffset * widget.userScalingBars, 0);
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
          tween: ConstantTween(-ModifierDeckWidgetState._kRotationDegrees * math.pi / ModifierDeckWidgetState._kDegreesPerRadian), weight: 1),
      TweenSequenceItem(
        tween: Tween(begin: -ModifierDeckWidgetState._kRotationDegrees * math.pi / ModifierDeckWidgetState._kDegreesPerRadian, end: 0.0),
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

class _ModifierDrawAnimationWidget extends StatefulWidget {
  const _ModifierDrawAnimationWidget({
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
  State<_ModifierDrawAnimationWidget> createState() =>
      _ModifierDrawAnimationWidgetState();
}

class _ModifierDrawAnimationWidgetState
    extends State<_ModifierDrawAnimationWidget>
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
      duration:
          const Duration(milliseconds: ModifierDeckWidgetState.cardAnimationDuration),
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
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: _maxScale), weight: 1),
      TweenSequenceItem(tween: ConstantTween(_maxScale), weight: _kAnimWeightPause),
      TweenSequenceItem(
          tween: Tween(begin: _maxScale, end: 1.0), weight: 1),
    ]).animate(_controller);

    _rotation = Tween<double>(begin: math.pi, end: _kTwoPI).animate(
      CurvedAnimation(
          parent: _controller, curve: const Interval(0.0, ModifierDeckWidgetState._kRotationInterval)),
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
