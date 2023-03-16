import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scribble/providers/room_provider.dart';
import 'package:scribble/screens/game_screen.dart';
import 'package:scribble/screens/home_screen.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:flutter/services.dart';

class lobbyScreen extends StatefulWidget {
  static const Routename = '/lobbyScreen';
  final IO.Socket socket;
  String roomId = "";
  lobbyScreen({Key? key, required this.socket}) : super(key: key);

  @override
  State<lobbyScreen> createState() => _lobbyScreenState();
}

class _lobbyScreenState extends State<lobbyScreen> {
  var response;

  showSnackBar(String message, Color color) {
    return SnackBar(
      backgroundColor: color,
      closeIconColor: Colors.white,
      showCloseIcon: true,
      content: Text(message),
      duration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();

    widget.socket.on(
        "/getRoomPlayersResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .refreshPlayersData(response["data"])
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

    widget.socket.on(
        "/playerJoined",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  print("playerJoined event triggred...."),
                  print(payload),
                  Provider.of<roomProvider>(context, listen: false)
                      .refreshPlayersData(response["data"])
                }
              else if (response["status"] == 400)
                {
                  print(response["message"]),
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red))
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error while fetching players. Please refresh page again.",
                      Colors.red))
                }
            });

    widget.socket.on(
        "/playerLeft",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .refreshPlayersData(response["data"]),
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "${response["player"]["playerName"]} left room.",
                      Colors.red))
                }
              else if (response["status"] == 400)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red))
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error while fetching players. Please refresh page again.",
                      Colors.red))
                }
            });

    widget.socket.on(
        "/adminLeft",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .clearRoomData(),
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red)),
                  Navigator.of(context).pushNamed(homeScreen.Routename)
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error while fetching players. Please refresh page again.",
                      Colors.red))
                }
            });

    widget.socket.on(
        "/leaveRoomResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar(response["message"], Colors.red)),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error while fetching players. Please refresh page again.",
                      Colors.red))
                }
            });

    widget.socket.on(
        "/gameStarted",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => gameScreen(
                        socket: widget.socket,
                        // roomId: widget.roomId,
                      ),
                    ),
                  )
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar("Error while starting Game.", Colors.red))
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<roomProvider>(builder: (_, provider, __) {
      var currentRoom = provider.currentRoom;

      Future<bool> _onWillPop() async {
        return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to leave this room ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      widget.socket
                          .emit("/leaveRoom", {"roomId": currentRoom!.roomId});
                      Provider.of<roomProvider>(context, listen: false)
                          .clearRoomData();
                      Navigator.of(context).pushNamed(homeScreen.Routename);
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                ],
              ),
            )) ??
            false;
      }

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Container(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      "Room: ${currentRoom!.roomName}",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          widget.socket.emit("/getRoomPlayers",
                              {"roomId": currentRoom.roomId});
                        },
                        icon: Icon(Icons.refresh_rounded)),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: currentRoom.roomId));
                    ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                        "Room Id copied to clipboard.", Colors.green));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Room Id: ",
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              currentRoom.roomId,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  overflow: TextOverflow.visible),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.copy,
                          size: 24,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                  itemCount: currentRoom.roomPlayers.length,
                  itemBuilder: (context, index) {
                    final player = currentRoom.roomPlayers[index];
                    return Container(
                        child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(player["playerName"]),
                    ));
                  },
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    TextButton(
                        onPressed: () {
                          widget.socket.emit(
                              "/startGame", {"roomId": currentRoom.roomId});
                        },
                        child: Container(
                            width: 150,
                            padding: const EdgeInsets.all(15),
                            // margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(child: Text("Start Game")))),
                    const Spacer(),
                    TextButton(
                        // style: ButtonStyle(backgroundColor: Colors.blue),
                        onPressed: () {
                          _onWillPop();
                        },
                        child: Container(
                            width: 150,
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                                child: Text(
                              "Leave Room",
                              style: TextStyle(color: Colors.red),
                            )))),
                    Spacer()
                  ],
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            )),
          ),
        ),
      );
    });
  }
}
