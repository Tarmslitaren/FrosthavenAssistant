// ignore_for_file: no-magic-number

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant_server/game_server.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'game_server_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Socket>()])
void main() {
  group('GameServer.handleConnection', () {
    // Regression test for OSError errno=22 (EINVAL — "Invalid argument").
    // A client can disconnect between accept() and handleConnection, leaving
    // the socket fd already invalid. setOption() then throws SocketException.
    // Before the fix that exception was unhandled and propagated to Sentry.
    test('destroys socket and returns early when setOption throws EINVAL', () {
      final server = _StubGameServer();
      final socket = MockSocket();
      when(socket.setOption(SocketOption.tcpNoDelay, true)).thenThrow(
        const SocketException(
          'Invalid argument',
          osError: OSError('Invalid argument', 22),
        ),
      );

      expect(() => server.handleConnection(socket), returnsNormally);
      verify(socket.destroy());
    });
  });
}

// Minimal concrete GameServer for testing handleConnection in isolation.
class _StubGameServer extends GameServer {
  @override
  void resetState() {}
  @override
  void undoState() {}
  @override
  void redoState() {}
  @override
  void updateStateFromMessage(StateUpdateMessage message, Socket client) {}
  @override
  void setNetworkMessage(String data) {}
  @override
  void send(String data) {}
  @override
  String currentStateMessage(String commandDescription) => '';
  @override
  Future<String> getConnectToIP() async => '';
  @override
  void sendPing() {}
  @override
  void addClientConnection(Socket client) {}
  @override
  void removeClientConnection(Socket client) {}
  @override
  void removeAllClientConnections() {}
  @override
  void sendToOnly(String data, Socket client) {}
  @override
  void sendToOthers(String data, Socket client) {}
  @override
  void sendInitResponse(Socket client) {}
}
