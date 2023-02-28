import 'dart:io';

import 'package:format/format.dart';

class Communication {
  static const beggining = "S3nD:";
  static const end = "[EOM]";
  final messageTemplate = "$beggining{}$end";
  final _sockets = <Socket>[];

  void sendTo(Socket? socket, String data) {
    if (socket != null) {
      socket.write(_composeMessageFrom(data));
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

  void add(Socket socket) {
    _sockets.add(socket);
  }

  void sendToAll(String data) {
    final message = _composeMessageFrom(data);
    for (var socket in _sockets) {
      socket.write(message);
    }
  }

  String _composeMessageFrom(String data) {
    return messageTemplate.format(data);
  }
}
