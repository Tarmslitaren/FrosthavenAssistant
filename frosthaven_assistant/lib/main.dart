import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

//import 'package:scaled_app/scaled_app.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import 'Layout/menus/main_menu.dart';

void main() {
  setupGetIt();

  /*ScaledWidgetsFlutterBinding.ensureInitialized(
    baseWidth: 490,
    applyScaling: (deviceWidth) => deviceWidth > 100 && deviceWidth < 740,
  );*/
  //runAppScaled(const MyApp());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);




  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    //to set fullscreen on pc - need to add exit button to quit //would be good to exit/enter mode with ctrl+enter
    //WindowManager.instance.setFullScreen(true);
    //to hide ui top and bottom on android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    //to fix issue with system bottom bar on top after keyboard shown on earlier os (24)
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) =>
    Future.delayed(const Duration(milliseconds: 1001), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      //in case the first went to  early?
      Future.delayed(const Duration(milliseconds: 301), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      });
    }));
     //call after keyboard
    if (!kIsWeb) {
      Wakelock.enable();
      //should force app to be in foreground and disable screen lock
    }
    //Screen.keepOn(true);

    return MaterialApp(
        //debugShowCheckedModeBanner: false,
        //debugShowMaterialGrid: true,
        checkerboardOffscreenLayers: false,
        //showPerformanceOverlay: true,
        title: 'Frosthaven Assistant',
        theme: theme,
        home: const MyHomePage(title: 'Frosthaven Assistant'),
      );

    /*return MaterialApp(
      title: 'Frosthaven Assistant',
      theme: theme,
      home: const MyHomePage(title: 'Frosthaven Assistant'),
    );*/
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
