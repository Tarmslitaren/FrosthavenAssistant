import 'package:flutter/material.dart';

import '../Resource/settings.dart';
import '../services/service_locator.dart';

class BackGround extends StatelessWidget {
  const BackGround({super.key, required this.child, this.settings});

  final Widget child;
  // injected for testing
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final settings = this.settings ?? getIt<Settings>();
    bool darkMode = settings.darkMode.value;
    return Container(
        decoration: BoxDecoration(
            backgroundBlendMode: BlendMode.srcATop,
            color: darkMode ? Colors.black : Colors.grey,
            image: DecorationImage(
              opacity: darkMode ? 0.4 : 0.7,
              fit: BoxFit.cover,
              image: ResizeImage(
                  AssetImage(
                    darkMode
                        ? 'assets/images/bg/bg.png'
                        : 'assets/images/bg/frosthaven-bg.png',
                  ),
                  width: (MediaQuery.of(context).size.width).toInt(),
                  height: (MediaQuery.of(context).size.height -
                          80 * settings.userScalingBars.value)
                      .toInt(),
                  policy: ResizeImagePolicy.fit),
            )),
        child: child);
  }
}
