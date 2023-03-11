import 'dart:convert';
import 'dart:io';

import 'package:format/format.dart';

class Connection {
  final _sockets = <Socket>[];

  List<Socket> getAll() {
    return _sockets;
  }

  void connect(Socket socket) {
    _cleanUpClosedConnections();
    if (!_isClosed(socket)) {
      final existingConnections = _find(socket);
      _destroy(existingConnections);
      socket.setOption(SocketOption.tcpNoDelay, true);
      socket.encoding = utf8;
      _sockets.add(socket);
    }
  }

  Iterable<Socket> _find(Socket socket) {
    return _sockets.where((x) =>
        x.remoteAddress == socket.remoteAddress && x.port == socket.port);
  }

  void disconnectAll() {
    _destroy(_sockets);
  }

  void _destroy(Iterable<Socket> sockets) {
    while (sockets.isNotEmpty) {
      var socket = sockets.first;
      socket.destroy();
      _sockets.remove(socket);
    }
  }

  void disconnect(Socket socket) {
    _cleanUpClosedConnections();
    if (!_isClosed(socket)) {
      var toDisconnect = _find(socket);
      _destroy(toDisconnect);
    }
  }

  bool connected() {
    return _sockets.isNotEmpty;
  }

  // Check if socet was remotely closed, thus address and port are unaccessable
  bool _isClosed(Socket socket) {
    try {
      socket.remoteAddress;
      socket.port;
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

  void _cleanUpClosedConnections() {
    var toDisconnect = _sockets.where((x) => _isClosed(x));
    while (toDisconnect.isNotEmpty) {
      var socket = toDisconnect.first;
      socket.destroy();
      _sockets.remove(socket);
    }
  }
}
