/*return AppBar(
iconTheme: const IconThemeData(color: Colors.white),
leading: IconButton(
//could modify constraints to make the button take less space when small, but could potentially cause issues
padding: EdgeInsets.all(min(8.0 * userScaling, 8.0)),
icon: Icon(Icons.menu, shadows: [shadow], size: 24 * userScaling),
onPressed: () => Scaffold.of(context).openDrawer(),
),

);*/

import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          final double userScaling = settings.userScalingBars.value;
          return SizedBox(
              height: 40 * userScaling,
              child: Stack(children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: getIt<Settings>().darkMode,
                      builder: (context, value, child) {
                        final darkMode = getIt<Settings>().darkMode.value;
                        final shadow = Shadow(
                          offset: Offset(userScaling, userScaling),
                          color: Colors.black87,
                          blurRadius: userScaling,
                        );
                        return Container(
                            height: 40 * userScaling,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color:
                                  darkMode ? Colors.black : Colors.transparent,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4), // Shadow position
                                )
                              ],
                              image: DecorationImage(
                                  opacity: darkMode ? 0.4 : 1,
                                  image: ResizeImage(
                                      AssetImage(darkMode
                                          ? 'assets/images/psd/gloomhaven-bar.png'
                                          : 'assets/images/psd/frosthaven-bar.png'),
                                      height: (40 * userScaling).toInt()),
                                  fit: BoxFit.cover,
                                  repeat: ImageRepeat.repeatX),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: 40 * userScaling,
                                      height: 40 * userScaling,
                                      child: TextButton(
                                        child: Icon(Icons.menu,
                                            shadows: [shadow],
                                            color: Colors.white,
                                            size: 24 * userScaling),
                                        onPressed: () =>
                                            Scaffold.of(context).openDrawer(),
                                      )),
                                  Expanded(
                                    //child: Center(
                                    child: Text("X-haven\nAssistant",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * userScaling,
                                          shadows: [shadow],
                                        )),
                                    //),
                                  ),
                                  Row(
                                    children: [
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 226, 66, 30),
                                          element: Elements.fire,
                                          icon:
                                              'assets/images/psd/element-fire.png'),
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 85, 200, 239),
                                          element: Elements.ice,
                                          icon:
                                              'assets/images/psd/element-ice.png'),
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 152, 176, 181),
                                          element: Elements.air,
                                          icon:
                                              'assets/images/psd/element-air.png'),
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 124, 168, 42),
                                          element: Elements.earth,
                                          icon:
                                              'assets/images/psd/element-earth.png'),
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 236, 166, 15),
                                          element: Elements.light,
                                          icon:
                                              'assets/images/psd/element-light.png'),
                                      ElementButton(
                                          key: UniqueKey(),
                                          color: const Color.fromARGB(
                                              255, 31, 50, 131),
                                          element: Elements.dark,
                                          icon:
                                              'assets/images/psd/element-dark.png'),
                                    ],
                                  )
                                ]));
                      }),
                )
              ]));
        });
  }
}
