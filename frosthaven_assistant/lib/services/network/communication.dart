import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
    // TODO RS: add deduplication by ip address and port
    socket.setOption(SocketOption.tcpNoDelay, true);
    socket.encoding = utf8;
    _sockets.add(socket);
  }

  void sendToAll(String data) {
    final message = _composeMessageFrom(data);
    for (var socket in _sockets) {
      socket.write(message);
    }
  }

  void disconnect() {
    while (_sockets.isNotEmpty) {
      var socket = _sockets.first;
      socket.destroy();
      _sockets.remove(socket);
    }
  }

  void listen(
      Function(Uint8List) onData, Function? onError, Function()? onDone) {
    for (var socket in _sockets) {
      socket.listen(onData, onError: onError, onDone: onDone);
    }
  }

  bool connected() {
    return _sockets.isNotEmpty;
  }

  String _composeMessageFrom(String data) {
    return messageTemplate.format(data);
  }
}
