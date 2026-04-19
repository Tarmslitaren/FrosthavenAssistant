import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/game_methods.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import 'view_models/condition_icon_view_model.dart';

class ConditionIcon extends StatefulWidget {
  ConditionIcon(this.condition, this.size, this.owner, this.figure,
      {super.key, required this.scale, this.gameState, this.settings})
      : gfx = _buildGfxPath(condition);

  static String _buildGfxPath(Condition condition) {
    String suffix = "";
    if (GameMethods.isFrosthavenStyle(null)) {
      suffix = "_fh";
    }
    if (condition.name.contains("character")) {
      return "assets/images/class-icons/${condition.getName()}.png";
    } else if (suffix.isNotEmpty && hasGHVersion(condition.name)) {
      return "assets/images/abilities/${condition.getName()}$suffix.png";
    }
    return "assets/images/abilities/${condition.name}.png";
  }

  final Condition condition;
  final double size;
  final double scale;
  final ListItemData owner;
  final FigureState figure;
  final GameState? gameState;
  // injected for testing
  final Settings? settings;
  final String gfx;

  @override
  ConditionIconState createState() => ConditionIconState();
}

class ConditionIconState extends State<ConditionIcon>
    with SingleTickerProviderStateMixin {
  static const double _kShakeAngleDegrees = 30.0;
  static const double _kDegreesPerRadian = 180.0;
  static const double _kShakeAngleRad =
      _kShakeAngleDegrees * math.pi / _kDegreesPerRadian;
  static const double _kShakeWeightHalf = 2;
  static const double _kClassTokenIconScale = 0.45;

  ConditionIconViewModel? _vmInstance;
  ConditionIconViewModel get _vm => _vmInstance ??= ConditionIconViewModel(
      gameState: widget.gameState, settings: widget.settings);
  AnimationController? _shakeController;
  Animation<double>? _shakeAngle;

  final animate = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _vm.commandIndex.addListener(_animateListener);

    final ctrl = AnimationController(
      duration: const Duration(milliseconds: 333),
      vsync: this,
    );
    _shakeController = ctrl;
    _shakeAngle = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: _kShakeAngleRad), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: _kShakeAngleRad, end: -_kShakeAngleRad),
          weight: _kShakeWeightHalf),
      TweenSequenceItem(
          tween: Tween(begin: -_kShakeAngleRad, end: 0.0), weight: 1),
    ]).animate(ctrl);
  }

  @override
  void dispose() {
    _vmInstance?.commandIndex.removeListener(_animateListener);
    _shakeController?.dispose();
    super.dispose();
  }

  void _runAnimation() {
    animate.value = true;
    _shakeController?.forward(from: 0.0).then((_) {
      animate.value = false;
    });
  }

  void _animateListener() {
    final oldState = _vm.getOldState();
    if (oldState == null) return;

    if (_vm.shouldTriggerAnimation(
      condition: widget.condition,
      owner: widget.owner,
      figure: widget.figure,
      oldState: oldState,
    )) {
      _runAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final shakeController = _shakeController;
    final shakeAngle = _shakeAngle;
    if (shakeController == null || shakeAngle == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<bool>(
        valueListenable: animate,
        builder: (context, value, child) {
          final isCharacter = _vm.isCharacterCondition(widget.condition);
          final classColor = _vm.classColorFor(widget.condition);
          return RepaintBoundary(
              child: AnimatedBuilder(
                  animation: shakeController,
                  builder: (context, child) => Transform.rotate(
                        angle: shakeAngle.value,
                        child: child,
                      ),
                  child: isCharacter
                      ? Stack(alignment: Alignment.center, children: [
                          Image(
                              color: classColor,
                              colorBlendMode: BlendMode.modulate,
                              height: widget.size * scale,
                              filterQuality: FilterQuality.medium,
                              image: const AssetImage(
                                  "assets/images/psd/class-token-bg.png")),
                          Image(
                              height:
                                  widget.size * scale * _kClassTokenIconScale,
                              filterQuality: FilterQuality.medium,
                              image: AssetImage(widget.gfx)),
                        ])
                      : Image(
                          height: widget.size * scale,
                          filterQuality: FilterQuality.medium,
                          image: AssetImage(widget.gfx),
                        )));
        });
  }
}
