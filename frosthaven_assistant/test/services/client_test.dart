import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'client_test.mocks.dart';

Client _sut = Client();
final _getIt = GetIt.instance;

@GenerateNiceMocks([MockSpec<GameState>(), MockSpec<Communication>()])
void main() {
  test('sends a message', () {
    //arrange
    const message = "TestMessage";
    final stubGameState = MockGameState();
    final mockCommunication = MockCommunication();
    _getIt.registerFactory<GameState>(() => stubGameState);
    _getIt.registerFactory<Communication>(() => mockCommunication);

    //act
    _sut.send(message);

    //assert
    verify(mockCommunication.sendTo(any, message));
  });
}
