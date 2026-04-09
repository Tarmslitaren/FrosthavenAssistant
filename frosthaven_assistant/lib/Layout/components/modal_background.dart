import 'package:flutter/material.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class ModalBackground extends StatelessWidget {
  const ModalBackground({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget child;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: kModalBackgroundOpacity), BlendMode.dstATop),
          image: AssetImage(getIt<Settings>().darkMode.value
              ? 'assets/images/bg/dark_bg.png'
              : 'assets/images/bg/white_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
