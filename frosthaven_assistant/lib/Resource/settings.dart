import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class Settings {
  final userScalingMainList = ValueNotifier<double>(1.0);
  final userScalingBars = ValueNotifier<double>(1.0);
  final userScalingMenus = ValueNotifier<double>(1.0);
  final fullScreen = ValueNotifier<bool>(true);
  final darkMode = ValueNotifier<bool>(false);

  //used for both initiative and search menus
  final softNumpadInput = ValueNotifier<bool>(false);


  Future<void> init() async {
    await loadFromDisk();
    setFullscreen(fullScreen.value);
  }

  Future<void> setFullscreen(bool fullscreen) async {
    fullScreen.value = fullscreen;
    //to set fullscreen on pc - need to add exit button to quit //would be good to exit/enter mode with ctrl+enter
    if(Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsFlutterBinding.ensureInitialized();
      windowManager.ensureInitialized();

      // Use it only after calling `hiddenWindowAtLaunch`
      windowManager.waitUntilReadyToShow().then((_) async {
// Hide window title bar
        //await windowManager.setTitleBarStyle('hidden');
        if(fullscreen) {
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
          await windowManager.setFullScreen(true);
          await windowManager.center();
          await windowManager.show();
          await windowManager.setSkipTaskbar(false);
          await windowManager.setAlwaysOnTop(true);
          await windowManager.setPosition(const Offset(0,0)); //weird this was needed
          await windowManager.show();
          
        }else {
          await windowManager.setTitleBarStyle(TitleBarStyle.normal);
          await windowManager.setFullScreen(false);
          await windowManager.center();
          await windowManager.show();
          await windowManager.setSkipTaskbar(false);
          await windowManager.focus();
          await windowManager.setAlwaysOnTop(false);

        }
      });
      //await WindowManager.instance.setFullScreen(fullscreen);
    } else {
      //android:
      //to hide ui top and bottom on android
      if (fullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
      }
      //to fix issue with system bottom bar on top after keyboard shown on earlier os (24)
      SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) =>
          Future.delayed(const Duration(milliseconds: 1001), () {
            if (fullscreen) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            } else {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
            }
            //in case the first went too early?
            Future.delayed(const Duration(milliseconds: 301), () {
              if (fullscreen) {
                SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
              }
            });
          }));
    }

    saveToDisk();
  }

  Future<void> saveToDisk() async {
    String saveState = toString();

    const sharedPrefsKey = 'settingsState';
    bool _hasError = false;
    bool _isWaiting = true;
    //notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      // save
      // uncomment this to simulate an error-during-save
      // if (_value > 3) throw Exception("Artificial Error");
      await prefs.setString(sharedPrefsKey, saveState);
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    //notifyListeners();
  }

  Future<void> loadFromDisk() async {
    //have to call after init or element state overridden

    const sharedPrefsKey = 'settingsState';
    String? state;
    bool _hasError = false;
    bool _isWaiting = true;
    //notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getString(sharedPrefsKey);
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    if (state != null) {
      Map<String, dynamic> data = jsonDecode(state);

      if (data["userScalingMainList"] != null) {
        userScalingMainList.value = data["userScalingMainList"];
      }
      if (data["userScalingBars"] != null) {
        userScalingBars.value = data["userScalingBars"];
      }
      if (data["userScalingMenus"] != null) {
        userScalingMenus.value = data["userScalingMenus"];
      }
      if (data["fullScreen"] != null) {
        fullScreen.value = data["fullScreen"];
      }
      if (data["softNumpadInput"] != null) {
        softNumpadInput.value = data["softNumpadInput"];
      }
      if (data["darkMode"] != null) {
        darkMode.value = data["darkMode"];
      }
    }
  }

  @override
  String toString() {
    return '{'
        '"userScalingMainList": ${userScalingMainList.value}, '
        '"userScalingBars": ${userScalingBars.value}, '
        '"userScalingMenus": ${userScalingMenus.value}, '
        '"fullScreen": ${fullScreen.value}, '
        '"softNumpadInput": ${softNumpadInput.value}, '
        '"darkMode": ${darkMode.value} '
        '}';
  }
}
