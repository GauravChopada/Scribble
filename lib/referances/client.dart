// import 'dart:io';
// import 'dart:typed_data';

// import 'terminal_service.dart';

// Future<void> main() async {
//   // print("hello");
//   // final ip = InternetAddress.anyIPv4;
//   // final list = await InternetAddress.lookup("0.0.0.0");
//   // print(list);
//   final socket = await Socket.connect("192.168.1.104", 8000);
//   // final socket = await Socket.connect('localhost', 4567);
//   // print("hello");

//   print(
//       'Server: Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

//   socket.listen(
//     (Uint8List data) {
//       final serverResponse = String.fromCharCodes(data);
//       printGreen("Client $serverResponse");
//     },
//     // handle errors
//     onError: (error) {
//       print("Client: $error");
//       socket.destroy();
//     },

//     // handle server ending connection
//     onDone: () {
//       print('Client: Server left.');
//       socket.destroy();
//     },
//   );

// // Ask user for its username
//   String? username;

//   do {
//     print("Client: Please enter your username");
//     username = stdin.readLineSync();
//   } while (username == null || username.isEmpty);

//   socket.write(username);
// }
