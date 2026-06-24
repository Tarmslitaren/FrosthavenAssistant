import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _fonts = {
  'NotoSans': 'NotoSans.ttf',
  'NotoSansKR': 'NotoSansKR.ttf',
  'NotoSansSC': 'NotoSansSC.ttf',
  'NotoSansTC': 'NotoSansTC.ttf',
  'NotoSansThai': 'NotoSansThai.ttf',
};

Future<void> loadLinuxFonts() async {
  if (kIsWeb || !Platform.isLinux) return;

  final fontsDir = Directory(
    '${File(Platform.resolvedExecutable).parent.path}/data/fonts',
  );
  if (!fontsDir.existsSync()) return;

  for (final entry in _fonts.entries) {
    final file = File('${fontsDir.path}/${entry.value}');
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key);
    loader.addFont(
      file.readAsBytes().then((bytes) => bytes.buffer.asByteData()),
    );
    await loader.load();
  }
}
