import 'dart:async';

import 'package:fluent_assertions/fluent_assertions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'client_test.mocks.dart';

Client _sut = Client();
final _getIt = GetIt.instance;
const _address = '127.0.0.1';

@GenerateNiceMocks([
  MockSpec<GameState>(),
  MockSpec<Communication>(),
  MockSpec<Connection>(),
  MockSpec<Network>(),
  MockSpec<Settings>(),
  MockSpec<ValueNotifier<String>>(as: Symbol('MockValueNotifierString')),
  MockSpec<ValueNotifier<ClientState>>(
      as: Symbol('MockValueNotifierClientState'))
])
final _connection = MockConnection();
final _gameState = MockGameState();
final _communication = MockCommunication();
final _network = MockNetwork();
final _settings = MockSettings();
final _valueNotifierString = MockValueNotifierString();
final _valueNotifierClientState = MockValueNotifierClientState();

List<String> log = [];

void main() {
  setUpAll(() {
    when(_settings.lastKnownPort).thenReturn('0000');
    _getIt.registerFactory<Connection>(() => _connection);
    _getIt.registerFactory<GameState>(() => _gameState);
    _getIt.registerFactory<Communication>(() => _communication);
    _getIt.registerFactory<Network>(() => _network);
    _getIt.registerFactory<Settings>(() => _settings);
  });

  test('connect creates client connection with server', overridePrint(() async {
    // arrange
    when(_network.networkMessage).thenReturn(_valueNotifierString);
    when(_settings.client).thenReturn(_valueNotifierClientState);

    // act
    await _sut.connect(_address);

    // assert
    log.any((element) => element.contains('port nr: 0')).shouldBeTrue();
  }));
}

void Function() overridePrint(void Function() testFn) => () {
      var spec = ZoneSpecification(print: (_, __, ___, String msg) {
        log.add(msg);
      });
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };
