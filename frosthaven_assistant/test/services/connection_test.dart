import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'connection_test.mocks.dart';

final _sut = Connection();
final _socket = MockSocket();
const _randomPortNumber = 5647382;

@GenerateNiceMocks([MockSpec<Socket>()])
void main() {
  group('sockets', () {
    test('getAll returns list of sockets', () {
      // arrange
      final sut = Connection();
      final expected = <Socket>[];
      final socket = MockSocket();
      expected.add(socket);
      sut.connect(socket);

      // act
      final result = sut.getAll();

      // assert
      result.shouldBeEqualTo(expected);
    });

    test('add adds a unique socket', () {
      // arrange
      final sut = Connection();
      final sockets = <Socket>[];
      for (var i = 0; i < 2; i++) {
        final socket = MockSocket();
        sockets.add(socket);
        when(socket.remoteAddress).thenReturn(InternetAddress.anyIPv4);
        when(socket.port).thenReturn(0);
      }

      // act
      for (var socket in sockets) {
        sut.connect(socket);
      }

      // assert
      for (var socket in sockets) {
        verify(socket.setOption(SocketOption.tcpNoDelay, true));
      }
      verify(sockets.first.destroy());
      verifyNever(sockets.last.destroy());
    });

    test('disconnectAll removes all sockets', () {
      // arrange
      List<Socket> sockets = _setupSockets(_sut);

      // act
      _sut.disconnectAll();

      // assert
      for (var socket in sockets) {
        verify(socket.destroy());
      }
      _sut.connected().shouldBeFalse();
    });

    test('disconnect removes specific socket', () {
      // arrange
      List<Socket> sockets = _setupSockets(_sut);
      final socketToDisconnect = sockets.first;
      final socketsToNotDisconnect =
          sockets.where((socket) => socket != socketToDisconnect);
      when(socketToDisconnect.remoteAddress)
          .thenReturn(InternetAddress.anyIPv4);
      when(socketToDisconnect.port).thenReturn(_randomPortNumber);

      // act
      _sut.disconnect(socketToDisconnect);

      // assert
      for (var socket in socketsToNotDisconnect) {
        verifyNever(socket.destroy());
      }
      verify(socketToDisconnect.destroy());
    });

    test('disconnect removes sockets with unaccessible properties', () {
      // arrange
      final sut = Connection();
      List<Socket> sockets = _setupSockets(sut);
      final socketToDisconnect = sockets.first;
      final socketsToNotDisconnect =
          sockets.where((socket) => socket != socketToDisconnect);
      when(socketToDisconnect.remoteAddress)
          .thenThrow(const SocketException('Remote address unavailable'));
      when(socketToDisconnect.port)
          .thenThrow(const SocketException('Port unavailable'));

      // act
      sut.disconnect(socketToDisconnect);

      // assert
      for (var socket in socketsToNotDisconnect) {
        verifyNever(socket.destroy());
      }
      verify(socketToDisconnect.destroy());
    });
    test('disconnect removes sockets with unexpected exception', () {
      // arrange
      final sut = Connection();
      List<Socket> sockets = _setupSockets(sut);
      final socketToDisconnect = sockets.first;
      final socketsToNotDisconnect =
          sockets.where((socket) => socket != socketToDisconnect);
      when(socketToDisconnect.remoteAddress).thenThrow(Exception(''));
      when(socketToDisconnect.port).thenThrow(Exception(''));

      // act
      sut.disconnect(socketToDisconnect);

      // assert
      for (var socket in socketsToNotDisconnect) {
        verifyNever(socket.destroy());
      }
      verify(socketToDisconnect.destroy());
    });
  });
}

List<Socket> _setupSockets(Connection Connection) {
  final sockets = <Socket>[];
  const socketCount = 3;
  for (var i = 0; i < socketCount; i++) {
    var socket = MockSocket();
    _addSocketForTesting(sockets, socket, Connection);
  }
  return sockets;
}

void _addSocketForTesting(
    List<Socket> sockets, MockSocket socket, Connection Connection) {
  sockets.add(socket);
  Connection.connect(socket);
}
