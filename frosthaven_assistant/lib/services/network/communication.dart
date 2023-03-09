import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
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
    // final existingConnections = _sockets.where((x) =>
    //     x.remoteAddress == socket.remoteAddress && x.port == socket.port);
    // for (var connection in existingConnections) {
    //   connection.destroy();
    //   _sockets.remove(connection);
    // }
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

  void disconnectAll() {
    while (_sockets.isNotEmpty) {
      var socket = _sockets.first;
      socket.destroy();
      _sockets.remove(socket);
    }
  }

  void disconnect(Socket socket) {
    var toDisconnect = _sockets
        .where((x) =>
            _isClosed(socket) ||
            x.remoteAddress == socket.remoteAddress && x.port == socket.port)
        .firstOrNull;
    if (toDisconnect != null) {
      toDisconnect.destroy();
      _sockets.remove(toDisconnect);
    }
  }

  // TODO: Need to test this somehow, or refactor altogether.
  // If testing, then better to verify assigned functions are being called on specific actions, rather than verify mock socket assignments.
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

  void sendToAllExcept(Socket client, String data) {
    final recipients = _sockets.where((x) =>
        x.remoteAddress != client.remoteAddress && x.port != client.port);
    for (var socket in recipients) {
      sendTo(socket, data);
    }
  }

  // Check if socet was remotely closed, thus address and port are unaccessable
  bool _isClosed(Socket socket) {
    try {
      final _ = socket.remoteAddress;
      final port = socket.port;
      return false;
    } on SocketException catch (_) {
      return true;
    } catch (e) {
      // Close the socket, as something is completely wrong with it
      print('Unexpected exception in determining socket closure: \'{}\''
          .format(e.toString()));
      return true;
    }
  }
}
