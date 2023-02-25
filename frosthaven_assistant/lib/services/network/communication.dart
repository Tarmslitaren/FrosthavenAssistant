import 'dart:io';

import 'package:format/format.dart';

class Communication {
  static const beggining = "S3nD:";
  static const end = "[EOM]";
  final messageTemplate = "$beggining{}$end";

  void sendTo(Socket? socket, String message) {
    if (socket != null) {
      socket.write(messageTemplate.format(message));
    }
  }

  String dataFrom(String message) {
    final valid = isValid(message);
    var data = valid
        ? message.substring(beggining.length, message.length - end.length)
        : "";
    return data;
  }

  bool isValid(String message) {
    return message.startsWith(beggining) && message.endsWith(end);
  }
}
