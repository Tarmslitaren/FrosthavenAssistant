import 'package:frosthaven_assistant_server/standalone_server.dart';

void main() async {
  StandaloneServer server = StandaloneServer();
  print("Starting Server");
  await server.startServerInternal("0.0.0.0", 4567);
}
