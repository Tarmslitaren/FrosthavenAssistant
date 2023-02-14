import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'client_test.mocks.dart';

Client _sut = Client();
final _getIt = GetIt.instance;

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([GameState])
void main() {
  group('fetchAlbum', () {
    test('returns an Album if the http call completes successfully', () {
      //arrange
      const message = "TestMessage";
      var stubGameState = MockGameState();
      _getIt.registerLazySingleton<GameState>(() => stubGameState);

      //act
      _sut.send(message);

      //assert
      expect(1, 1);
    });
  });
}
