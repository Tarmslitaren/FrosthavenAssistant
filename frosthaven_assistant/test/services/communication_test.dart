import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'communication_test.mocks.dart';

Communication _sut = Communication();

@GenerateMocks([Socket])
void main() {
  test('message is formatted in template', () {
    //arrange
    const message = "TestMessage";
    const expectedMessage = "S3nD:$message[EOM]";
    var socket = MockSocket();

    //act
    _sut.sendTo(socket, message);

    //assert
    verify(socket.write(expectedMessage));
  });

  test('data is extracted from message', () {
    //arrange
    const expectedData = "TestMessage";
    const message = "S3nD:$expectedData[EOM]";

    //act
    final result = _sut.dataFrom(message);

    //assert
    expect(result, expectedData);
  });
}
