import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../Resource/enums.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

class TopBar extends StatelessWidget {
  static const double _kMenuIconSize = 24.0;
  static const double _kTitlePaddingLeft = 2.0;
  static const double _kToolbarHeight = 40.0;
  static const double _kFlexibleHeight = 42.0;
  static const double _kDarkModeOpacity = 0.4;

  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          final userScaling = settings.userScalingBars.value;
          var shadow = Shadow(
            offset: Offset(1 * userScaling, 1 * userScaling),
            color: Colors.black87,
            blurRadius: 1 * userScaling,
          );
          return AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerUp: (event) {
                // Filter out phantom events at (0,0) caused by Flutter/iPadOS bug
                if (event.localPosition.dx > 1 || event.localPosition.dy > 1) {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: Container(
                alignment: Alignment.center,
                child:
                    Icon(Icons.menu, shadows: [shadow], size: _kMenuIconSize * userScaling),
              ),
            ),
            title: Container(
              padding: EdgeInsets.only(left: _kTitlePaddingLeft * userScaling),
              child: Text(
                "X-haven\nAssistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kFontSizeBody * userScaling,
                  shadows: [shadow],
                ),
              ),
            ),
            toolbarHeight: _kToolbarHeight * settings.userScalingBars.value,
            flexibleSpace: ValueListenableBuilder<bool>(
                valueListenable: settings.darkMode,
                builder: (context, value, child) {
                  final darkMode = settings.darkMode.value;
                  return Container(
                    height: _kFlexibleHeight * userScaling,
                    decoration: BoxDecoration(
                      color: darkMode ? Colors.black : Colors.transparent,
                      image: DecorationImage(
                        opacity: darkMode ? _kDarkModeOpacity : 1,
                        fit: BoxFit.cover,
                        repeat: ImageRepeat.repeatX,
                        image: ResizeImage(
                            AssetImage(darkMode
                                ? 'assets/images/psd/gloomhaven-bar.png'
                                : 'assets/images/psd/frosthaven-bar.png'),
                            height:
                                (_kToolbarHeight * settings.userScalingBars.value).toInt()),
                      ),
                    ),
                  );
                }),
            actions: [
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 226, 66, 30),
                  element: Elements.fire,
                  icon: 'assets/images/psd/element-fire.png'),
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 85, 200, 239),
                  element: Elements.ice,
                  icon: 'assets/images/psd/element-ice.png'),
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 152, 176, 181),
                  element: Elements.air,
                  icon: 'assets/images/psd/element-air.png'),
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 124, 168, 42),
                  element: Elements.earth,
                  icon: 'assets/images/psd/element-earth.png'),
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 236, 166, 15),
                  element: Elements.light,
                  icon: 'assets/images/psd/element-light.png'),
              ElementButton(
                  key: UniqueKey(),
                  color: const Color.fromARGB(255, 31, 50, 131),
                  element: Elements.dark,
                  icon: 'assets/images/psd/element-dark.png'),
            ],
          );
        });
  }
}
