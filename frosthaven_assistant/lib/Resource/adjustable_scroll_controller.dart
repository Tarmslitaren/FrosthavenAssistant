import 'dart:math';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class ScrollDetector extends StatelessWidget {
  final void Function(PointerScrollEvent event) onPointerScroll;
  final Widget child;

  const ScrollDetector({
    required Key key,
    required this.onPointerScroll,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          onPointerScroll(pointerSignal);
        } else {}
      },
      child: child,
    );
  }
}

//todo: delete this. not needed
class AdjustableScrollController extends ScrollController {
  AdjustableScrollController([int extraScrollSpeed = 30]) {
    /*super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          double scrollEnd = super.offset +
              (scrollDirection == ScrollDirection.reverse
                  ? extraScrollSpeed
                  : -extraScrollSpeed);
          scrollEnd = min(super.position.maxScrollExtent,
              max(super.position.minScrollExtent, scrollEnd));
          jumpTo(scrollEnd);
          //totally screws up non mouse wheel scrolling...
        }
      }
    })*/
    ;
  }
}
