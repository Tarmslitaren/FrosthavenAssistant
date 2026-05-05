import 'dart:math' as math;

import 'package:flutter/material.dart';

class ModifierSlideAnimationWidget extends StatefulWidget {
  static const int _kAnimationDuration = 1200;
  static const double _kCardOffset = 33.3333;
  static const double _kRotationDegrees = 15.0;
  static const double _kDegreesPerRadian = 180.0;

  const ModifierSlideAnimationWidget({
    required super.key,
    required this.child,
    required this.userScalingBars,
    required this.onComplete,
  });

  final Widget child;
  final double userScalingBars;
  final VoidCallback onComplete;

  @override
  State<ModifierSlideAnimationWidget> createState() =>
      _ModifierSlideAnimationWidgetState();
}

class _ModifierSlideAnimationWidgetState
    extends State<ModifierSlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _translation;
  Animation<double>? _rotation;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      duration: const Duration(
          milliseconds: ModifierSlideAnimationWidget._kAnimationDuration),
      vsync: this,
    );
    _controller = ctrl;

    final slideTarget = Offset(
        ModifierSlideAnimationWidget._kCardOffset * widget.userScalingBars, 0);
    _translation = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 1),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: slideTarget)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(ctrl);

    _rotation = TweenSequence<double>([
      TweenSequenceItem(
          tween: ConstantTween(
              -ModifierSlideAnimationWidget._kRotationDegrees *
                  math.pi /
                  ModifierSlideAnimationWidget._kDegreesPerRadian),
          weight: 1),
      TweenSequenceItem(
        tween: Tween(
            begin: -ModifierSlideAnimationWidget._kRotationDegrees *
                math.pi /
                ModifierSlideAnimationWidget._kDegreesPerRadian,
            end: 0.0),
        weight: 1,
      ),
    ]).animate(ctrl);

    ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    ctrl.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final translation = _translation;
    final rotation = _rotation;
    if (controller == null || translation == null || rotation == null) {
      return widget.child;
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.translate(
          offset: translation.value,
          child: Transform.rotate(
            angle: rotation.value,
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
