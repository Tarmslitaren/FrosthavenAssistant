import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'client_test.mocks.dart';

Client _sut = Client();
final _getIt = GetIt.instance;

@GenerateNiceMocks([MockSpec<GameState>(), MockSpec<Communication>(), MockSpec<Connection>()])
void main() {
  test('does not send a message without active connections', () {
    //arrange
    const message = "TestMessage";
    final stubGameState = MockGameState();
    final mockCommunication = MockCommunication();
    final mockConnection = MockConnection();
    _getIt.registerFactory<GameState>(() => stubGameState);
    _getIt.registerFactory<Communication>(() => mockCommunication);
    _getIt.registerFactory<Connection>(() => mockConnection);

    //act
    _sut.send(message);

    //assert
    verifyNever(mockCommunication.sendTo(any, message));
  });
}
