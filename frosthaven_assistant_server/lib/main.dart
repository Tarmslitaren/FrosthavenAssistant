import 'dart:io';

import 'package:frosthaven_assistant_server/standalone_server.dart';

void main() async {
  StandaloneServer server = StandaloneServer();
  ProcessSignal.sigint.watch().listen((signal) {
    print('Received SIGINT signal, shutting down gracefully...');
    server.stopServer("Shutdown Requested");
    exit(0);
  });
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((signal) {
      print('Received SIGTERM signal, shutting down gracefully...');
      server.stopServer("Shutdown Requested");
      exit(0);
    });
  }

  print("Starting Server");
  await server.startServerInternal("0.0.0.0", 4567);
}
