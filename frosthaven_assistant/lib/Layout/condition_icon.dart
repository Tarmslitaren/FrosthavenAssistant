import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/game_methods.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import 'view_models/condition_icon_view_model.dart';

class ConditionIcon extends StatefulWidget {
  ConditionIcon(this.condition, this.size, this.owner, this.figure,
      {super.key, required this.scale, this.gameState, this.settings}) {
    String suffix = "";
    if (GameMethods.isFrosthavenStyle(null)) {
      suffix = "_fh";
    }
    String imagePath = "assets/images/abilities/${condition.name}.png";
    if (condition.name.contains("character")) {
      imagePath = "assets/images/class-icons/${condition.getName()}.png";
    } else if (suffix.isNotEmpty && hasGHVersion(condition.name)) {
      imagePath = "assets/images/abilities/${condition.getName()}$suffix.png";
    }
    gfx = imagePath;
  }

  final Condition condition;
  final double size;
  final double scale;
  final ListItemData owner;
  final FigureState figure;
  final GameState? gameState;
  // injected for testing
  final Settings? settings;
  late final String gfx;

  @override
  ConditionIconState createState() => ConditionIconState();
}

class ConditionIconState extends State<ConditionIcon> {
  late final ConditionIconViewModel _vm;
  final animate = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _vm = ConditionIconViewModel(
        gameState: widget.gameState, settings: widget.settings);
    _vm.commandIndex.addListener(_animateListener);
  }

  @override
  void dispose() {
    _vm.commandIndex.removeListener(_animateListener);
    super.dispose();
  }

  void _runAnimation() {
    animate.value = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
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
    return ValueListenableBuilder<bool>(
        valueListenable: animate,
        builder: (context, value, child) {
          final isCharacter = _vm.isCharacterCondition(widget.condition);
          final classColor = _vm.classColorFor(widget.condition);
          return RepaintBoundary(
              child: ShakeAnimatedWidget(
                  duration: const Duration(milliseconds: 333),
                  enabled: animate.value,
                  alignment: Alignment.center,
                  shakeAngle: Rotation.deg(x: 0, y: 0, z: 30),
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
                              height: widget.size * scale * 0.45,
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
