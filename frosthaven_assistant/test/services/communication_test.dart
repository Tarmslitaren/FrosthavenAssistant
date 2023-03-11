import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'communication_test.mocks.dart';

final _sut = Communication();
final _socket = MockSocket();
const _randomPortNumber = 5647382;
final _getIt = GetIt.instance;
final stubConnection = MockConnection();

@GenerateNiceMocks([MockSpec<Socket>(), MockSpec<Connection>()])
void main() {
  setUpAll(() {
    _getIt.registerFactory<Connection>(() => stubConnection);
    when(stubConnection.getAll())
        .thenReturn([MockSocket(), MockSocket(), MockSocket()]);
  });

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

  group('Messaging', () {
    test('SendToAllExcept sends data to all sockets except one', () {
      // arrange
      const data = 'TestMessage';
      List<Socket> sockets = stubConnection.getAll();
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
      List<Socket> sockets = stubConnection.getAll();

      // act
      _sut.sendToAll(data);

      // assert
      for (var socket in sockets) {
        verify(socket.write(message));
      }
    });
  });
}

String createValidMessage({String data = "Message"}) {
  return "S3nD:$data[EOM]";
}
