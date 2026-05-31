import 'dart:io';

import 'package:flutter/services.dart';

/// Controls the Android foreground-service notification that keeps the
/// X-haven server process alive when the app is backgrounded.
///
/// All methods are no-ops on non-Android platforms.
class AndroidForegroundService {
  static const _channel = MethodChannel(
    'com.tarmslitaren.frosthaven_assistant/foreground_service',
  );

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('start');
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('stop');
  }
}
