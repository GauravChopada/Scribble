import 'package:flutter/material.dart';
import 'package:scribble/providers/room_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/lobby_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Scribble',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider(
            create: (context) => roomProvider(), child: homeScreen()),
        routes: {
          homeScreen.Routename: (ctx) => homeScreen(),
          // lobbyScreen.Routename: ((context) => lobbyScreen()),
        });
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     connect();
//   }

//   String msg = "Nothing yet..";

//   void connect() {
//     print("1.");
//     var socket = IO.io("http://192.168.1.104:5000", <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false
//     });
//     print("2.");
//     socket.connect();

//     socket.onConnect((data) => {print("connected")});
//     print(socket.connected);
//     socket.emit("/test", "hello server");
//     socket.on("send", (data) => {print(data)});
//   }

//   Future<void> _incrementCounter() async {
//     connect();
//     // setState(() {
//     //   _counter++;
//     // });
//     // print('hello');
//     // final list = await InternetAddress.lookup("0.0.0.1");
//     // print(list);
//     // final socket = await Socket.connect("google.com", 80);
//     // Socket.connect('http://192.168.1.104', 4567).then((socket) => print(
//     //     '1. Server: Connected to: ${socket.remoteAddress.address}:${socket.remotePort}'));

//     // final socket = await Socket.connect('192.168.1.104', 4567);
//     // print('second step');
//     // setState(() {
//     //   print(
//     //       '1. Server: Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
//     //   msg =
//     //       'Server: Connected to: ${socket.remoteAddress.address}:${socket.remotePort}';
//     //   print("2. " + msg);
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     // return Scaffold(
//     //   appBar: AppBar(
       
//     //     title: Text(widget.title),
//     //   ),
//     //   body: Center(
        
//     //     child: Column(
         
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: <Widget>[
//     //         const Text(
//     //           'You have pushed the button this many times:',
//     //         ),
//     //         Text(
//     //           msg,
//     //           style: Theme.of(context).textTheme.headline4,
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     //   floatingActionButton: FloatingActionButton(
//     //     onPressed: _incrementCounter,
//     //     tooltip: 'Increment',
//     //     child: const Icon(Icons.add),
//     //   ), 
//     // );
//   }
// }
