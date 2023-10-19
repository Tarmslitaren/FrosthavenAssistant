import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:format/format.dart';

class Connection {
  final _sockets = <Socket>[];

  List<Socket> getAll() {
    return _sockets;
  }

  Future<Socket> connect(String address, int port) async {
    final resolvedAddresses = await _resolveAddress(address);
    var socket = await Socket.connect(resolvedAddresses.first, port);
    add(socket);
    return socket;
  }

  Future<List<InternetAddress>> _resolveAddress(String address) async {
    List<InternetAddress> resolvedAddresses =
        await InternetAddress.lookup(address);
    if (resolvedAddresses.isEmpty) {
      throw Exception("Unable to resolve host");
    }
    return resolvedAddresses;
  }

  void add(Socket socket) {
    _cleanUpClosedConnections();
    if (!_isClosed(socket)) {
      final existingConnections = _find(socket);
      _destroy(existingConnections);
      socket.setOption(SocketOption.tcpNoDelay, true);
      socket.encoding = utf8;
      _sockets.add(socket);
    }
  }

  void removeAll() {
    _destroy(_sockets);
  }

  void remove(Socket socket) {
    _cleanUpClosedConnections();
    if (!_isClosed(socket)) {
      var toDisconnect = _find(socket);
      _destroy(toDisconnect);
    }
  }

  bool established() {
    return _sockets.isNotEmpty;
  }

  Iterable<Socket> _find(Socket socket) {
    return _sockets.where((x) =>
        x.remoteAddress == socket.remoteAddress &&
        x.remotePort == socket.remotePort);
  }

  void _destroy(Iterable<Socket> sockets) {
    while (sockets.isNotEmpty) {
      var socket = sockets.first;
      socket.destroy();
      _sockets.remove(socket);
    }
  }

  // Check if socket was remotely closed, thus address and port are not accessible
  bool _isClosed(Socket socket) {
    try {
      socket.remoteAddress;
      socket.port;
      return false;
    } on SocketException catch (_) {
      return true;
    } catch (e) {
      // Close the socket, as something is completely wrong with it
      log('Unexpected exception in determining socket closure: \'{}\''
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
