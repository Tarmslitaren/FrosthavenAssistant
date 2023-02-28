import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'communication_test.mocks.dart';

final _sut = Communication();
final _socket = MockSocket();

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
    test('send message to all sockets', () {
      // arrange
      const receiverCount = 3;
      const data = 'Data';
      final message = createValidMessage(data: data);
      final sockets = <Socket>[];
      for (var i = 0; i < receiverCount; i++) {
        var socket = MockSocket();
        sockets.add(socket);
        _sut.add(socket);
      }

      // act
      _sut.sendToAll(data);

      // assert
      for (var socket in sockets) {
        verify(socket.write(message));
      }
    });

    test('removes all sockets', () {
      // arrange
      const receiverCount = 3;
      final sockets = <Socket>[];
      for (var i = 0; i < receiverCount; i++) {
        var socket = MockSocket();
        sockets.add(socket);
        _sut.add(socket);
      }

      // act
      _sut.disconnect();

      // assert
      for (var socket in sockets) {
        verify(socket.destroy());
      }
      _sut.connected().shouldBeFalse();
    });
  });
}

String createValidMessage({String data = "Message"}) {
  return "S3nD:$data[EOM]";
}
