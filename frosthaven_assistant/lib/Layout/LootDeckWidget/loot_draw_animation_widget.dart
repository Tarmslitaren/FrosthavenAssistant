import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class LootDrawAnimationWidget extends StatefulWidget {
  static const int _kAnimationDuration = 1600;
  static const double _kMaxScale = 4.0;
  static const double _kAnimWeightPause = 2;
  static const double _kRotationInterval = 0.25;

  const LootDrawAnimationWidget({
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
  State<LootDrawAnimationWidget> createState() =>
      _LootDrawAnimationWidgetState();
}

class _LootDrawAnimationWidgetState extends State<LootDrawAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _translation;
  Animation<double>? _scale;
  Animation<double>? _rotation;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      duration: const Duration(
          milliseconds: LootDrawAnimationWidget._kAnimationDuration),
      vsync: this,
    );
    _controller = ctrl;

    final start = Offset(widget.startXOffset, 0);
    final center = Offset(widget.xOffset, widget.yOffset);

    _translation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: start, end: center), weight: 1),
      TweenSequenceItem(
          tween: ConstantTween(center),
          weight: LootDrawAnimationWidget._kAnimWeightPause),
      TweenSequenceItem(
          tween: Tween(begin: center, end: Offset.zero), weight: 1),
    ]).animate(ctrl);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween:
              Tween(begin: 1.0, end: LootDrawAnimationWidget._kMaxScale),
          weight: 1),
      TweenSequenceItem(
          tween: ConstantTween(LootDrawAnimationWidget._kMaxScale),
          weight: LootDrawAnimationWidget._kAnimWeightPause),
      TweenSequenceItem(
          tween:
              Tween(begin: LootDrawAnimationWidget._kMaxScale, end: 1.0),
          weight: 1),
    ]).animate(ctrl);

    _rotation = Tween<double>(begin: math.pi, end: kTwoPI).animate(
      CurvedAnimation(
          parent: ctrl,
          curve: const Interval(
              0.0, LootDrawAnimationWidget._kRotationInterval)),
    );

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
    final scale = _scale;
    final rotation = _rotation;
    if (controller == null ||
        translation == null ||
        scale == null ||
        rotation == null) {
      return widget.child;
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.translate(
          offset: translation.value,
          child: Transform.scale(
            scale: scale.value,
            child: Transform.rotate(
              angle: rotation.value,
              child: child,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
