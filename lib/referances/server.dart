import 'dart:io';
import 'dart:typed_data';

import 'terminal_service.dart';

Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 8000);
  print("Server is running on: ${ip.address}:4567");
  server.listen((Socket event) {
    handleConnection(event);
  });
}

List<Socket> clients = [];

void handleConnection(Socket client) {
  printGreen(
    "Server: Connection from ${client.remoteAddress.address}:${client.remotePort}",
  );

  client.listen(
    (Uint8List data) async {
      // final message = String.fromCharCodes(data);

      // for (final c in clients) {
      //   c.write("Server: $message joined the party!");
      // }

      // clients.add(client);
      // client.write("Server: You are logged in as: $message");
    }, // handle errors
    onError: (error) {
      printRed(error);
      client.close();
    },

    // handle the client closing the connection
    onDone: () {
      printWarning('Server: Client left');
      client.close();
    },
  );
}
