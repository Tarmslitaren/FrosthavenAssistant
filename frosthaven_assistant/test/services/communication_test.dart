import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'communication_test.mocks.dart';

final _sut = Communication();
final _socket = MockSocket();
const _randomPortNumber = 5647382;

@GenerateNiceMocks([MockSpec<Socket>()])
void main() {
  test('message is formatted in template', () {
    // arrange
    const message = "TestMessage";
    final expectedMessage = createValidMessage(data: message);

    // act
    _sut.sendTo(_socket, message);

    // assert
    verify(_socket.write(expectedMessage));
  });

  test('data is extracted from message', () {
    // arrange
    const expectedData = "TestMessage";
    final message = createValidMessage(data: expectedData);

    // act
    final result = _sut.dataFrom(message);

    // assert
    expect(result, expectedData);
  });

  test('message should be valid', () {
    // arrange
    final validMessage = createValidMessage();

    // act
    final result = _sut.isValid(validMessage);

    // assert
    result.shouldBeTrue();
  });

  test('message should not be valid', () {
    // arrange
    const invalidMessage = "Message";

    // act
    final result = _sut.isValid(invalidMessage);

    // assert
    result.shouldBeFalse();
  });

  group('sockets', () {
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
      final sut = Communication();
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
      final sut = Communication();
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

  group('Messaging', () {
    test('SendToAllExcept sends data to all sockets except one', () {
      // arrange
      const data = 'TestMessage';
      List<Socket> sockets = _setupSockets(_sut);
      final excludedSocket = sockets.first;
      final includedSockets =
          sockets.where((socket) => socket != excludedSocket);
      when(excludedSocket.remoteAddress).thenReturn(InternetAddress.anyIPv4);
      when(excludedSocket.port).thenReturn(_randomPortNumber);

      // act
      _sut.sendToAllExcept(excludedSocket, data);

      //assert
      for (var socket in includedSockets) {
        verify(socket.write(any));
      }
      verifyNever(excludedSocket.write(any));
    });

    test('send message to all sockets', () {
      // arrange
      const data = 'Data';
      final message = createValidMessage(data: data);
      List<Socket> sockets = _setupSockets(_sut);

      // act
      _sut.sendToAll(data);

      // assert
      for (var socket in sockets) {
        verify(socket.write(message));
      }
    });
  });
}

List<Socket> _setupSockets(Communication communication) {
  final sockets = <Socket>[];
  const socketCount = 3;
  for (var i = 0; i < socketCount; i++) {
    var socket = MockSocket();
    _addSocketForTesting(sockets, socket, communication);
  }
  return sockets;
}

void _addSocketForTesting(
    List<Socket> sockets, MockSocket socket, Communication communication) {
  sockets.add(socket);
  communication.add(socket);
}

String createValidMessage({String data = "Message"}) {
  return "S3nD:$data[EOM]";
}
