import 'dart:io';
import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'communication_test.mocks.dart';

Communication _sut = Communication();

@GenerateMocks([Socket])
void main() {
  test('message is formatted in template', () {
    // arrange
    const message = "TestMessage";
    final expectedMessage = createValidMessage(data: message);
    var socket = MockSocket();

    // act
    _sut.sendTo(socket, message);

    // assert
    verify(socket.write(expectedMessage));
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
}

String createValidMessage({String data = "Message"}) {
  return "S3nD:$data[EOM]";
}
