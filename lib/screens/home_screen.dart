import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scribble/providers/room_provider.dart';
import './lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

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
  var response;

  showSnackBar(String message, Color color) {
    return SnackBar(
      backgroundColor: color,
      closeIconColor: Colors.white,
      showCloseIcon: true,
      content: Text(message),
    );
  }

  void socketConnect() {
    socket = IO.io(dotenv.env['SERVER_URL'], <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false
    });
    socket.connect();

    socket.onConnect((data) => {
          // ignore: avoid_print
          print("connected to socket: ${socket.id}"),
          ScaffoldMessenger.of(context).showSnackBar(
              showSnackBar("Connected to Server..", Colors.green)),
        });
  }

  @override
  void initState() {
    super.initState();
    socketConnect();

    socket.onDisconnect((payload) => {
          ScaffoldMessenger.of(context).showSnackBar(
              showSnackBar("Connection Lost to server..", Colors.red)),
          Provider.of<roomProvider>(context, listen: false).clearRoomData(),
          Navigator.of(context).pushNamed(homeScreen.Routename)
        });

    socket.on(
        "creatingRoom",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .roomCreated(response["data"]),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => lobbyScreen(
                        socket: socket,
                      ),
                    ),
                  )
                }
              else if (response["status"] == 400)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red))
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar("Error.. Room Creation failed", Colors.red))
                }
            });

    socket.on(
        "joiningRoom",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .roomJoined(response["data"]),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => lobbyScreen(
                        socket: socket,
                      ),
                    ),
                  )
                }
              else if (response["status"] == 400)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red))
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar("Error.. Could not join room", Colors.red))
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Scribble",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
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
                                    borderSide: const BorderSide(
                                        color: Colors.deepPurple, width: 2.0),
                                    borderRadius: BorderRadius.circular(20)),
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2.0),
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
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            onChanged: (value) => {roomId = value.trim()},
                            decoration: InputDecoration(
                                hintText: 'Room name',
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.deepPurple, width: 2.0),
                                    borderRadius: BorderRadius.circular(20)),
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2.0),
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
                        TextButton(
                            onPressed: () {
                              if (socket.disconnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    showSnackBar("Not connected to server.",
                                        Colors.red));
                              } else {
                                socket.emit("/createRoom", {
                                  "roomName": roomId.trim(),
                                  "playerName": playerName.trim(),
                                  "socketId": socket.id
                                });
                              }
                            },
                            child: Text("Create Room")),
                        TextButton(
                            onPressed: () {
                              if (!_formkey.currentState!.validate()) {
                                return;
                              } else if (socket.disconnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    showSnackBar("Not connected to server.",
                                        Colors.red));
                              } else {
                                socket.emit("/enterRoom", {
                                  "roomId": roomId.trim(),
                                  "playerName": playerName.trim(),
                                  "socketId": socket.id
                                });
                              }
                            },
                            child: Text("Join room")),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
