import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scribble/providers/game_provider.dart';
import 'package:scribble/providers/room_provider.dart';
import 'package:scribble/screens/game_screen.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/player.dart';

class lobbyScreen extends StatefulWidget {
  static const Routename = '/lobbyScreen';
  final IO.Socket socket;
  final String roomId;
  lobbyScreen({Key? key, required this.socket, required this.roomId})
      : super(key: key);

  @override
  State<lobbyScreen> createState() => _lobbyScreenState();
}

// class StreamSocket {
//   final _socketResponse = StreamController<String>();

//   void Function(String) get addResponse => _socketResponse.sink.add;

//   Stream<String> get getResponse => _socketResponse.stream;

//   void dispose() {
//     _socketResponse.close();
//   }
// }

class _lobbyScreenState extends State<lobbyScreen> {
  String test = "x";
  @override
  void initState() {
    super.initState();

    // widget.socket.emit("getRoomData", widget.roomId);

    // widget.socket.on(
    //     "test",
    //     (data) => {
    //           Provider.of<roomProvider>(context, listen: false)
    //               .setMsg(data.toString())
    //         });

    // widget.socket.on(
    //     "success",
    //     (data) => {
    //           print(data),
    //           Provider.of<roomProvider>(context, listen: false)
    //               .setMsg(data.toString())
    //         });

    widget.socket.emit("getPlayers", widget.roomId);

    widget.socket.on("gameStarted", (data) => {});

    widget.socket.on(
        "roomJoined",
        (data) => {
              print("..................." + data),
              Provider.of<roomProvider>(context, listen: false)
                  .addNewPlayer(data)
              // Provider.of<roomProvider>(context, listen: false)
              //     .setMsg(data.toString())
            });

    widget.socket.on(
        "getPlayersResponse",
        (data) => {
              print("getPlayersResponse event triggred...."),
              Provider.of<roomProvider>(context, listen: false)
                  .refreshPlayersData(data)
            });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to leave this room ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  widget.socket.emit("leaveRoom", widget.roomId);
                  print("called back");
                  Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // StreamSocket streamSocket = StreamSocket();
    // final socket = ModalRoute.of(context)!.settings.arguments as IO.Socket;

    // widget.socket.on('event', (data) => streamSocket.addResponse);

    // socket.onConnect(
    //   (data) {
    //     socket.on("emitClient", (data) {
    //       print("emitClient" + data);
    //     });
    //   },
    // );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),

              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    "Room: " + widget.roomId,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        widget.socket.emit("getPlayers");
                      },
                      icon: Icon(Icons.refresh_rounded)),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: Consumer<roomProvider>(builder: (_, provider, __) {
                    print(provider.players);
                    return ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                      itemCount: provider.players.length,
                      itemBuilder: (context, index) {
                        final player = provider.players[index];
                        // ignore: avoid_unnecessary_containers
                        return Container(
                            child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(player.playerName),
                        ));
                      },
                    );
              })),

              // Selector<roomProvider, String>(
              //     selector: (_, provider) => provider.msg,
              //     builder: (_, msg, __) => msg != '' ? Text(msg) : Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (context) => gameProvider(),
                              child: gameScreen(
                                socket: widget.socket,
                                roomId: widget.roomId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                          width: 150,
                          padding: EdgeInsets.all(15),
                          // margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(child: Text("Start Game")))),
                  Spacer(),
                  TextButton(
                      // style: ButtonStyle(backgroundColor: Colors.blue),
                      onPressed: () {
                        _onWillPop();
                      },
                      child: Container(
                          width: 150,
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child: Text(
                            "Leave Room",
                            style: TextStyle(color: Colors.red),
                          )))),
                  Spacer()
                ],
              ),
              SizedBox(
                height: 30,
              )
            ],
          )),
        ),
      ),
    );
  }
}
