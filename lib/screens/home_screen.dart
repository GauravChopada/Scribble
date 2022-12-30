import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scribble/providers/room_provider.dart';
import './lobby_screen.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class homeScreen extends StatefulWidget {
  static const Routename = '/homeScreen';
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  String roomId = '';
  String playerName = '';
  final GlobalKey<FormState> _formkey = GlobalKey();
  late IO.Socket socket;
  String msg = "nothing";

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    // print("1.");
    socket = IO.io("http://192.168.1.100:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false
    });
    // print("2. " + socket.id.toString());
    socket.connect();

    socket.onConnect(
        (data) => {print("connected"), print("2. " + socket.id.toString())});
    print(socket.connected);
    socket.emit("/test", "hello server");

    // socket.on(
    //     "success",
    //     (data) => {
    //           // print(data)
    //           Provider.of<roomProvider>(context, listen: false)
    //               .setMsg(data.toString())
    //         });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Scribble",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) => {playerName = value.trim()},
                      decoration: InputDecoration(
                          hintText: 'Player Name',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2.0),
                              borderRadius: BorderRadius.circular(20)),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(20))),
                      // keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Player Name';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      onChanged: (value) => {roomId = value.trim()},
                      decoration: InputDecoration(
                          hintText: 'Room name',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2.0),
                              borderRadius: BorderRadius.circular(20)),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(20))),
                      // keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Room Id';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // TextButton(
                  //     onPressed: () {
                  //       socket.emit("/createRoom", "Room1");
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) => ChangeNotifierProvider(
                  //             create: (context) => roomProvider(),
                  //             child: lobbyScreen(
                  //               socket: socket,
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     child: Text("Enter room")),
                  TextButton(
                      onPressed: () {
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        socket.emit("/enterRoom", {
                          "roomId": roomId.trim(),
                          "playerName": playerName.trim(),
                          "socketId": socket.id
                        });
                        // socket.emit("test", "abc");
                        // showDialog(
                        //     context: context,
                        //     builder: ((context) => AlertDialog(
                        //           actions: [
                        //             Center(
                        //               child: CircularProgressIndicator(),
                        //             ),
                        //             Selector<roomProvider, String>(
                        //                 builder: (_, msg, __) {
                        //                   return msg == ''
                        //                       ? Container()
                        //                       : Text(msg);
                        //                 },
                        //                 selector: (_, provider) => provider.msg)
                        //           ],
                        //         )));

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (context) => roomProvider(),
                              child: lobbyScreen(
                                socket: socket,
                                roomId: roomId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text("Enter room")),
                ],
              ),
            ),
            // Selector<roomProvider, String>(
            //     builder: (_, msg, __) =>
            //         msg != '' ? Text(msg) : Text("nothing yet"),
            //     selector: (_, provider) => provider.msg)
          ],
        )),
      ),
    );
  }
}
