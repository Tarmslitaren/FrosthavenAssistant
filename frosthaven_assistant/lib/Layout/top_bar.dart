import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../Resource/enums.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();
    return ValueListenableBuilder<double>(
        valueListenable: getIt<Settings>().userScalingBars,
        builder: (context, value, child) {
          final userScaling = settings.userScalingBars.value;
          var shadow = Shadow(
            offset: Offset(1 * userScaling, 1 * userScaling),
            color: Colors.black87,
            blurRadius: 1 * userScaling,
          );
          return AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              focusNode: FocusNode(skipTraversal: true),
              //could modify constraints to make the button take less space when small, but could potentially cause issues
              padding: EdgeInsets.all(min(8.0 * userScaling, 8.0)),
              icon: Icon(Icons.menu, shadows: [shadow], size: 24 * userScaling),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: Container(
              padding: EdgeInsets.only(left: 2.0 * userScaling),
              child: Text(
                "X-haven\nAssistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * userScaling,
                  shadows: [shadow],
                ),
              ),
            ),
            toolbarHeight: 40 * settings.userScalingBars.value,
            flexibleSpace: ValueListenableBuilder<bool>(
                valueListenable: getIt<Settings>().darkMode,
                builder: (context, value, child) {
                  return Container(
                      height: 42 * userScaling,
                      color: getIt<Settings>().darkMode.value
                          ? Colors.black
                          : Colors.white,
                      child: Image(
                          height: 40 * settings.userScalingBars.value,
                          image: AssetImage(getIt<Settings>().darkMode.value
                              ? 'assets/images/psd/gloomhaven-bar.png'
                              : 'assets/images/psd/frosthaven-bar.png'),
                          fit: BoxFit.cover,
                          repeat: ImageRepeat.repeatX));
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
