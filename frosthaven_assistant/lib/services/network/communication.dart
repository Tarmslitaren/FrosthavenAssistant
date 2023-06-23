import 'dart:io';
import 'dart:typed_data';

import 'package:format/format.dart';

import '../service_locator.dart';
import 'connection.dart';

class Communication {
  static const begining = "S3nD:";
  static const end = "[EOM]";
  final messageTemplate = "$begining{}$end";
  final _connection = getIt<Connection>();

  // TODO: Need to test this somehow, or refactor altogether.
  // If testing, then better to verify assigned functions are being called on specific actions, rather than verify mock socket assignments.
  void listen(
      Function(Uint8List) onData, Function? onError, Function()? onDone) {
    final sockets = _connection.getAll();
    for (var socket in sockets) {
      socket.listen(onData, onError: onError, onDone: onDone);
    }
  }

  void sendToAllExcept(Socket client, String data) {
    final sockets = _connection.getAll();
    final recipients =
        sockets.where((x) => x.remoteAddress != client.remoteAddress);
    for (var socket in recipients) {
      sendTo(socket, data);
    }
  }

  // TODO: Change to throw exception if socket is null. Otherwise impossible to test
  void sendTo(Socket? socket, String data) {
    if (socket != null) {
      socket.write(_composeMessageFrom(data));
    }
  }

  void sendToAll(String data) {
    final message = _composeMessageFrom(data);
    final sockets = _connection.getAll();
    for (var socket in sockets) {
      socket.write(message);
    }
  }

  String dataFrom(String message) {
    final valid = isValid(message);
    var data = valid
        ? message.substring(begining.length, message.length - end.length)
        : "";
    return data;
  }

  bool isValid(String message) {
    return message.startsWith(begining) && message.endsWith(end);
  }

  String _composeMessageFrom(String data) {
    return messageTemplate.format(data);
  }
}
