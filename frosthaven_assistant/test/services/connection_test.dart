import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'connection_test.mocks.dart';

final _sut = Connection();
const _randomPortNumber = 54632;

@GenerateNiceMocks([MockSpec<Socket>()])
void main() {
  test('getAll returns list of sockets', () {
    // arrange
    final sut = Connection();
    final expected = <Socket>[];
    final socket = MockSocket();
    expected.add(socket);
    sut.add(socket);

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
      sut.add(socket);
    }

    // assert
    for (var socket in sockets) {
      verify(socket.setOption(SocketOption.tcpNoDelay, true));
    }
    verify(sockets.first.destroy());
    verifyNever(sockets.last.destroy());
  });

  test('removeAll removes all sockets', () {
    // arrange
    List<Socket> sockets = _setupSockets(_sut);

    // act
    _sut.removeAll();

    // assert
    for (var socket in sockets) {
      verify(socket.destroy());
    }
    _sut.established().shouldBeFalse();
  });

  test('remove removes specific socket', () {
    // arrange
    List<Socket> sockets = _setupSockets(_sut);
    final socketToDisconnect = sockets.first;
    final socketsToNotDisconnect =
        sockets.where((socket) => socket != socketToDisconnect);
    when(socketToDisconnect.remoteAddress).thenReturn(InternetAddress.anyIPv4);
    when(socketToDisconnect.port).thenReturn(_randomPortNumber);

    // act
    _sut.remove(socketToDisconnect);

    // assert
    for (var socket in socketsToNotDisconnect) {
      verifyNever(socket.destroy());
    }
    verify(socketToDisconnect.destroy());
  });

  test('remove removes sockets with unaccessible properties', () {
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
    sut.remove(socketToDisconnect);

    // assert
    for (var socket in socketsToNotDisconnect) {
      verifyNever(socket.destroy());
    }
    verify(socketToDisconnect.destroy());
  });

  test('remove removes sockets with unexpected exception', () {
    // arrange
    final sut = Connection();
    List<Socket> sockets = _setupSockets(sut);
    final socketToDisconnect = sockets.first;
    final socketsToNotDisconnect =
        sockets.where((socket) => socket != socketToDisconnect);
    when(socketToDisconnect.remoteAddress).thenThrow(Exception(''));
    when(socketToDisconnect.port).thenThrow(Exception(''));

    // act
    sut.remove(socketToDisconnect);

    // assert
    for (var socket in socketsToNotDisconnect) {
      verifyNever(socket.destroy());
    }
    verify(socketToDisconnect.destroy());
  });

  test('established returns true if socket was added', () {
    // arrange
    final sut = Connection();
    sut.add(MockSocket());

    // act
    final result = sut.established();

    // assert
    result.shouldBeTrue();
  });

  test('established returns false if no sockets were added', () {
    // arrange
    final sut = Connection();

    // act
    final result = sut.established();

    // assert
    result.shouldBeFalse();
  });

  test('connect returns socket connected to', () async {
    // arrange
    final expectedAddress = InternetAddress('127.0.0.1');

    // act
    final result = await _sut.connect(expectedAddress.toString(), 80);
    // assert

    result.port.shouldBe(80);
    result.address.shouldBe(expectedAddress);
  }, skip: 'Can not figure out port number to be tested on');
}

List<Socket> _setupSockets(Connection connection) {
  final sockets = <Socket>[];
  const socketCount = 3;
  for (var i = 0; i < socketCount; i++) {
    var socket = MockSocket();
    _addSocketForTesting(sockets, socket, connection);
  }
  return sockets;
}

void _addSocketForTesting(
    List<Socket> sockets, MockSocket socket, Connection connection) {
  sockets.add(socket);
  connection.add(socket);
}
